
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// Include the Twilio Cloud Module and initialize it
var twilio = require("twilio");
twilio.initialize("AC855ba2a9cbf2bc153f17c158f20e1435","ed9b89503ca93da370cceb4b3920952c");

// Create the Cloud Function
Parse.Cloud.define("verifyPhoneNumber", function(request, response) {
  // Use the Twilio Cloud Module to send an SMS
  var bodyDescription = "Here is your Pump verification code: "
  twilio.sendSMS({
    From: "(760)546-9862",
    To: request.params.number,
    Body: bodyDescription.concat(request.params.verification_code) 
  }, {
    success: function(httpResponse) { response.success("SMS sent!"); },
    error: function(httpResponse) { response.error("Uh oh, something went wrong"); }
  });
});
