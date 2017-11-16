$('.upload-btn').on('click', function () {
    $('#upload-input').click();
});


function updateStatus() {
  var status = {
    name: localStorage.getItem("status"),
  }
  var $cont = $('.status');
  var file = "status/" + localStorage.getItem("status") + '.txt';
  $.ajax({
    type: 'GET',
    url: '/status',
    data: status,
    dataType: "json",
    contentType: "application/json",
    success: function(data) {
      if (data.status[data.status.length-2] == 'Finished') {
         $cont.empty();
        for (var i = 0; i < data.status.length-1; i++) {
          $cont.append('<p>' + data.status[i] + '</p>');
          $cont[0].scrollTop = $cont[0].scrollHeight;
        }
        var pathToReport = data.status[data.status.length-1];
        if (pathToReport == '0') {
           $cont.append('<p><b>Uploaded data could not be processed. Read Status Report.</b></p>');
           localStorage.setItem("checkStatus", 'false');
        }
        else {
           self.redirect(pathToReport);
        }
      }
      else {
         $cont.empty();
         for (var i = 0; i < data.status.length; i++) {
           $cont.append('<p>' + data.status[i] + '</p>');
           $cont[0].scrollTop = $cont[0].scrollHeight;
         }

      }
    },
    error: function(e) {
     console.log(e.message);
    }
  });
};

this.redirect = function(pathToResults) {
  localStorage.setItem("checkStatus", 'false');
  document.getElementById("previous_tests").disabled = false;
  window.location.replace('/report?path=' + pathToResults);
}

$(document).ready(
  setInterval(
    function() {
      var checkStatus = localStorage.getItem("checkStatus");
      if (checkStatus.localeCompare('true') == 0) {
        console.log("updating status: " + localStorage.getItem("checkStatus"));
        updateStatus();
      }
    }, 2000)
  );

function guid() {
 function s4() {
   return Math.floor((1 + Math.random()) * 0x10000)
     .toString(16)
     .substring(1);
 }
 return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
   s4() + '-' + s4() + s4() + s4();
}

$('#upload-input').on('change', function(){
   var files = $(this).get(0).files;
   var ext = files[0].name.split('.');
   if (ext[1] !== 'zip')
      alert('Accepting only zip files. You file was: ' + files[0].name);
   else {
      var $cont = $('.status');
      $cont.empty();
      $cont.append('<p>Uploading file and starting MATLAB</p>');
      var status = guid();
      localStorage.setItem("status", status);
      // data to be sent to the server
      var algo = document.getElementById('algorithm').value;
      var username = localStorage.getItem("username");
      var status = localStorage.getItem("status");

      var fd = new FormData();
      fd.append('file', files[0]);
      fd.append("user", username);
      fd.append("algo", algo);
      fd.append("status", status);
      $.ajax({
         url: '/upload',
         data: fd,
         processData: false,
         contentType: false,
         type: 'POST',
         success: function(data){
            $cont.append('<p>' + data + '</p>');
            localStorage.setItem("checkStatus", 'true');
         },
         error: function(data) {
            localStorage.setItem("checkStatus", 'false');
            $cont.empty();
            $cont.append('<p>' + data.responseText + '</p>');
         }
      });
   }
});
