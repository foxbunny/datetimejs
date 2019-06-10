/**
 * Format configuration.
 *
 * @module datetimejs.config
 */

/**
 * Default configuration object
 *
 * This object contains the default (global) configuration for formatting,
 * parsing, and manipulating dates and times.
 *
 * The `updateDefaultConfig()` function's documentation has more information
 * about the contents of this object.
 */
export const DEFAULT_CONFIG = {
  // Full month names
  MONTHS: [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ],

  // Abbreviated month names.
  MNTH: [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ],

  // Week day names, starting with Sunday.
  DAYS: [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ],

  // Abbreviated week day names.
  DY: [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ],

  // Ante-meridiem shorthand
  AM: 'a.m.',

  // Post-meridiem shorthand
  PM: 'p.m.',

  // Day the week starts on. 0 is Sunday, 1 is Monday, and so on.
  WEEK_START: 0,

  // ISO format expressed in stftime format
  ISO_FORMAT: '%Y-%m-%dT%H:%M:%f',
};

/**
 * Update the default configuration
 *
 * This function takes an object with one or more keys from the
 * `DEFAULT_CONFIG`, and updates the `DEFAULT_CONFIG` globally. The
 * configuration added using this function applies to this package from the
 * moment this function is invoked.
 *
 * The keys that can be used in the custom configuration are:
 *
 * - `MONTHS` - array of strings - full month names.
 * - `MNTH` - array of strings - abbreviated month names (usually 3-letter).
 * - `DAYS` - array of strings - names of the week days (starting with Sunday).
 * - `DY` - array of strings - abbreviated names of the week days (usually
 *   3-letter).
 * - `AM` - string - ante-meridiem abbreviation.
 * - `PM` - string - post-meridiem abbreviation.
 * - `WEEKSTART` - number - the starting day of the week (0 for Sunday, 1 for
 *   Monday, through to 6 for Saturday).
 * - `ISO_FORMAT` - string - format string for ISO date and time.
 *
 * Using illegal keys will cause an exception.
 *
 * This function can be used to globally translate the strings. If you use a
 * language other than English, but only use one language, then setting the
 * options using this function is the best approach. Functions like
 * `format.strftime()` and `parse.strptime()` also accept a configuraiton
 * which can be used to override the configuration on per-invocation basis.
 * This is a better approach when you have multiple languages to deal with.
 *
 * @example
 *
 * config.updateDefaultConfig({
 *   AM: 'преп.',
 *   PM: 'послеп.',
 *   MONTHS: [
 *     'јануар',
 *     'фебруар',
 *     'март',
 *     'април',
 *     'мај',
 *     'јун',
 *     'јул',
 *     'август',
 *     'септембар',
 *     'октобар',
 *     'новембар',
 *     'децембар',
 *   ],
 * });
 *
 * @param {object} config Object with configuration keys that override the
 * defaults
 */
export function updateDefaultConfig(config) {
  for (let key in config) {
    if (DEFAULT_CONFIG.hasOwnProperty(key)) {
      DEFAULT_CONFIG[key] = config[key];
    }
    else {
      throw Error(`Configuraiton ${key} is invalid, expecting one of ${Object.keys(DEFAULT_CONFIG).join(', ')}`);
    }
  }
};

