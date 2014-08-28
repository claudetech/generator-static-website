livereloadPort = 35729
httpServerPort = 9000

fs         = require 'fs'
path       = require 'path'
loremIpsum = require 'lorem-ipsum'

lorem = (count, options={}) ->
  if typeof count == 'number'
    options.count = count
  else
    options = count ? {}
  options.units ?= 'words'
  loremIpsum options

module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    watch:
      coffee:
        cwd: 'assets/js'
        files: 'assets/js**/*.coffee'
        tasks: ['brerror:newer:coffee:dev']
      js:
        files: 'assets/js/**/*.js'
        tasks: ['newer:copy:js']
      css:
        files: 'assets/css/**/*.css'
        tasks: ['newer:copy:css']
      stylesheets:
        cwd: 'assets/css' <% if(options.css === 'stylus') { %>
        files: 'assets/css/**/*.styl'
        tasks: ['brerror:newer:stylus:dev'] <% } else if (options.css === 'less') { %>
        files: 'assets/css/**/*.less'
        tasks: ['brerror:newer:less:dev'] <% } %>
      views:
        cwd: 'views' <% if(options.html === 'jade') { %>
        files: 'views/**/*.jade'
        tasks: ['brerror:newer:jade:dev'] <% } else if (options.html === 'ejs') { %>
        files: 'views/**/*.ejs'
        tasks: ['brerror:newer:ejs:dev']  <% } %>
      images:
        files: [
          'assets/img/**'
          'assets/favicon.ico'
        ]
        tasks: ['newer:copy:images']
      options:
        livereload: livereloadPort

    coffee:
      dev:
        files: [
          expand: true
          cwd: 'assets'
          src: ['js/**/*.coffee']
          dest: 'public'
          ext: '.js'
        ]
    <% if(options.css === 'stylus') { %>
    stylus:
      dev:
        files: [
          expand: true
          cwd: 'assets'
          src: ['css/**/*.styl', '!css/**/_*.styl']
          dest: 'public'
          ext: '.css'
        ]
        options:
          compress: false
      options:
        use: [
          require 'axis-css'
        ]
    <% } else if(options.css === 'less') { %>
    less:
      dev:
        files: [
          expand: true
          cwd: 'assets'
          src: ['css/**/*.less', '!css/**/_*.less']
          dest: 'public'
          ext: '.css'
        ]
    <% } if(options.html === 'jade') { %>
    jade:
      dev:
        files: [
          expand: true
          cwd: 'views'
          src: ['**/*.jade', '!**/_*.jade', '!layout.jade']
          dest: 'public'
          ext: '.html'
        ]
        options:
          pretty: true
          data:
            lorem: lorem
    <% } else if(options.html === 'ejs') { %>
    ejs:
      dev:
        files: [
          expand: true
          cwd: 'views'
          src: ['**/*.ejs', '!**/_*.ejs', '!layout.ejs']
          dest: 'public'
          ext: '.html'
        ]
        options:
          lorem: lorem
    <% } %>
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
      images:
        files: [
          expand: true
          cwd: 'assets'
          src: ['img/**']
          dest: 'public'
        ,
          src: 'assets/favicon.ico'
          dest: 'public/favicon.ico'
        ]
      js:
        files: [
          expand: true
          cwd: 'assets'
          src: 'js/**/*.js'
          dest: 'public'
        ]
      css:
        files: [
          expand: true
          cwd: 'assets'
          src: 'css/**/*.css'
          dest: 'public'
        ]

    concurrent:
      start:
        tasks: ['connect', 'watch', 'brerror:server']
        options:
          logConcurrentOutput: true
          gruntPath: path.join __dirname, 'node_modules', 'grunt-cli', 'bin', 'grunt'


  searchWord = (word, file, callback) ->
    fs.readdir file, (err, files) ->
      return unless err is null
      files.forEach (f) ->
        filepath = path.join file, f
        stat = fs.statSync filepath
        if stat.isDirectory()
          searchWord word, filepath, callback
        else
          fs.readFile filepath, 'utf8', (err, data) ->
            return unless err is null
            if data.indexOf(word) > -1
              callback filepath

  grunt.event.on 'watch', (action, filepath, task) ->
    return if task == 'images' || task == 'css' || task == 'js'
    cwd = path.join __dirname, grunt.config("watch.#{task}.cwd")
    filename = path.basename filepath, path.extname(filepath)
    searchWord filename, cwd, (file) ->
      date = new Date()
      fs.utimes file, date, date

  grunt.registerTask 'compile:dev', [
    'copy'       <% if (options.html == 'jade') { %>
    'jade:dev'   <% } else if(options.html == 'ejs') { %>
    'ejs:dev'    <% } if (options.css == 'stylus') { %>
    'stylus:dev' <% } else if (options.css == 'less') { %>
    'less:dev'   <% } %>
    'coffee:dev'
  ]
  grunt.registerTask 'default', ['compile:dev', 'concurrent:start']
