describe("ppp.util", function() {
  describe(".getClientCoordinates", function() {
    describe("if ppp.util.clientLocation is set", function() {
      beforeEach(function() {
        this._oldClientLocation = ppp.util.clientLocation;
        ppp.util.clientLocation = {latitude: 32.3909, longitude: -108.0293};
        this.callback = jasmine.createSpy();
      })
      afterEach(function() {
        ppp.util.clientLocation = this._oldClientLocation;
      })
      it("calls the success callback with ppp.util.clientLocation", function() {
        ppp.util.getClientCoordinates({success: this.callback});
        expect(this.callback).toHaveBeenCalledWith({ latitude: 32.3909, longitude: -108.0293 });
      }),
      it("also calls the given callback if it's the only argument", function() {
        ppp.util.getClientCoordinates(this.callback);
        expect(this.callback).toHaveBeenCalledWith({ latitude: 32.3909, longitude: -108.0293 });
      })
    })
    
    describe("if the 'userlocation' cookie is set", function() {
      beforeEach(function() {
        $.cookie("userlocation", "32.3909,-108.0293");//, { path: "/" });
        this.callback = jasmine.createSpy();
      })
      it("calls the given success callback with the cookie", function() {
        ppp.util.getClientCoordinates({success: this.callback});
        var location = { latitude: 32.3909, longitude: -108.0293 };
        expect(this.callback).toHaveBeenCalledWith(location);
        expect(ppp.util.clientLocation).toEqual(location);
      })
      it("also calls the given callback if it's the only argument", function() {
        ppp.util.getClientCoordinates(this.callback);
        var location = { latitude: 32.3909, longitude: -108.0293 };
        expect(this.callback).toHaveBeenCalledWith(location);
        expect(ppp.util.clientLocation).toEqual(location);
      })
      afterEach(function() {
        ppp.util.clientLocation = null;
        $.cookie("userlocation", null);
      })
    })
    
    describe("if neither ppp.util.clientLocation nor the cookie is set", function() {
      beforeEach(function() {
        this.callback = jasmine.createSpy();
        this.location = { latitude: 32.3909, longitude: -108.0293 }
        spyOn(ppp.util, 'geolocateClient').andReturn(this.location);
        
        ppp.util.clientLocation = null;
        $.cookie("userlocation", null);
      })
      it("makes a call to geolocateClient with a wrapped function that sets the cookie after retrieving the location", function() {
        ppp.util.getClientCoordinates({success: this.callback});
      })
      it("also accepts one argument which is treated as the success callback", function() {
        ppp.util.getClientCoordinates(this.callback);
      })
      afterEach(function() {
        expect(ppp.util.geolocateClient).toHaveBeenCalled();
        var options = ppp.util.geolocateClient.mostRecentCall.args[0];
        options.success(this.location);
        expect(this.callback).toHaveBeenCalled();
        expect($.cookie("userlocation")).toEqual("32.3909,-108.0293");
        expect(ppp.util.clientLocation).toEqual(this.location);
      })
    })
    
    describe("if ppp.util.clientLocation is set, but force was passed", function() {
      beforeEach(function() {
        this.callback = jasmine.createSpy();
        this.location = { latitude: 32.3909, longitude: -108.0293 }
        spyOn(ppp.util, 'geolocateClient').andReturn(this.location);
        
        ppp.util.clientLocation = "something";
        $.cookie("userlocation", null);
      })
      it("makes a call to geolocateClient with a wrapped function that sets the cookie after retrieving the location", function() {
        ppp.util.getClientCoordinates({success: this.callback, force: true});
      })
      afterEach(function() {
        expect(ppp.util.geolocateClient).toHaveBeenCalled();
        var options = ppp.util.geolocateClient.mostRecentCall.args[0];
        options.success(this.location);
        expect(this.callback).toHaveBeenCalled();
        expect($.cookie("userlocation")).toEqual("32.3909,-108.0293");
        expect(ppp.util.clientLocation).toEqual(this.location);
      })
    })
    
    describe("if the cookie is set, but force was passed", function() {
      beforeEach(function() {
        this.callback = jasmine.createSpy();
        this.location = { latitude: 32.3909, longitude: -108.0293 }
        spyOn(ppp.util, 'geolocateClient').andReturn(this.location);
        
        ppp.util.clientLocation = null;
        $.cookie("userlocation", "something");
      })
      it("makes a call to geolocateClient with a wrapped function that sets the cookie after retrieving the location", function() {
        ppp.util.getClientCoordinates({success: this.callback, force: true});
      })
      afterEach(function() {
        expect(ppp.util.geolocateClient).toHaveBeenCalled();
        var options = ppp.util.geolocateClient.mostRecentCall.args[0];
        options.success(this.location);
        expect(this.callback).toHaveBeenCalled();
        expect($.cookie("userlocation")).toEqual("32.3909,-108.0293");
        expect(ppp.util.clientLocation).toEqual(this.location);
      })
    })
  })
})