(function($) {
  window.ppp = {
    ui: {
      showUserLocation: function() {
        ppp.util.getUserCity({
          loading: this.getUserCityLoading,
          success: this.onGetClientAddress
        })
      },
      onGetUserCity: function(city) {
        $('#client-location').html("<p>Current city: " + city + ".</p>");
        var $link = $("<a href='#'>Get my location again!</a>").click(function() {
          ppp.util.getUserCity({
            force: true,
            loading: ppp.ui.getUserCityLoading,
            success: ppp.ui.onGetUserCity
          })
        })
        $('#client-location').append($link);
      },
      getUserCityLoading: function() {
        $('#client-location').html("<p>Loading location...</p>")
      }
    },

    util: (function() {
      // ==== Private functions ====
      
      var emptyFunction = function() { };
      
      var EVENTS = ["loading", "success", "error", "unavailable"];
      
      // Given an object, ensure that the object has callbacks for all events we will be
      // using in the asynchronous request function factories (defined below).
      // If an event does not have a callback, it is given an empty one.
      //
      function normalizeEventCallbacks(events) {
        events = $.extend({}, events); // copy
        if ($.isFunction(events)) events = {success: events};
        $.each(EVENTS, function(i, event) {
          events[event] = events[event] || emptyFunction;
        })
        return events;
      }
      
      // Given a context and a series of functions, executes one function within the given
      // context, feeds the return value to the next function, and returns the final result.
      //
      // That is, given functions f, g, and h, returns h(g(f)).
      //
      function feedFunctionsRight(context/*, functions...*/) {
        var functions = Array.prototype.slice.call(arguments, 1);
        return function() {
          // feed return value rightward into each successive function
          // as a stack, layer each successive function on the one before it - the return value bubbles up
          // in math terms, it looks like f(...) then g(f(...)) then h(g(f(...))), etc.
          var result = functions[0].apply(context, arguments);
          $.each(functions.slice(1), function(i, fn) {
            if (fn != emptyFunction) result = fn.apply(context, result);
          })
          return result;
        }
      }
      
      /*
      function wrapEvent(events, event, layer, context) {
        events = $.extend({}, events); // copy
        var original = events[event];
        if (original) {
          events[event] = feedFunctionsRight(context, original, layer);
        } else {
          events[event] = layer;
        }
        return events;
      }
      
      function wrapEvents(events, layers, context) {
        events = $.extend({}, events); // copy
        $.each(EVENTS, function(i, event) {
          if (layers[event]) events = wrapEvent(events, event, layers[event], context);
        })
        return events;
      }
      */
      
      // Defines a function useful for making a request to a service asynchronously and
      // handling the result of the request in a meaningful way. The function which will
      // be defined accepts an options object which lets you specify callbacks for four
      // events:
      //
      // * loading:     Fired before the request occurs.
      // * success:     Fired if the request was successful. The callback, if supplied,
      //                will presumably be given the result of the request.
      // * error:       Fired if the request was unsuccessful.
      // * unavailable: Fired if the functionality the service provides is not available.
      //                Currently only used by the geolocation function (below).
      //
      defineAsyncRequestFunction: function(callback) {
        return function() {
          var args = Array.prototype.slice.call(arguments);
          var options = args.pop();
          options = normalizeEventCallbacks(options);
          options.loading();
          args.push(options);
          callback.apply(this, args);
        }
      },
      
      // This function makes sense only in the context of defineAsyncRequestFunction(),
      // above. So read more about that first.
      //
      // This function is the next logical step above defineAsyncRequestFunction().
      // Namely, once we've made an asynchronous request and gotten a result back, we would
      // like to store this in a cookie so that successive calls to the function we are
      // creating will simply draw from the cookie. Although it's less of a speedup than
      // preventing another request, we would also like to prevent drawing from the cookie
      // successively, by storing the result in memory. Finally, we would like to provide
      // the option to bypass the cache and hit the request again, with a 'force' option.
      //
      // This function makes it easy to create a function that does exactly this. Our
      // factory function here accepts two arguments. The first is a key which will be 
      // used to name the cookie and the in-memory value when caching the result of the
      // request. The second argument is the request callback itself.
      //
      // It's important to keep in mind that the function that will end up being returned
      // here (again, this is a factory function) is merely a wrapper for a function that
      // was defined using defineAsyncRequestFunction(), above. That is, your request
      // callback is going to receive an 'events' object which represent a set of callbacks.
      // In your request callback, you're probably going to call some hypothetical other
      // request function. The point is that since you still have the 'events' object,
      // you'll need to call events.success somewhere (otherwise the data won't make it
      // back and get cached).
      //
      // This is probably kind of hard to understand, so here's an example. Say we've
      // defined this function:
      //
      //   var getLocationFromService = defineAsyncRequestFunction(function(events) {
      //     // call some service, and get some result...
      //     options.success(result);
      //   })
      //
      // And now we want to have a cached version of that function. So we can do this:
      //
      //   var getCachedLocationFromService = definedCachedRequestFunction("location", function(events) {
      //     var events = $.extend({}, events, {
      //       success: function(data) {
      //         // do something with the data...
      //         events.success(data);
      //       }
      //     })
      //     getLocationFromService(events);
      //   })
      //
      // Now the getLocationFromService() function will get called, and the result will
      // be cached appropriately.
      //
      // Notice that we use $.extend to make a duplicate of the events object, and then
      // merge our 'success' callback into it. This is because if there's already, say,
      // an 'error' event, we don't want to wipe that out.
      // 
      function defineCachedRequestFunction(dataKey, request) {
        return function(events) {
          events = normalizeEventCallbacks(events);
          
          if (!events.force) {
            if (this[dataKey]) {
              events.success(this[dataKey]);
              return;
            }
            var value = $.cookie(dataKey);
            if (value) {
              value = JSON.parse(value);
              events.success(value);
              this[property] = value;
              return;
            }
          }

          var storeData = (function(self) {
            return function(data) {
              var value = JSON.stringify(data);
              $.cookie(cookieName, value, {
                expires: 7, // days
                path: '/'
              });
              self.clientAddress = data;
              return data;
            }
          })(this);
          
          events.success = feedFunctionsRight(this, storeData, events.success);
          
          request.call(this, events);
        }
      }
      
      // Reformats the result from the Google Geocoding API into a more palatable form.
      // See: http://groups.google.com/group/google-maps-js-api-v3/msg/ab743b525e0cc841
      //
      function reformatAddressComponents(result) { 
        var result2 = {}; 
        var components = result.address_components;
        $.each(result.address_components, function(i, component) {
          $.each(component.types, function(j, type) {
            result2[type] = component.short_name;
            result2[type + "_long"] = component.long_name;
          })
        })
        for (var prop in result) { 
          if (prop != "address_components") result2[prop] = result[prop]; 
        } 
        return result2; 
      }
      
      // ==== Public functions ====
      
      return {
        // Find the user's location, and run it through the Google Geolocation API to
        // find the user's address. Calls the 'success' callback with the city and state.
        //
        getUserCity: defineCachedRequestFunction('userCity', function(events) {
          var events = $.extend({}, events, {
            success: function(loc) {
              var events = $.extend({}, events, {
                success: function(results) {
                  results = reformatAddressComponents(results);
                  var address = results[0];
                  var city = address.administrative_area_level_2,
                      state = address.administrative_area_level_1;
                  events.success({city: city, state: state});
                }
              })
              this.geocodeLocationViaGoogle(loc, events);
            }
          });
          this.geolocateClient(events)
        }),
        
        // Lower-level functions
        
        // Runs the given coordinates (latitude, longitude) through the Google Geocoding
        // API. Calls the 'success' callback with the raw results, or the 'error' callback
        // if the request produced an error.
        //
        geocodeLocationViaGoogle: defineAsyncRequestFunction(function(loc, events) {
          var geocoder = new google.maps.Geocoder();
          var latlng = new google.maps.LatLng(loc.latitude, loc.longitude);
          geocoder.geocode({'latLng': latlng}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
              events.success(results);
            } else {
              events.error(status);
            }
          })
        }),

        // Uses HTML5 geolocation, or Google Gears if the client's browser doesn't support
        // that, to determine the client's location. Calls the 'success' callback with
        // the coordinates (latitude, longitude), the 'error' callback if request produced
        // an error, or 'unavailable' if the client's browser doesn't support geolocation
        // or geolocation is disabled.
        //
        geolocateClient: defineAsyncRequestFunction(function(events) {
          // Copied from: <http://code.google.com/apis/maps/documentation/javascript/basics.html#DetectingUserLocation>
          // TODO: Update to use Modernizr when we add the HTML5 boilerplate
          if (navigator.geolocation) {
            // Browser supports HTML5 geolocation natively.
            navigator.geolocation.getCurrentPosition(function(pos) { events.success(pos.coords) }, events.error);
          } else if (google.gears) {
            // Browser doesn't support HTML5 geolocation, but does have Google Gears.
            var geo = google.gears.factory.create('beta.geolocation');
            geo.getCurrentPosition(function(pos) { events.success(pos) }, events.error);
          } else {
            // Geolocation is unsupported or has been disabled.
            events.unavailable();
          }
        })
      }
    })()
  };
})(jQuery)