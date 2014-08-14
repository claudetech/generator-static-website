var yeoman = require('yeoman-generator'),
    path = require('path');

module.exports = yeoman.generators.NamedBase.extend({
  constructor: function () {
    yeoman.generators.NamedBase.apply(this, arguments);
    this.option('css', {
      desc: 'Select CSS templating.',
      defaults: 'stylus'
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

  installDependencies: function () {
    if (!this.options.skipInstall) {
      this.npmInstall();
    }
  },

  initializeGit: function () {
    this.spawnCommand('git', ['init']);
  }
});
