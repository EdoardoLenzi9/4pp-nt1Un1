var GoogleAuth = require('google-auth-library');
var auth = new GoogleAuth;
var client = new auth.OAuth2(CLIENT_ID, '', '');


var isAuthenticated = function (){
	next();
};

/*
client.verifyIdToken(
    token,
    CLIENT_ID,
    function(e, login) {
      var payload = login.getPayload();
      var userid = payload['sub'];
    });

*/
