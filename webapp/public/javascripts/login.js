$('#loginForm')
  .ajaxForm({
    success: function(res, status, xhr, form) {
      localStorage.setItem("username", res);
      window.location  = "/index";
   },
   error: function(res, status) {
       alert('Invalid Credentials');
       window.location  = "/";
   }
  });
