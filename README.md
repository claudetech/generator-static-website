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

### CSS engine

The default CSS engine is [Stylus](http://learnboost.github.io/stylus/).
However, you can use [less css](http://lesscss.org/) if you wish, by adding
`--css=less` to the yo command:

```
yo static-website MY_WEBSITE --css=less
```

### HTML template engine

The default HTML template engine is [Jade](http://jade-lang.com/).
However, you can use [ejs (with layouts)](https://github.com/RandomEtc/ejs-locals) if you wish, by adding
`--html=ejs` to the yo command:

```
yo static-website MY_WEBSITE --html=ejs
```

## Features

* [Lorem Ipsum generator](https://github.com/knicklabs/lorem-ipsum.js):
  You can use the lorem ipsum generator as the function `lorem` in all Jade/EJS templates:

  ```slim
  p= lorem({units: 'paragraphs', count: 2})
  ```

  ```ejs
  <%= lorem({units: 'paragraphs', count: 2}) %>
  ```
