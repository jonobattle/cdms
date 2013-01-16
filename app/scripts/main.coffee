require.config({
  shim: {
  },

  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min'
  }
});


@API_URL   = "http://localhost:3000"
@CONTAINER = "#container"
@NAVIGATION_CONTAINER = "#navigation"
@SESSION_CONTAINER = "#session"
 
require [ "controllers/app", 
          "controllers/router", 
          "controllers/navigations", 
          "controllers/pages", 
          "controllers/session", 
          "models/page", 
          "models/account",
          "models/navigation", 
          "vendor/mkay", 
          "vendor/jquery.cookie", 
          "vendor/jquery.address-1.5.min"], ->

  window.app = new App
  window.app.load()

  

