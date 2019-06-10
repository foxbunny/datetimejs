[![Build Status](https://travis-ci.com/foxbunny/datetimejs.svg?branch=master)](https://travis-ci.com/foxbunny/datetimejs)

# Datetime.js

Succinct library for manipulating, formatting, and parsing date and time.

Datetime.js started as an attempt to copy Python's fantastic `datetime` library.
Although it fell well short of the mark, it took a direction that ended up
being a much better fit for JavaScript, especially in the front end.

## Features

- Flexible and unambiguous date formatting and parsing functions using the
  tried and true strftime-style format tokens.
- Functions for creating, cloning, and manipulating dates.
- Functions for quering and calculating time and date differences.
- Easy support for localization.

## Quick start

Here is a quick example. It should work exactly the same in both Node and
browser environments.

```javascript
import * as dt from 'datetimejs';
// const dt = require('datetimejs');

// create a plain Date object for 2019-03-15T00:00:00.000
let d = new Date(2019, 2, 15, 0, 0, 0, 0);

// Add two days to d
let d1 = dt.datetime.addDays(d, 2);

// Format and log the date object
console.log(dt.format.strftime(d1, '%m/%d/%Y %i %p'));
// => 03/17/2019 12 a.m.

// Change the text for 'a.m.' and 'p.m.'
dt.updateDefaultConfig({
  AM: 'AM',
  PM: 'PM',
});

// Format again with the updated config
console.log(dt.format.strftime(d1, '%m/%d/%Y %i %p'));
// => 03/17/2019 12 AM

// create a plain Date object for 2019-03-17T15:00:00.000
// 15 hours ahead of d1
let d2 = new Date(2019, 2, 17, 15, 0, 0, 0);

// Calculate the delta between two date objects
let diff = dt.dtdelta.delta(d1, d2);

// The delta object has `hours` property
console.log(diff.hours);
// => 15

// The delta object has `minutes` property; same interval as `hours` just
// expressed in minutes
console.log(diff.minutes);
// => 900

// Create a new date object by adding the delta to a date object
let d3 = dt.datetime.addDelta(d1, diff);

// Create a date object by parsing a string ('yml' doesn't confuse us!)
let d4 = dt.parse.strptime(
  '2009-03-22_12-22-05.yml',
  '%Y-%m-%d_%H-%M-%S.yml', 
);
```

## Motivation

Since the original release in 2013, the library has had two goals:

- Provide strftime-based formatting and parsing.
- Provide methods for manipulating and creating `Date` objects that cover the
  most tedious tasks and nothing more.

The reason strftime was chosen is because it allows unambiguous format
specification using a very terse syntax. Although it has a bit of a learning
curve initially, it is far more flexible than ambiguous formats that do not use
escape characters.

Although libraries today can afford to be pretty big thanks to tree-shaking,
the downside of letting a library grow is the increasing API surface and
functionality that goes unused due to obscurity.  For example, we do not have
`addHours()` even though we have `addDays()` because `addDelta()` covers
`addHours()`, `addMinutes()`, and `addSeconds()`.  If a function can be easily
derived from another one, then it is not included.  Similarly, functions like
`isAfter()` were even removed because the JavaScript's comparison operators get
the job done, and `isAfter()` does not add much value. JavaScript developers
already know operators anyway, and this is just one less thing they'd have to
learn.

Datetime.js focuses on bang per byte rather than completeness. 

## Installation

To install this package, you can use NPM:

```bash
npm install --save datetimejs
```

or Yarn:

```bash
yarn add datetimejs
```

## Library overview

The `datetimejs` module exports the following modules:

- `config` - format and calendar configuration.
- `datetime` - date creation, cloning, and manipulation.
- `dtdelta` - calculation of date and time differences and date/time queries.
- `format` - date and time formatting.
- `parse` - date and time parsing.

Additionally, it exports the `updateDefaultConfig()` function which comes from
the `config` module.

Details about these modules and functions can be found in the documentation.

## Documentation

The generated documentation is available in the `docs` directory within the
source tree.

## Migrating from pre-1.0.0 versions

The way Datetime.js was configured was a bit different with releases before
1.0.0. Configuration was done by assigning to variables that were exported by
the main module.

Starting with 1.0.0, configuration can be done one of two ways:

1. By calling the `datetimejs.updateDefaultConfig()` function and passing it
   fragments of configuration.
2. By passing complete configuration objects to `strftime()` and `stfptime()`
   functions.

Adding custom format and parse tokens is done the same way as before, however
the `FORMAT_TOKENS` and `PARSE_RECIPES` variables have been moved to
`datetimejs.format` and `datetimejs.parse`, respectively.

The `DAY_MS` variable is no longer configurable as there is no need for that.

Some functions that are trivially replicated using simpler JavaScript or can be 
derived from other functions in this library have been removed completely.
Please refer to the 1.0.0 changelog for migration strategies.
