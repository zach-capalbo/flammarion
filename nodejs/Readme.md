# Flammarion

The nifty ~~ruby~~ nodejs GUI toolkit!

This package is a nodejs port of the ruby [flammarion](https://github.com/zach-capalbo/flammarion) gem. It is intended to be as similar as possible to use.

## Overview

Flammarion is an easy-to-use library for displaying information that you might normally display to the command line in a slightly easier-to-access way.

It is not intended to be a full fledged application development toolkit. It is intended instead for small scripts where you just want to show some information or buttons without going through too much trouble.

## Installation

Flammarion is designed to use existing installed web browsers. It will look for Chrome and MS Edge by default, or a global installation of Electron if available.

You can install the package globally by:

```
npm i -g flammarion
```

or you can install it for a particular script/project by running

```
npm i --save flammarion
```

## Tutorial

The easiest way to use Flammarion is similar to how you might use STDOUT:

_(Note: these examples are intended to be run from an interactive session such as Node.js.)_

```javascript
const {Engraving} = require('flammarion')
const f = new Engraving();
f.puts("Hello World!");
```

You can also do more advanced things. Say you want to show a table. Easy!

```javascript
f.table([
  ["Number", "Squared", "Sqrt"],
  ...Array.from({ length: 10 }, (x, i) => [i, i * i, Math.sqrt(i)])
]);
```

```javascript
let x = Array.from({ length: 10 }, (_, i) => i);
f.plot([{ x, y: x }, { x, y: x.map(i => i * i) }, { x, y: x.map(i => Math.sqrt(i)) }]);
```

If you need feedback, there's a simple callback mechanism for buttons and text boxes:

```javascript
f.button("Click Here!!!", () => { f.puts("You clicked the button!"); });
f.input("Placeholder > ", (msg) => { f.puts(`You wrote: ${msg.text}`); });
```

You can also use them with `await` in `async` functions:

```javascript
f.puts("Waiting for you to click the button:")
await f.button("Click it!!")
f.puts("Now waiting for you to type something")
let typed = await f.inputPromise("TYPE HERE>")
f.puts(`You typed ${typed}`)
```