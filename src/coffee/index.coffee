require('./angular')

document.addEventListener('deviceready', (->
  domElement = document.getElementById('body')
  angular.bootstrap domElement, [ 'mainApp' ]
), false)
