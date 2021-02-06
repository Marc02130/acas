#!/usr/bin/python
"""
Create a Live Report in LiveDesign with data from provided ACAS experiment.

By:
Brian Fielder

"""

import json
import sys
import argparse


try:
    import http.client as http_client
except ImportError:
    # Python 2
    import http.client as http_client
http_client.HTTPConnection.debuglevel = 0

import ldclient
from ldclient.client import LDClient as Api
from ldclient.client import LiveReport
from ldclient.models import Project

try:
    import requests
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    from requests.packages.urllib3.exceptions import InsecurePlatformWarning
    from requests.packages.urllib3.exceptions import SNIMissingWarning
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    requests.packages.urllib3.disable_warnings(InsecurePlatformWarning)
    requests.packages.urllib3.disable_warnings(SNIMissingWarning)
except ImportError:
    #ignore error, allow warnings
    print('ignoring ImportError')

def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def make_acas_live_report(api, compound_ids, assays_to_add, experiment_code, logged_in_user, database, projectId, ldClientVersion, readonly):

    folder_names = {}
    for folder in api.list_folders([projectId]):
        if int(folder.project_id) == int(projectId):
            folder_names[folder.name] = folder.id
    if 'Autogenerated ACAS Reports' not in list(folder_names.keys()):
        print('Autogenerated ACAS Reports folder does not exist in this project. Creating it')
        folder = api.create_folder('Autogenerated ACAS Reports', projectId)
        folder_id = folder.id
    else:
        folder_id = folder_names['Autogenerated ACAS Reports']    
   
    lr = LiveReport(experiment_code, 
                    "Contains the data just loaded",
                    project_id = projectId)

    lr = api.create_live_report(lr)
    #change LR owner to logged in user
    lr.owner = logged_in_user
    #put the LR in the Autogenerated ACAS Reports folder
    lr.tags = [folder_id]
    #Make the LR read-only
    if readonly:
        lr.update_policy = LiveReport.NEVER
    #Update LR
    api.update_live_report(lr.id, lr)
    
    
    lr_id = int(lr.id)
    print("Live Report ID is:" + str(lr_id))
    #get the list of assay addable columns
    if ldClientVersion >= 7.6:
        assay_column_ids = []
        for assay_to_add in assays_to_add:
            assay_tree=api.get_folder_tree_data(projectId, assay_to_add['protocolName'])
            #print json.dumps(assay_tree)
            if type(assay_tree) is list:
                assay_tree=[x for x in assay_tree if x['name'] == 'Experimental Assays'][0]
                #print json.dumps(assay_tree)
            assay = findassay(assay_tree, assay_to_add['protocolName'])
            assay_column_ids = extract_endpoints(assay, [])
    else:
        assays = api.assays()
        assay_hash = {}
        for assay in assays:
            if assay.name not in assay_hash:
                assay_hash[assay.name] = {}
            for assay_type in assay.types:
                assay_hash[assay.name][assay_type.name] = assay_type.addable_column_id
        assay_column_ids = []
        for assay_to_add in assays_to_add:
            assay_column_ids.append(assay_hash[assay_to_add['protocolName']][assay_to_add['resultType']])
    #assay_column_id1 = assay_hash["Peroxisome proliferator-activated receptor delta"]["EC50"]
    #assay_column_id2 = assay_hash["DRC TEST ASSAY"]["IC50%"]


    # This is the API call to cause addition of the assay columns by their ids
    # need to modify code above to take the list of assay names and types as input
    # and generte an array of matchign ids and pass those in here
    api.add_columns(lr_id,assay_column_ids)
    
    #add an external property
    #addable_column_id is found in /api/extprop/versions?project_ids=0%2C1%2C476759
    
    #hide the rationale column
    rationale_column_descriptor = api.column_descriptors(lr_id,'Rationale')[0]
    rationale_column_descriptor.hidden = True
    api.update_column_descriptor(lr_id,rationale_column_descriptor)
   
    #compound search by id
    search_results = []
    if isinstance(compound_ids, str):
        search_results.extend(api.compound_search_by_id(compound_ids, database_names=[database], project_id = projectId))
    else:
        search_string = ""
        for compound_id in compound_ids:
            search_string += compound_id +"\n"
        search_results.extend(api.compound_search_by_id(search_string, database_names=[database], project_id = projectId))
    # Now add the rows for the compound ids for which we want data
    #compound_ids = ["V51411","V51412","V51413","V51414"]
    api.add_rows(lr_id, search_results)
    
    return lr_id

def findassay(assay_tree, assay_name):
    if 'name' in assay_tree and assay_tree['name'] == assay_name: return assay_tree
    elif 'name' in assay_tree and assay_name in assay_tree['name'] and 'column_folder_node_type' in assay_tree and assay_tree['column_folder_node_type']=='ROLLUP': return assay_tree
    for sub_tree in assay_tree['children']:
        item = findassay(sub_tree, assay_name)
        if item is not None:
            return item  
            
def extract_endpoints(assay, endpoints):
    #print json.dumps(assay)
    if 'addable_column_ids' in assay and len(assay['addable_column_ids']) > 0:
        endpoints.extend(assay['addable_column_ids'])
    for sub_assay in assay['children']:
        extract_endpoints(sub_assay, endpoints)
    return endpoints       

def main():
    #if len(sys.argv) is not 4:
    #    raise Exception("Must call with endpoint, username, and password" +\
    #                    " i.e.: python example.py http://<server>:9087 <user> <pass>")
    #endpoint = sys.argv[1]
    #username = sys.argv[2]
    #password = sys.argv[3]
    parser = argparse.ArgumentParser(description='Parse input parameters')
    parser.add_argument('-i', '--input', type=json.loads)
    parser.add_argument('-e', '--endpoint', type=str)
    parser.add_argument('-u', '--username', type=str)
    parser.add_argument('-p', '--password', type=str)
    parser.add_argument('-d', '--database', type=str)
    parser.add_argument('-r', '--readonly', type=str2bool)
    args = parser.parse_args()
    args = vars(args)
    endpoint = args['endpoint']
    username = args['username']
    password = args['password']
    #database = args['database']
    database = 'ACAS'

    compound_ids=args['input']['compounds']
    assays_to_add=args['input']['assays']
    experiment_code=args['input']['experimentCode']
    try:
        project=args['input']['project']
    except:
        project="Global"
    try:
        logged_in_user=args['input']['username']
    except:
        logged_in_user=username
    apiSuffix = "/api"
    apiEndpoint = endpoint + apiSuffix;
    api = Api(apiEndpoint, username, password)
#    api.reload_db_constants()
    try:
        ld_client_version=float(ldclient.client.SUPPORTED_SERVER_VERSION)
    except:
        try:
            ld_client_version=float(ldclient.api.requester.SUPPORTED_SERVER_VERSION)
        except:
            ld_client_version=float(7.3)
    print("LDClient version is:"+str(ld_client_version))
    try:
#    	projectId = api.get_project_id_by_name(project)
        matching_projects = [p for p in api.projects() if p.name == project]
        projectId = int(matching_projects[0].id.encode('ascii'))
        print("Project " + project + " found with id: " + str(projectId))
    except:
        projectId = 0
    if type(projectId) is not int:
        projectId = 0
    lr_id = make_acas_live_report(api, compound_ids, assays_to_add, experiment_code, logged_in_user, database, projectId, ld_client_version, args["readonly"])
    
    liveReportSuffix = "/#/projects/"+str(projectId)+"/livereports/";
    print(endpoint + liveReportSuffix + str(lr_id))
    #return endpoint + liveReportSuffix + str(lr_id)

if __name__ == '__main__':
    main()

    
 
