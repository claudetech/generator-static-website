livereloadPort = 35729
httpServerPort = 9000

fs = require 'fs'

module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    watch:
      scripts:
        files: 'assets/js/**/*.coffee'
        tasks: ['newer:coffee:dev']
      stylesheets:
        files: 'assets/css/**/*.styl'
        tasks: ['newer:stylus:dev']
      views:
        files: 'views/**/*.jade'
        tasks: ['newer:jade:dev']
      options:
        livereload: livereloadPort

    coffee:
      dev:
        files: [
          expand: true
          cwd: 'assets'
          src: ["js/**/*.coffee"]
          dest: "public"
          ext: ".js"
        ]

    stylus:
      dev:
        files: [
          expand: true
          cwd: 'assets'
          src: ['css/**/*.styl']
          dest: "public"
          ext: ".css"
        ]
        options:
          compress: false
      options:
        use: [
          require('axis-css')
        ]

    jade:
      dev:
        files: [
          expand: true
          cwd: 'views'
          src: ['**/*.jade']
          dest: "public"
          ext: ".html"
        ]
        options:
          pretty: true

    connect:
      server:
        options:
          port: httpServerPort
          keepalive: true
          debug: true
          base: 'public'
          useAvailablePort: true
          open: true
          livereload: true

    copy:
      main:
        files: [
          expand: true
          cwd: 'assets'
          src: ['img/**']
          dest: 'public'
        ,
          src: 'assets/favicon.ico'
          dest: 'public/favicon.ico'
        ]

    concurrent:
      start:
        tasks: ['connect', 'watch']
        options:
          logConcurrentOutput: true

  grunt.registerTask 'compile:dev', ['copy', 'jade:dev', 'coffee:dev', 'stylus:dev']
  grunt.registerTask 'default', ['compile:dev', 'concurrent:start']
