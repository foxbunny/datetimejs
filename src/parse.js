/**
 * Date and time parsing
 *
 * @module datetimejs.parse
 */

import {lower, cycle, zeroPad, h12to24} from './utils';
import {DEFAULT_CONFIG} from './config';

// Array of regexp characters that should be escaped in a format string when
// parsing dates and times.
const REGEXP_CHARS = [
  '.',
  '^', '$',
  '[', ']',
  '(', ')',
  '{', '}',
  '+', '*', '?',
  '|',
];

/**
 * Recipes for parsing the date
 *
 * A recipe consists of a regular expression fragment (string) and a parsing
 * function. This object maps parse tokens to factory functions that take a
 * format configuration object and returns a recipe.
 *
 * The recipes are represented by an object with `re` and `fn` keys. The `re`
 * key is a string that represents a regular expression fragment that will
 * match any valid data for the token. The `fn` function takes the string
 * matched by the regular expression fragment, and an object that tracks the
 * progress of various values that were parsed. The function should examine the
 * string and update the progress object.
 *
 * To add a recipe for a new token, or override a recipe for an existing one,
 * we simply assign to the corresponding key on the `parse.PARSE_RECIPES`
 * object.
 *
 * @example
 *
 * parse.PARSE_RECIPES['%R'] = function (conf) {
 *   return {
 *     re: '....',
 *     fn: function (s, parsedValues) {
 *       // do something with `s` and update `parsedValues`
 *     },
 *   };
 * };
 */
export let PARSE_RECIPES = {
  '%b': function (conf) {
    let lowerCaseMonths = conf.MNTH.map(lower);

    return {
      re: conf.MNTH.join('|'),
      fn: function (s, parsedValues) {
        parsedValues.month = lowerCaseMonths.indexOf(s.toLowerCase());
      },
    };
  },
  '%B': function (conf) {
    let lowerCaseMonths = conf.MONTHS.map(lower);

    return {
      re: conf.MONTHS.join('|'),
      fn: function (s, parsedValues) {
        parsedValues.month = lowerCaseMonths.indexOf(s.toLowerCase());
      },
    };
  },
  '%d': function () {
    return {
      re: '[0-2][0-9]|3[01]',
      fn: function (s, parsedValues) {
        parsedValues.date = parseInt(s, 10);
      },
    };
  },
  '%D': function () {
    return {
      re: '3[01]|[12]?\\d',
      fn: function (s, parsedValues) {
        parsedValues.date = parseInt(s, 10);
      },
    };
  },
  '%f': function () {
    return {
      re: '\\d{2}\\.\\d{2}',
      fn: function (s, parsedValues) {
        let i = parseInt(s, 10);
        let f = parseFloat(s);
        parsedValues.second = i;
        parsedValues.millisecond = f * 1000 % 1000;
      },
    };
  },
  '%H': function () {
    return {
      re: '[0-1]\\d|2[0-3]',
      fn: function (s, parsedValues) {
        parsedValues.hour = parseInt(s, 10);
      },
    };
  },
  '%i': function () {
    return {
      re: '1[0-2]|\\d',
      fn: function (s, parsedValues) {
        parsedValues.hour = parseInt(s, 10);
      },
    };
  },
  '%I': function () {
    return {
      re: '0\\d|1[0-2]',
      fn: function (s, parsedValues) {
        parsedValues.hour = parseInt(s, 10);
      },
    };
  },
  '%m': function () {
    return {
      re: '0\\d|1[0-2]',
      fn: function (s, parsedValues) {
        parsedValues.month = parseInt(s, 10) - 1;
      },
    };
  },
  '%M': function () {
    return {
      re: '[0-5]\\d',
      fn: function (s, parsedValues) {
        parsedValues.minute = parseInt(s, 10);
      },
    };
  },
  '%n': function () {
    return {
      re: '1[0-2]|\\d',
      fn: function (s, parsedValues) {
        parsedValues.month = parseInt(s, 10) - 1;
      },
    };
  },
  '%N': function () {
    return {
      re: '[1-5]?\\d',
      fn: function (s, parsedValues) {
        parsedValues.minute = parseInt(s, 10);
      },
    };
  },
  '%p': function (conf) {
    return {
      re: `${conf.PM.replace(/\./g, '\\.')}|${conf.AM.replace(/\./g, '\\.')}`,
      fn: function (s, parsedValues) {
        parsedValues.isPMin12h = conf.PM.toLowerCase() === s.toLowerCase();
      },
    };
  },
  '%s': function () {
    return {
      re: '[1-5]?\\d',
      fn: function (s, parsedValues) {
        parsedValues.second = parseInt(s, 10);
      },
    };
  },
  '%S': function () {
    return {
      re: '[0-5]\\d',
      fn: function (s, parsedValues) {
        parsedValues.second = parseInt(s, 10);
      },
    };
  },
  '%r': function () {
    return {
      re: '\\d{1,3}',
      fn: function (s, parsedValues) {
        parsedValues.millisecond = parseInt(s, 10);
      },
    };
  },
  '%y': function () {
    let thisYear = (new Date()).getFullYear();

    return {
      re: '\\d{2}',
      fn: function (s, parsedValues) {
        let c = thisYear.toString().slice(0, 2);
        parsedValues.year = parseInt(c + s, 10);
      },
    };
  },
  '%Y': function () {
    return {
      re: '\\d{4}',
      fn: function (s, parsedValues) {
        parsedValues.year = parseInt(s, 10);
      },
    };
  },
  '%z': function () {
    return {
      re: '[+-](?1[01]|0\\d)[0-5]\\d|Z',
      fn: function (s, parsedValues) {
        if (s === 'Z') {
          parsedValues.timezone = 0
        }
        else {
          let mult = s.startsWith('-') ? 1 : -1;
          let h = parseInt(s.slice(0, 2), 10);
          let m = parseInt(s.slice(2, 2), 10);
          parsedValues.timezone = mult * (h * 60) + m;
        }
      },
    };
  },
};

/**
 * Parse a date/time string according to a format string
 *
 * The return value is a `Date` object or `null` if the input does not match
 * the format string.
 *
 * The `Date` object is always in the local time zone, but if time zone offset
 * appears in the string, it will be taken into account and the resulting
 * object adjusted accordingly.
 *
 * The format string is an arbitrary string that contains format sequences
 *
 * - `%b` - Short month name (e.g., 'Jan', 'Feb'...).
 * - `%B` - Full month name (e.g., 'January', 'February'...).
 * - `%d` - Zero-padded date (e.g, 02, 31...).
 * - `%D` - Non-zero-padded date (e.g., 2, 31...).
 * - `%H` - Zero-padded hour in 24-hour format (e.g., 8, 13, 0...).
 * - `%i` - Non-zero-padded hour in 12-hour format (e.g., 8, 1, 12...).
 * - `%I` - Zero-padded hour in 12-hour format (e.g., 08, 01, 12...).
 * - `%m` - Zero-padded month (e.g., 01, 02...).
 * - `%M` - Zero-padded minutes (e.g., 01, 12, 59...).
 * - `%n` - Non-zero-padded month (e.g., 1, 2...).
 * - `%N` - Non-zero-padded minutes (e.g., 1, 12, 59).
 * - `%p` - AM/PM (a.m. and p.m.).
 * - `%s` - Non-zero-padded seconds (e.g., 1, 2, 50...).
 * - `%S` - Zero-padded seconds (e.g., 01, 02, 50...).
 * - `%r` - Milliseconds (e.g., 1, 24, 500...).
 * - `%y` - Zero-padded year without the century part (e.g., 01, 13, 99...).
 * - `%Y` - Full year (e.g., 2001, 2013, 2099...).
 * - `%z` - UTC offset in +HHMM or -HHMM format or 'Z' (e.g., +1000, -0200).
 * - `%%` - literal percent character.
 *
 * The `%z` token behaves slightly differently when parsing date and time
 * strings. In addition to formats that strftime outputs, it also supports
 * 'Z', which allows parsing of ISO timestamps.
 *
 * @example
 *
 * let s1 = '2019 Jan 12 4:55 p.m.';
 * let d1 = parse.strptime(s, '%Y %b %D %i:%M %p');
 * // => new Date(2019, 0, 12, 16, 55)
 *
 * // With customized AM/PM
 * let s2 = '18/March/2019 07:22am';
 * let d2 = parse.strptime(s, '%d/%B/%Y %I:%M%p', {
 *   AM: 'am',
 *   PM: 'pm',
 * });
 * // => new Date(2019, 2, 18, 7, 22)
 *
 * @param {string} s Formatted date/time string
 * @param {string} formatString The expected format of the `s` argument
 * @param {object} [config=DEFAULT_CONFIG] Format configuration
 */
export function strptime(s, formatString, config = DEFAULT_CONFIG) {
  // Build the regexp to match format tokens inside format string
  let parseTokens = Object.keys(PARSE_RECIPES).join('|');
  let parseTokenRe = new RegExp(`(${parseTokens}|%%)`, 'g');

  // Prepare the format string for matching
  let rxp = formatString.replace(/\\/, '\\\\');
  REGEXP_CHARS.forEach(function (schr) {
    rxp = rxp.replace(new RegExp('\\' + schr, 'g'), `\\${schr}`);
  });

  // Replace all format tokens inside the format string with the actual regexp
  // that matches each token, and build a regexp string.
  let converters = [];
  rxp = rxp.replace(parseTokenRe, function (_, token) {
    if (token === '%%') {
      return '%';
    }

    // Get the token regexp and parser function
    let {re, fn} = PARSE_RECIPES[token](config);
    converters.push(fn);
    return `(${re})`;
  });

  // Convert the regexp string to a `RegeExp` object.
  rxp = new RegExp(`^${rxp}$`, 'i');

  // Perform the match
  let matches = rxp.exec(s);

  // We consider the parse failed if nothing matched
  if (!matches) {
    return null;
  }

  // Remove the first item from the matches, since we're not interested in it
  matches.shift()

  // The object used to keep track of the parsing
  let parsedValues = {
    year: 0,
    month: 0,
    date: 1,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    isPMin12h: null,
    timezone: null,
  };

  // Iterate parser functions and apply the function to each match
  matches.forEach(function (match, idx) {
    let fn = converters[idx];
    fn(match, parsedValues);
  });

  if (parsedValues.isPMin12h) {
    parsedValues.hour = h12to24(parsedValues.hour, parsedValues.isPMin12h);
  }

  // Construct the `Date` object using the parsedValues object
  let dt = new Date(
    parsedValues.year,
    parsedValues.month,
    parsedValues.date,
    parsedValues.hour,
    parsedValues.minute,
    parsedValues.second,
    parsedValues.millisecond
  );

  if (parsedValues.timezone != null) {
    // Determine the relative offset of the original time to local time of
    // the platform.
    let localOffset = dt.getTimezoneOffset();
    // Shift the time by the difference of timezone and local zone
    let offset = localOffset - parsedValues.timezone
    dt.setMinutes(d.getMinutes() + offset);
  }

  return dt;
};
