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
    controller: require('./controllers/AppController')
    abstract: true
  )
  
  .state( 'app.home',
    url: '/home'
    templateUrl: 'home.html'
    controller: require('./controllers/HomeController')
  )
  
  .state('app.settings',
    url: '/settings'
    template: '<ion-nav-view></ion-nav-view>'
    controller: require('./controllers/Settings/RootController')
    abstract: true
  )
  
  .state('app.settings.general',
    url: '/general'
    templateUrl: 'settings/general.html'
    controller: require('./controllers/Settings/GeneralController')
  )
  
  $urlRouterProvider.otherwise '/app/home'
)
