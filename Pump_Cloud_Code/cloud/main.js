
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

Parse.Cloud.define("retrieveRecentPassengers", function(request, response) {          
	var Trip = Parse.Object.extend("Trip");
	var query = new Parse.Query(Trip);
	query.equalTo("owner", Parse.User.current());
	query.include("passengers");
	query.limit(10)
	query.find({
	  success: function(results) {
	    alert("Successfully retrieved " + results.length + " trips.");
	    // Do something with the returned Parse.Object values
	    var users = [];
	    var counter = 0;
	    for (var i = results.length - 1; i >= 0; i--) {
	    	var trip = results[i];
	    	var passengers = trip.get("passengers");
	    	for (var j = passengers.length - 1; j >= 0; j--) {
	    		var passenger = passengers[j];
	    		if (containsObject(passenger, users) == false) {
	    			users.push(passenger);
	    		};
	    		counter ++;
	    		if (counter>20) {break;};
	    	};
	    	if (counter>20) {break;};
	    };
	    response.success(users);
	  },
	  error: function(error) {
	    alert("Error: " + error.code + " " + error.message);
	  }
	});    
});

function containsObject(obj, list) {
    var i;
    for (i = 0; i < list.length; i++) {
        if (list[i].id === obj.id || obj.id == Parse.User.current().id) {
            return true;
        }
    }

    return false;
}

Parse.Cloud.define("retrieveUsersWithPhoneNumbers", function(request, response) {
	var query = new Parse.Query(Parse.User);
	query.containedIn("phone", request.params.phone_numbers);
	query.notEqualTo("objectId", Parse.User.current().id);
	query.find({
	  success: function(results) {
	    alert("Successfully retrieved " + results.length + " scores.");
	    // Do something with the returned Parse.Object values
	    response.success(results);
	  },
	  error: function(error) {
	    alert("Error: " + error.code + " " + error.message);
	  }
	});        
});

