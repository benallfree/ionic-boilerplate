module.exports = ($scope, $state, $ionicSideMenuDelegate) ->
  console.log("AppController loaded")
  
  $scope.toggleLeft = ->
    $ionicSideMenuDelegate.toggleLeft()
  
  $scope.settings = ->
    $state.go 'app.settings.general'
  