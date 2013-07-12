describe("PasswordResetsController", function() {
  //Mocks
  var http = {};
  var routeParams = {};

  //Controller
  var ctrl = null;

  //Scope
  var $scope = null;

  beforeEach( function() {
    angular.module('window.KarmaTracker');
  });

  /* IMPORTANT!
   * this is where we're setting up the $scope and
   * calling the controller function on it, injecting
   * all the important bits, like our mockService */
  beforeEach(angular.inject(function($rootScope, $httpBackend, $controller) {
    //create a scope object for us to use.
    $scope = $rootScope.$new();

    //http mock from Angular
    http = $httpBackend;


    //now run that scope through the controller function,
    //injecting any services or other injectables we need.
    ctrl = $controller(PasswordResetsController, {
      $scope: $scope,
      $http: http,
      $routeParams: routeParams
    });
  }));


  it("foo spec", function() {
    expect($scope.foo).toEqual('test');
  });
});
