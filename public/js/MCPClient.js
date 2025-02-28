(function() {
  window.MCPClient = {
    baseUrl: window.conf.service.mcp.fullpath,
    
    // Example function to process chemistry data
    processMoleculeData: function(data, callback) {
      $.ajax({
        url: this.baseUrl + 'process/molecule',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(response) {
          callback(null, response);
        },
        error: function(error) {
          console.error("Error processing molecule data:", error);
          callback(error);
        }
      });
    },
    
    // Example function to retrieve processed data
    getProcessedResults: function(jobId, callback) {
      $.ajax({
        url: this.baseUrl + 'jobs/' + jobId,
        type: 'GET',
        success: function(response) {
          callback(null, response);
        },
        error: function(error) {
          console.error("Error retrieving job results:", error);
          callback(error);
        }
      });
    }
  };
})(); 