# generator-static-website

Yeoman generator to create static websites with
[Stylus](http://learnboost.github.io/stylus/), 
[Jade](http://jade-lang.com/) and 
[CoffeeScript](http://coffeescript.org/).
Support for [Axis CSS](http://roots.cx/axis/) integrated.

## Installation

Run 

```
npm install -g yo grunt-cli generator-static-website
```

If you get a permission error, try running `npm` with `sudo`.

## Usage

To create a new website, run

```
yo static-website MY_WEBSITE
```

The directory `MY_WEBSITE` will be generated.
You can then start coding.

```
cd MY_WEBSITE
grunt
```
