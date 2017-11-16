var express = require('express');
var path = require('path');
var fs = require('fs');
var shell = require('shelljs');
var app = express();
var multer = require('multer');
const execSync = require('child_process').execSync;
var bodyParser = require('body-parser');
var ldap = require('ldapjs');

app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

var assert = require('assert');
var sprintf = require('util').format;

var BASE = 'dc=st,dc=com';
var FILTER_FMT = '(&(uid=%s))';
var URL = 'ldap://server:389';


var myLDAPBind = function(user, pass, callback) {
  assert.equal(typeof (user), 'string');
  assert.equal(typeof (pass), 'string');
  assert.equal(typeof (callback), 'function');

  var client = ldap.createClient({
     url: URL
  });

  var opts = {
     filter: sprintf(FILTER_FMT, user),
     scope: 'sub',
     attributes: ['mail']
  };

  var entry;
  return client.search(BASE, opts, function (err, res) {
    if (err) {
      return callback(err);
   }


    res.on('searchEntry', function (_entry) {
      entry = _entry;
    });


    res.on('error', function (err) {
      return callback(err);
    });

    res.on('end', function () {
      if (!entry) {
         return callback(new Error("non-exist"), null);
      }

      return client.bind(entry.dn.toString(), pass, function (err) {
         if (err) {
            return callback(err);
         }


        return client.unbind(function (err) {
          return callback(true, entry.toObject());
        });
      });
    });
  });
}

app.get('/validate', function(req, res) {
    var userPassword = req.query.password;
    var userName = req.query.username;

    myLDAPBind(userName, userPassword, function (err, user) {
      if (user == null) {
         res.status(500).send('User does not exist!')
      }
      else {
         userName = userName.replace(" ", "");
         res.send(userName);
      }
   });
});


var self = this;

let upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, callback) => {
      let path = '../Uploads/';
      if (!fs.existsSync(path)){
        fs.mkdirSync(path);
      }
      callback(null, path);
    },
    filename: (req, file, callback) => {
      //originalname is the uploaded file's name with extn
      var name = file.originalname.replace(' ', '');
      callback(null, name);
    }
  })
});

var type = upload.single('file');
// upload file to be processed
app.post('/upload', type, function(req, res) {
   var algo;
   switch (req.body.algo) {
      case 'Activity Recognition':
         algo = "AR";
         break;
      case "Carry Position":
         algo = "CP";
         break;
      case "Step Detection":
         algo = "SD";
         break;
      case "Vertical Context":
         algo = "VC";
         break;
   }
  // WINDOWS
  //console.log(__dirname.split("\\"));
  // LINUX
  //console.log(__dirname.split("/"));

  var user = req.body.user;
  var username = user.replace(" ", "");

  var path = '../Uploads/' + username;

  if (!fs.existsSync(path)){
    fs.mkdirSync(path);
  }

  path = path + '/' + self.getTime();
  if (!fs.existsSync(path)){
    fs.mkdirSync(path);
  }

  var newDest = path + '/' + req.file.filename;
  execSync('mv ../Uploads/' + req.file.filename + ' ' + newDest);

  var command = "unzip " + newDest + " -d " + path;
  execSync(command);

  // check if uploaded zip contains ST_PDR_Log.txt file(s)
  var output = shell.exec('sh ./bash/checkForST_PDR_Log.sh ' + path + '/').stdout;
  var output = output.split('');
  if (output[0] =="0") {
     execSync("rm -fr " + path);
     res.status(500).send('Uploaded zip does not contain ST_PDR_Log.txt');
  }
  else {
     // remove the zip file
     execSync("rm -fr " + newDest);

     /* write the contents of the directory to csv file
     If ecevuted without errors, the only content of the dir will be either one ST_PDR_Log.txt
     or multiple directories containing ST_PDR_Log.txt
     */
     execSync('sh ./bash/dataCSV.sh ' + path + '/');

     // execute Preprocessing in MATLAB
     var uniqueStatus = req.body.status;
     var pathToCsv  = path.substring(3, path.length) + '/data.csv';

     var statusPath = './status';
     if (!fs.existsSync(statusPath)){
      fs.mkdirSync(statusPath);
     }
     execSync('sh ./bash/callMATLAB.sh ' + algo + " " + username + " " + uniqueStatus + " " + pathToCsv);
     res.status(200).send('File uploaded successfully. Starting MATLAB...');
 }


});

this.getTime = function() {
  var d = new Date();
  var y = d.getFullYear();
  var month = self.addZero(d.getMonth() + 1, 2);
  var day = self.addZero(d.getDate(), 2);
  var h = self.addZero(d.getHours(), 2);
  var m = self.addZero(d.getMinutes(), 2);
  var s = self.addZero(d.getSeconds(), 2);
  var folderTime = y + "" +  month + "" + day + "" + h + "" + m + "" + s;
  return folderTime;
};

this.addZero = function(x,n) {
    while (x.toString().length < n) {
        x = "0" + x;
    }
    return x;
}

// return index page
app.get('/', function(req, res){
  res.sendFile(path.join(__dirname, 'views/login.html'));
});

app.get('/index', function(req, res) {
  res.sendFile(path.join(__dirname + "/views/" + "index.html"));
});

app.get('/status', function(req, res) {
  var url = 'status/' + req.query.name + '.txt';
  var stat = shell.exec('cat ' + url).stdout;
  stats = stat.split("\n");

  res.json({ok: true, status: stats,});
})



app.get('/report', function(req, res) {
  var path = req.query.path;

  var myPath = path + '/results.zip';
  var out = parseInt(shell.exec('[ -f ' + myPath + ' ] && echo 1 || echo 0').stdout);
  if ((out == 0)) {
    res.send("I couldn't generate output from the files you provided. \nCheck your file and the algorithm.\n" + "<a href='/index'>Home Page</a>");

  }
  else {
    res.sendFile(myPath);
  }
});



app.get('/checkProcessed', function(req, res) {
  var username = req.query.username;
  var user = username.split(".");
  user = user[0] + user[1];
  var command = "sh ./bash/returnProcessed.sh " + user;
  var processedCount = 0;
  shell.exec(command, function(code, stdout, stderr) {
    if (parseInt(stdout) > 0) {
      res.json({ok: true, count: parseInt(stdout)});
    }
    else {
      res.json({ok: false});
    }
  });
});

app.get('/processed', function(req, res) {
  var username = req.query.username;
  var command = 'sh ./bash/returnProcessed.sh ' + username;
  var processedFiles = [];
  shell.exec(command, function(code, stdout, stderr) {
    var arr = stdout.split("\n");
    for (var i = 0; i < arr.length; i++) {
      var nonvalid = arr[i].localeCompare('Uploads/' + username + '/*');
      if (nonvalid !== 0) {
        processedFiles.push(arr[i]);
      }
    }
    if (processedFiles.length > 0) {
      var files = self.getFiles(processedFiles, username);
      res.send(files);
    }
    else {
      res.send("error")
    }
  });
});


this.getFiles = function(processedFiles, user) {
   var arr = [];
   for(var row = 0; row < processedFiles.length; row++){
       arr[row] = [];
       for(var y = 0; y < 3; y++){
           arr[row][y] = "";
       }
   }

   for(var row = 0; row < processedFiles.length; row++){
      if (processedFiles[row] != '') {
         file = processedFiles[row].split('/');
         date = file[file.length-1].split('_');

         dateTime = date[1] + "/" + date[2] + "/" + date[0] + " Time: " + date[3] + ":" + self.addZero(date[4], 2);
         arr[row][0] = dateTime;

         algo = date[5];
         arr[row][1] = algo;

         // WINDOWS
         pathToReport = 'C:/matlabCode/combined-regression/Output/' + user + '/' + file[file.length-1];

         // LINUX
         //pathToReport = '' + user + '/' + file[file.length-1]
         arr[row][2] = pathToReport;
      }

   }

   return arr;
}

var server = app.listen(3000, function(){
   console.log('Server listening on port 3000');
});
