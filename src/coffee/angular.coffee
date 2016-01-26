require('ionic-sdk/release/js/ionic.bundle.min.js')
require('angular-ios9-uiwebview-patch')
require('ng-cordova')

app = angular.module('mainApp', [ 'ionic' ]).config(($interpolateProvider) ->
  $interpolateProvider.startSymbol('<%').endSymbol '%>'
)

.run(($ionicPlatform) ->
  $ionicPlatform.ready ->
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
    if window.StatusBar
      StatusBar.styleDefault()
)

.config(($stateProvider, $urlRouterProvider) ->
  $stateProvider
  .state('app',
    url: '/app'
    templateUrl: 'app.html'
    controller: 'AppController'
    abstract: true
  )
  .state( 'home',
    url: '/home'
    templateUrl: 'home.html'
    controller: 'HomeController'
    parent: 'app'
  )
  $urlRouterProvider.otherwise '/app/home'
)

require('./controllers/AppController')(app)
require('./controllers/HomeController')(app)
