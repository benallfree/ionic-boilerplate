sprintf = require('sprintf-js').sprintf

module.exports = (
    $scope, 
    $ionicHistory, 
    $ionicPopup, 
    $ionicNavBarDelegate, 
    $ionicActionSheet,
    $jrCrop,
    $cordovaImagePicker,
    $cordovaFile
  ) ->
  
    cats = []
    for cat,subcats of categories
      if subcats.length==0
        cats.push
          key: cat
          name: cat
      else
        for subcat in subcats
          cats.push
            key: sprintf("%s|%s", cat, subcat)
            name: sprintf("%s - %s", cat, subcat)

    $scope.cats = cats
  
    $scope.do_logo = ->
      options = 
        maximumImagesCount: 1

      $cordovaImagePicker.getPictures(options)
        .then ( ((results) ->
          $jrCrop.crop(
            url: results[0]
            title: 'Move and Scale'
            width: 300
            height: 300
          ).then( (canvas)->
            _base64ToArrayBuffer = (base64) ->
              binary_string = window.atob(base64.replace(/\s/g, ''))
              len = binary_string.length
              bytes = new Uint8Array(len)
              i = 0
              while i < len
                bytes[i] = binary_string.charCodeAt(i)
                i++
              bytes.buffer
            resize = (src_canvas, dst_name, d,cb = null)->
              Caman(src_canvas, ->
                @resize
                  width: d
                  height: d
                @render =>
                  data_url = @toBase64('jpeg')
                  b64 = data_url.replace(/^data:.+?;base64,/, "");
                  console.log(data_url.substring(0,50))
                  data = _base64ToArrayBuffer(b64)
                  $cordovaFile.writeFile($scope.output_directory, dst_name, data, true).then(->
                    if cb
                      cb($scope.output_directory+ dst_name, data_url)
                  )
                @reset()
              )
            resize(canvas, 'logo-thumb.jpg', 75, (path, data_url)->
              $scope.show.logo_path = path
              $scope.logo_src = data_url
            )
            resize(canvas, 'logo.jpg', 1400, (path, data_url)->
              new UploadWorker(
                code: $scope.podcast.code
                type: 'logo'
                mime: 'image/jpeg'
                src: path
              )
            )
          )
        )), (error)->
          console.log(error)
        
    getb64 = (cdv_path, cb) ->
      resolveLocalFileSystemURL(cdv_path, (entry)->
        path = entry.toURL()
        window.plugins.Base64.encodeFile(path, (base64)->
          console.log(base64.substring(0,50))
          cb(base64)
        );
      )

    $scope.show = 
      title: ''
      subtitle: ''
      author: ''
      description: ''
      primary_category: ''
      secondary_category: ''
      is_explicit: false
      logo_path: null
    
    for k,v of $scope.show
      if($scope.podcast[k]?)
        $scope.show[k] = $scope.podcast[k]
  
    if($scope.show.logo_path)
      getb64( $scope.show.logo_path, (b64)->
        $scope.logo_src = b64;
      )
      
    console.log($scope.show)
    original = angular.copy($scope.show)
  
    $scope.has_changes = false
    $scope.$watch 'show', ((newValue, oldValue) ->
      $scope.has_changes = !angular.equals(original, newValue)
      $ionicNavBarDelegate.showBackButton !$scope.has_changes
    ), true
      
    $scope.save = ->
      validate =
        title: 'a title'
        logo_path: 'cover art'
        subtitle: 'a subtitle'
        author: 'an author'
        description: 'a description'
        primary_category: 'primary category'
        secondary_category: 'secondary category'
      for k,v of validate
        if(!($scope.show[k]?))
          $ionicPopup.alert(
            title: 'Required'
            template: "Please supply #{v}."
          )
          return
        $scope.show[k] = $scope.show[k].trim()
      for k,v of $scope.show
        $scope.podcast[k] = $scope.show[k]
      $scope.save_state()
      if($scope.has_changes)
        rss = FastCast.templates.rss
          podcast: $scope.podcast
        $cordovaFile.writeFile($scope.output_directory, $scope.podcast.code+'.rss', rss, true).then ((result) ->
          new UploadWorker(
            code: $scope.podcast.code
            type: 'rss'
            mime: 'application/rss+xml'
            src: $scope.output_directory + $scope.podcast.code+'.rss'
          )
        )
      $scope.home()

    $scope.cancel = ->
      hideSheet = $ionicActionSheet.show(
        destructiveText: 'Discard Changes'
        titleText: 'Discard changes'
        cancelText: 'Cancel'
        destructiveButtonClicked: ->
          $scope.home()
      )
  
    $jrCrop.defaultOptions.template = $jrCrop.defaultOptions.template.replace(/{{/g, '<%').replace(/}}/g, '%>')
