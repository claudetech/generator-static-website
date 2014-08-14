var yeoman = require('yeoman-generator'),
    path = require('path');

module.exports = yeoman.generators.NamedBase.extend({
  constructor: function () {
    yeoman.generators.NamedBase.apply(this, arguments);
    this.option('css', {
      desc: 'Select CSS templating.',
      defaults: 'stylus'
    });
    this.option('html', {
      desc: 'Select HTML templating.',
      defaults: 'jade'
    });
  },

  prepareDir: function () {
    this.mkdir(this.name);
    this.destinationRoot(this.name);
  },

  copyCommonFiles: function () {
    this.sourceRoot(path.join(__dirname, 'templates/common'));
    this.copy('gitignore', '.gitignore');
  },

  copyFiles: function () {
    this.sourceRoot(path.join(__dirname, 'templates/website'));
    this.directory('.', '.');
  },

  copyCss: function () {
    if (this.options.css !== 'stylus' && this.options.css !== 'less') {
      this.log('Wrong CSS template engine ' + this.options.css);
      this.log('Using stylus instead.');
      this.options.css = 'stylus';
    }
    this.sourceRoot(path.join(__dirname, 'templates', 'assets', this.options.css));
    this.directory('.', 'assets/css');
  },

  copyViews: function() {
    if (this.options.html !== 'jade' && this.options.html !== 'ejs') {
      this.log('Wrong HTML template engine ' + this.options.html);
      this.log('Using jade instead.');
      this.options.html = 'ejs';
    }
    this.sourceRoot(path.join(__dirname, 'templates', 'views', this.options.html));
    this.directory('.', 'views');
  },

  installDependencies: function () {
    if (!this.options.skipInstall) {
      this.npmInstall();
    }
  },

  initializeGit: function () {
    if (!this.options.skipGit) {
      this.spawnCommand('git', ['init']);
    }
  }
});
