(function($) {
  window.ppp = {
    ui: {
      showUserLocation: function() {
        ppp.util.getClientAddress({
          loading: function() {
            $('#client-location').html("<p>Loading location...</p>")
          },
          success: this.onGetClientAddress
        })
      },
      onGetClientAddress: function(data) {
        var content = "<p>It looks like you are located at: (" + data.location.latitude + "," + data.location.longitude + ").</p>";
        content += "<p>Possible addresses:</p>";
        content += "<ul>";
        $.each(data.addresses, function(i, address) {
          content += "<li>" + address + "</li>";
        })
        content += "</ul>";
        $('#client-location').html(content);
        var $link = $("<a href='#'>Get my location again!</a>").click(function() {
          ppp.util.getClientAddress({
            force: true,
            loading: function() {
              $('#client-location').html("<p>Loading location...</p>")
            },
            success: ppp.util.onGetClientAddress
          })
        })
        $('#client-location').append($link);
      }
    },

    util: (function() {
      var emptyFunction = function() { };
      
      function normalizeCallbacks(options) {
        if ($.isFunction(options)) options = {success: options};
        options = $.extend({}, options);
        $.each("loading success error unavailable".split(" "), function(i, callback) {
          options[callback] = options[callback] || emptyFunction;
        })
        return options;
      }
      
      return {
        getClientAddress: function(options) {
          options = normalizeCallbacks(options);
          if (!options.force) {
            if (this.clientAddress) {
              options.success(this.clientAddress);
              return;
            }
            var address = $.cookie('client_address');
            if (address) {
              address = JSON.parse(address);
              options.success(address);
              this.clientAddress = address;
              return;
            }
          }
          options.loading();
          this.getClientCoordinates({
            loading: options.loading,
            success: function(loc) {
              var geocoder = new google.maps.Geocoder();
              var latlng = new google.maps.LatLng(loc.latitude, loc.longitude);
              geocoder.geocode({'latLng': latlng}, function(results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                  var addresses = [];
                  $.each(results, function(i, address) {
                    addresses.push(address.formatted_address);
                  })
                  var data = {location: loc, addresses: addresses};
                  var value = JSON.stringify(data);
                  $.cookie('client_address', value, {
                    expires: 7, // days
                    path: '/'
                  });
                  this.clientAddress = data;
                  options.success(data);
                } else {
                  options.error(status);
                }
              })
            },
            error: options.error,
            unavailable: options.unavailable
          });
        },

        // If we haven't found the user's location yet, does so and stores the result in a cookie.
        // Otherwise, just returns the result of that cookie. Additionally, the result is stored
        // in the ppp object so as not to hit the cookie again.
        //
        // This accepts the same arguments as geolocateClient(), so see that for more.
        // This also accepts a 'force' option, which will force the call to geolocateClient()
        // even if the result of a previous call to getClientCoordinates() was cached.
        //
        getClientCoordinates: function(options) {
          options = normalizeCallbacks(options);
          if (!options.force) {
            if (this.clientLocation) {
              options.success(this.clientLocation);
              return;
            }
            var loc = $.cookie('client_location');
            if (loc) {
              loc = JSON.parse(loc);
              options.success(loc);
              this.clientLocation = loc;
              return;
            }
          }
          options.success = (function(fn, self) {
            return function(loc) {
              fn(loc);
              var value = JSON.stringify(loc);
              $.cookie('client_location', value, {
                expires: 7, // days
                path: '/'
              });
              self.clientLocation = loc;
            };
          })(options.success, this);
          this.geolocateClient(options);
        },

        // Retrieves the physical location of the client by using HTML5 geolocation or Google Gears,
        // whichever the client's browser supports.
        //
        // Because we are making an asynchronous request, this function calls a function you supply
        // with the resulting location instead of merely returning the location.
        //
        // There are four possible events you can hook into:
        //
        // * loading:     Fired before the Ajax request to get the location occurs.
        // * success:     Fired if the Ajax request to get the location was successful.
        //                A callback, if supplied, will be called with the location, which
        //                is an object with 'latitude' and 'longitude' properties.
        // * error:       Fired if geolocation was unsuccessful. A callback, if supplied,
        //                will be called without any arguments.
        // * unavailable: Fired if the client's browser doesn't support geolocation or it has
        //                been disabled. A callback, if supplied, will be called without any
        //                arguments.
        //
        // You may specify a callback for any of the events by passing an object where
        // the property is the event. Alternately, if you're only interested in the success
        // event, you may pass only one argument instead of an object.
        //
        geolocateClient: function(options) {
          options = normalizeCallbacks(options);
          options.loading();
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
    })()
  };
})(jQuery)