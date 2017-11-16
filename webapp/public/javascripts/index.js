var self = this;

$( window ).on( "load", function() {
  localStorage.setItem("checkStatus", 'false');
  updateList();
  document.getElementById("data").style.visibility = "hidden";
});

function updateList() {
  var user = localStorage.getItem("username");
  var userData = {
    username: user
  }
  $.ajax({
    type: 'GET',
    url: '/processed',
    data: userData,
    dataType: 'text',
    success: function(data) {
      var dataX = JSON.parse(data);
      for (var i = 0; i < dataX.length-1; i++) {
        var row = $("<tr>");

        row.append($("<td>" + dataX[i][0] + "</td>"))
           .append($("<td>" + dataX[i][1] + "</td>"))
           .append($("<td>Processed (click to download)</td>"));

        $("#data tbody").append(row);
      }
      var table = document.getElementById("data");
      if (table != null) {
        for (i = 0; i < table.rows.length; i++) {
          table.rows[i].cells[2].onclick = function() {
             getReport(dataX[this.parentNode.rowIndex - 1][2]);
          };
         }
       }
    },
    error: function(e) {
      console.log("Error");
    }
  });
}

function getReport(path) {
  window.location.replace('/report?path=' + path);
}

function showTable() {
  $('#data > tbody > tr').remove();

  updateList();
  var visibility = document.getElementById("data").style.visibility;
  if (visibility.localeCompare("hidden") == 0) {
    document.getElementById("data").style.visibility = "visible";
  }
  else {
    document.getElementById("data").style.visibility = "hidden";
  }
}
