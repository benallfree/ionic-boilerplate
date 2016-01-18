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
  $stateProvider.state 'home',
    url: '/'
    templateUrl: 'home.html'
    controller: 'HomeController'
  $urlRouterProvider.otherwise '/'
)

require('./controllers/AppController')(app)
require('./controllers/HomeController')(app)
