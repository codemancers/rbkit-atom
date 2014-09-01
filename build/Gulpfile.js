var gulp = require('gulp');
var coffee = require('gulp-coffee');
var coffeelint = require('gulp-coffeelint');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');

var paths = {
  coffee: [
    '../src/**/*.coffee'
  ]
};

var onError = function(err) {
  gutil.log(err);
}

gulp.task('watch', function() {
  gulp.watch(paths.coffee, ['coffee']);
});

gulp.task('coffee', function() {
  return gulp.src(paths.coffee)
    .pipe(plumber(onError))
    .pipe(coffee())
    .pipe(gulp.dest('../src/'));
});

gulp.task('coffeelint', function() {
  return gulp.src(paths.coffee)
    .pipe(coffeelint())
    .pipe(coffeelint.reporter());
});

gulp.task('default', ['watch']);
