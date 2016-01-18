gulp = require('gulp')
plumber = require('gulp-plumber')
concat = require('gulp-concat')
sass = require('gulp-sass')
haml = require('gulp-haml')
notify = require('gulp-notify')
jst = require('gulp-jst')
declare = require('gulp-declare')
iced = require('gulp-iced-coffee')
sourcemaps = require('gulp-sourcemaps')
notifier = require('node-notifier')
browserify = require('gulp-browserify')
rename = require('gulp-rename')
copy = require('gulp-copy')
del = require('del')

e = ->
  plumber({errorHandler: notify.onError("Error: <%= error.message %>")})

gulp.task 'clean', ->
  del(['./build/**/*'])

gulp.task 'default', ['browserify', 'sass', 'haml', 'fonts'], ->
  notifier.notify
    'title': 'Done'
    'message': 'Done!'

gulp.task 'fonts', ->
  gulp.src('./node_modules/ionic-sdk/release/fonts/**/*')
    .pipe(e())
    .pipe(copy('./build/out/fonts', {prefix: 4}))
    
gulp.task 'browserify', ['coffee', 'jst'], ->
  gulp.src([ './build/js/index.js' ])
    .pipe(e())
    .pipe(browserify({
		  debug : true
		}))
    .pipe(rename('app.js'))
    .pipe gulp.dest('./build/out/js')

gulp.task 'haml', ->
  gulp.src('./src/haml/**/*.haml')
    .pipe(e())
    .pipe(haml({
      ext: '.html'
      compiler: 'visionmedia'
    }))
    .pipe gulp.dest('./build/out')

gulp.task 'coffee', ->
  gulp.src([ './src/coffee/**/*.coffee' ])
    .pipe(e())
    .pipe(sourcemaps.init())
    .pipe(iced({ options: {bare: true}}))
    .pipe(sourcemaps.write())
    .pipe gulp.dest('./build/js')

gulp.task 'jst', ->
  gulp.src('./src/jst/*.html')
    .pipe(e())
    .pipe(jst())
    .pipe(declare({
      namespace: 'JST'
      noRedeclare: true
    }))
    .pipe(concat('jst.js'))
    .pipe gulp.dest('./build/js')

gulp.task 'sass', ->
  gulp.src(['./node_modules/ionic-sdk/release/css/ionic.css', './src/scss/**/*.scss'])
    .pipe(e())
    .pipe(sourcemaps.init())
    .pipe(sass({errLogToConsole: true}))
    .pipe(sourcemaps.write())
    .pipe(concat('app.css'))
    .pipe gulp.dest('./build/out/css')
    
gulp.task 'www', (cb)->
  del(['./www/**/*'])

  gulp.src('./build/out/**/*')
    .pipe(e())
    .pipe(copy('./www', {prefix: 2}))
    
  cb()

gulp.task 'watch', ->
  gulp.watch ['./src/scss/**/*.scss'], ['sass']
  gulp.watch './src/haml/**/*.haml', ['haml']
  gulp.watch './src/jst/**/*.html', ['browserify']
  gulp.watch './src/coffee/**/*.coffee', ['browserify']
