module.exports = (grunt) ->
  grunt.initConfig
    bower_concat:
      all:
        dest: 'public/js/bower.js'
        cssDest: 'public/css/bower.css'
        dependencies:
          'underscore': 'jquery'
          'backbone': 'underscore'
          'bootstrap': 'jquery'
        bowerOptions:
          relative: false

  grunt.loadNpmTasks 'grunt-bower-concat'

