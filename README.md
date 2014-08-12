# generator-static-website

Yeoman generator to create static websites with
[Stylus](http://learnboost.github.io/stylus/), 
[Jade](http://jade-lang.com/) and 
[CoffeeScript](http://coffeescript.org/).

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

## Features

* Support for [Axis CSS](http://roots.cx/axis/).
* [Lorem Ipsum generator](https://github.com/knicklabs/lorem-ipsum.js):
  You can use the lorem ipsum generator as the function `lorem` in all Jade templates:

  ```slim
  p= lorem({units: 'paragraphs', count: 2})
  ```
