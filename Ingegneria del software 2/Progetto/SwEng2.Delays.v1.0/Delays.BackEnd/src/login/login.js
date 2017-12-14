function onSignIn(googleUser) {
  var profile = googleUser.getBasicProfile();
  console.log("ID: " + profile.getId()); // Don't send this directly to your server!
  console.log('Full Name: ' + profile.getName());
  console.log('Given Name: ' + profile.getGivenName());
  console.log('Family Name: ' + profile.getFamilyName());
  console.log("Image URL: " + profile.getImageUrl());
  console.log("Email: " + profile.getEmail());
  // The ID token you need to pass to your backend:
  var id_token = googleUser.getAuthResponse().id_token;
  console.log("ID Token: " + id_token);
  signIn(id_token);
  window.open(baseUrl + "/busLines/","_self")
};

var signIn = function(id_token){
  axios.post(baseUrl + '/loginResponse', {id_token : id_token}, {
      headers: {
          'Content-Type': 'application/json',
      }
  })
  .then(function (response) {
    localStorage.setItem('profile', JSON.stringify(response.data.cookie));
  })
  .catch(function (error) {
      console.log(error);
  });
}

// Retrieve the object from storage
var retrievedObject = localStorage.getItem('testObject');

console.log('retrievedObject: ', JSON.parse(retrievedObject));