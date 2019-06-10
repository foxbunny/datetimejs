/**
 * Date and time formatting
 *
 * @module datetimejs.format
 */

import {zeroPad, cycle} from './utils';
import {DEFAULT_CONFIG} from './config';

// Number of milliseconds in a day
export const DAY_MS = 86400000;

/**
 * Functions for formatting Date objects
 *
 * This object maps format tokens to formatting functions. This object is used
 * by `strftime()` to perform the formatting. It can also be manipulated to
 * modify and/or enhance the way `stftime()` formats date and time.
 *
 * To add a new token, we first decide on the actual token we want to use, or
 * whther we want to override an existing one. Then we assign a format function
 * to that key.
 *
 * The format functions take two arguments, the `Date` object to format, and
 * the configuration object.
 *
 * @example
 *
 * format.FORMAT_TOKENS['%R'] = function romanYear(dt, conf) {
 *   // Do something with `dt` and/or `conf` and return a string...
 * };
 */
export let FORMAT_TOKENS = {
  // Shorthand day-of-week name
  '%a': function (dt, conf) {
    return conf.DY[dt.getDay()];
  },

  // Full day-of-week name
  '%A': function (dt, conf) {
    return conf.DAYS[dt.getDay()];
  },

  // Shorthand month name
  '%b': function (dt, conf) {
    return conf.MNTH[dt.getMonth()];
  },

  // Full month name
  '%B': function (dt, conf) {
    return conf.MONTHS[dt.getMonth()];
  },

  // Locale-formatted date and time (dependent on browser/platform/device),
  // here added for compatibility reasons.
  '%c': function (dt, conf) {
    return dt.toLocaleString();
  },

  // Zero-padded date (day of month)
  '%d': function (dt) {
    return zeroPad(dt.getDate(), 2);
  },

  // Non-zero-padded date (day of month)
  '%D': function (dt) {
    return '' + dt.getDate();
  },

  // Zero-padded seconds with decimal part
  '%f': function (dt) {
    let s = dt.getSeconds();
    let m = dt.getMilliseconds();
    let fs = Math.round((s + m / 1000) * 100) / 100;
    return zeroPad(fs, 5, 2);
  },

  // Zero-padded hour in 24-hour format
  '%H': function (dt) {
    return zeroPad(dt.getHours(), 2);
  },

  // * Non-zero-padded hour in 12-hour format
  '%i': function (dt) {
    return cycle(dt.getHours(), 12);
  },

  // Zero-padded hour in 12-hour format
  '%I': function (dt) {
    return zeroPad(cycle(dt.getHours(), 12), 2);
  },

  // Zero-padded day of year
  '%j': function (dt) {
    let firstOfYear = new Date(dt.getFullYear(), 0, 1);
    return zeroPad(Math.ceil((dt - firstOfYear) / DAY_MS), 3);
  },

  // Zero-padded numeric month
  '%m': function (dt) {
    return zeroPad(dt.getMonth() + 1, 2);
  },

  // Zero-padded minutes
  '%M': function (dt) {
    return zeroPad(dt.getMinutes(), 2);
  },

  // Non-zero-padded numeric month
  '%n': function (dt) {
    return `${dt.getMonth() + 1}`;
  },

  // Non-zero-padded minutes
  '%N': function (dt) {
    return '' + dt.getMinutes();
  },

  // am/pm
  '%p': function (dt, conf) {
    let h = dt.getHours();
    return (0 <= h && h < 12) ? conf.AM : conf.PM;
  },

  // Non-zero-padded seconds
  '%s': function (dt) {
    return '' + dt.getSeconds();
  },

  // Zero-padded seconds
  '%S': function (dt) {
    return zeroPad(dt.getSeconds(), 2);
  },

  // Milliseconds
  '%r': function (dt) {
    return '' + dt.getMilliseconds();
  },

  // Numeric day of week (0 == Sunday)
  '%w': function (dt) {
    return '' + dt.getDay();
  },

  // Last two digits of the year
  '%y': function (dt) {
    return ('' + dt.getFullYear()).slice(2);
  },

  // Full year
  '%Y': function (dt) {
    return '' + dt.getFullYear();
  },

  // Locale-formatted date (without time)
  '%x': function (dt) {
    return dt.toLocaleDateString();
  },

  // Locale-formatted time
  '%X': function (dt) {
    return dt.toLocaleTimeString();
  },

  // Timezone in +HHMM or -HHMM format
  '%z': function (dt) {
    let prefix = dt.getTimezoneOffset() <= 0 ? '+' : '-';
    let tz = Math.abs(dt.getTimezoneOffset());
    return `${prefix}${zeroPad(Math.floor(tz / 60), 2)}${zeroPad(tz % 60, 2)}`;
  },

  // Literal percent character
  '%%': function (dt) {
    return '%';
  },

  // The following functions are unsupported

  '%U': function (dt) {
    return '';
  },

  '%Z': function (dt) {
    return '';
  },
};

/**
 * Format a `Date` object according to a format string
 *
 * The formatting uses strftime-compatible syntax with follwing tokens:
 *
 * - `%a` - short week day name (e.g. 'Sun', 'Mon'...).
 * - `%A` - long week day name (e.g., 'Sunday', 'Monday'...).
 * - `%b` - short month name (e.g., 'Jan', 'Feb'...).
 * - `%B` - full month name (e.g., 'January', 'February'...).
 * - `%c` - locale-formatted date and time (platform-dependent).
 * - `%d` - zero-padded date (e.g, 02, 31...).
 * - `%D` - non-zero-padded date (e.g., 2, 31...).
 * - `%f` - zero-padded decimal seconds (e.g., 04.23, 23.50).
 * - `%H` - zero-padded hour in 24-hour format (e.g., 8, 13, 0...).
 * - `%i` - non-zero-padded hour in 12-hour format (e.g., 8, 1, 12...).
 * - `%I` - zero-padded hour in 12-hour format (e.g., 08, 01, 12...).
 * - `%j` - zero-padded day of year (e.g., 002, 145, 364...).
 * - `%m` - zero-padded month (e.g., 01, 02...).
 * - `%M` - zero-padded minutes (e.g., 01, 12, 59...).
 * - `%n` - non-zero-padded month (e.g., 1, 2...).
 * - `%N` - non-zero-padded minutes (e.g., 1, 12, 59).
 * - `%p` - aM/PM (a.m. and p.m.).
 * - `%s` - non-zero-padded seconds (e.g., 1, 2, 50...).
 * - `%S` - zero-padded seconds (e.g., 01, 02, 50...).
 * - `%r` - milliseconds (e.g., 1, 24, 500...).
 * - `%w` - numeric week day where 0 is Sunday (e.g., 0, 1...).
 * - `%y` - zero-padded year without the century part (e.g., 01, 13, 99...).
 * - `%Y` - full year (e.g., 2001, 2013, 2099...).
 * - `%z` - timezone in +HHMM or -HHMM format (e.g., +0200, -0530).
 * - `%x` - locale-formatted date (platform dependent).
 * - `%X` - locale-formatted time (platform dependent).
 * - `%%` - literal percent character %.
 *
 * Any characters that are not part of the %-something sequence are used as is
 * in the final output.
 *
 * The third and optional argument is the format configuration object. This
 * object is used to customize the human-readable strings used in the output,
 * such as month names and similar. Please refer to
 * `config.updateDefaultConfig()` function's documentation for information on
 * what this object may contain.
 *
 * @example
 *
 * let d = new Date(2009, 4, 1, 12, 33);
 *
 * // US date format
 * strftime(d, '%n/%D/%Y'); // '5/1/2019'
 *
 * // Using non-formatting characters
 * strftime(d, 'On %b %D at %i:%M %p'); // 'On May 1 at 12:33 p.m.'
 *
 * // With 24-hour time
 * strftime(d, '%Y-%m-%d %H:%M'); // '2019-05-01 12:33'
 *
 * // With localized short month names (this configuration is only used for
 * // this particular call, and the global defaults are not modified)
 * const srMnth = ['јан', 'феб', 'мар', 'апр', 'мај', 'јун', 'јул', 'авг',
 *   'сеп', 'окт', 'нов', 'дец'];
 * strftime(d, '%D. %b %Y.', {MNTH: srMnth}); // '1. мај 2019.'
 *
 * @param {Date} dt The `Date` object to format
 * @param {string} formatString The format of the output
 * @param {object} [config={}] Format configuration
 */
export function strftime(d, formatString, config = {}) {
  config = {...DEFAULT_CONFIG, ...config};

  // Create a regexp that matches any of the formatting tokens
  const formatTokens = Object.keys(FORMAT_TOKENS).join('|') + '|%%';
  const formatTokenRe = new RegExp(`(${formatTokens})`, 'g');

  // Replace any encountered tokens with a result of calling a matching format
  // function
  return formatString.replace(formatTokenRe, function (_, token) {
    if (token == '%%') {
      return '%';
    }
    if (token in FORMAT_TOKENS) {
      return FORMAT_TOKENS[token](d, config);
    }
    return token;
  });
};


