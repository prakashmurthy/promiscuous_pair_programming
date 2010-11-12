var ppp = {
  ui: {
    showUserLocation: function() {
      ppp.util.getUserLocation(function(loc) {
        $('#client-location').html("It looks like you are located at: (" + loc.latitude + "," + loc.longitude + ')')
      })
    },
  },
  
  util: {
    // If we haven't found the user's location yet, does so and stores the result in a cookie.
    // Otherwise, just returns the result of that cookie. Additionally, the result is stored
    // in the ppp object so as not to hit the cookie again.
    //
    // This accepts the same arguments as geolocateClient(), so see that for more.
    //
    getUserLocation: function(options) {
      if ($.isFunction(options)) options = {success: options};
      if (this.clientLocation) {
        if (options.success) options.success(this.clientLocation);
      } else {
        var loc = $.cookie('userlocation');
        if (loc) {
          var latlng = loc.split(",");
          var loc = { latitude: Number(latlng[0]), longitude: Number(latlng[1]) }
          options.success(loc);
          this.clientLocation = loc;
        } else {
          options.success = (function(fn, self) {
            return function(loc) {
              fn(loc);
              var value = loc.latitude+','+loc.longitude;
              $.cookie('userlocation', value, {
                expires: 7, // days
                path: '/'
              });
              self.clientLocation = loc;
            };
          })(options.success, this);
          this.geolocateClient(options);
        }
      }
    },
  
    // Retrieves the physical location of the client by using HTML5 geolocation or Google Gears,
    // whichever the client's browser supports.
    //
    // Because we are making an asynchronous request, this function calls a function you supply
    // with the resulting location instead of merely returning the location.
    //
    // There are three possible statuses resulting from the request:
    //
    // * success:     Occurs if the Ajax request to get the location was successful.
    //                A callback, if supplied, will be called with the location, which is an
    //                object with 'latitude' and 'longitude' properties.
    // * error:       Occurs if geolocation was unsuccessful. A callback, if supplied, will
    //                be called without any arguments.
    // * unavailable: Occurs if the client's browser doesn't support geolocation or it has
    //                been disabled. A callback, if supplied, will be called without any
    //                arguments.
    //
    // You may specify a callback for any of the three status by passing an object where
    // the property is the status. Alternately, if you're only interested in the success
    // status, you may pass only one callback.
    //
    geolocateClient: function(options) {
      if ($.isFunction(options)) options = {success: options};
      // Copied from: <http://code.google.com/apis/maps/documentation/javascript/basics.html#DetectingUserLocation>
      // TODO: Update to use Modernizr when we add the HTML5 boilerplate
      if (navigator.geolocation) {
        // Browser supports HTML5 geolocation natively.
        navigator.geolocation.getCurrentPosition(function(pos) { options.success(pos.coords) }, options.error);
      } else if (google.gears) {
        // Browser doesn't support HTML5 geolocation, but does have Google Gears.
        var geo = google.gears.factory.create('beta.geolocation');
        geo.getCurrentPosition(function(pos) { options.success(pos) }, options.error);
      } else {
        // Geolocation is unsupported or has been disabled.
        if (options.unavailable) options.unavailable();
      }
    }
  }
};