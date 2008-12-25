// -- authored by melfar

var ServerStatsAgent = {
  sendRequest: function(payload, key, callback) {
    
    $.get('http://' + hostname.replace(/^http:\/\//, ''), {q: $.toJSON(payload)}, callback);
  }
};