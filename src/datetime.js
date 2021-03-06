/**
 * `Date` object creation and manipulation functions
 *
 * @module datetimejs.datetime
 */

import {DEFAULT_CONFIG} from './config';

/**
 * Clone a `Date` object
 *
 * Creates a copy of a `Date` object that points to the exact same time.
 *
 * @example
 *
 * let dt = new Date(2019, 8, 1, 14, 2);
 * let dt1 = datetime.clone(dt);
 *
 * dt.getTime() === dt1.getTime(); // true
 * dt === dt1; // false
 *
 * @param {Date} dt `Date` object to clone
 */
export function clone(dt) {
  return new Date(dt.getTime());
};

/**
 * Create a clone of a `Date` object with specified number of days added
 *
 * As the days are added, the date object is correctly adjusted for month and
 * year. For example, adding 31 days to a Date object will result in a date
 * object that is also one or two months ahead as well.
 *
 * Negative number of days can also be added in which case days are shifted
 * bakcwards.
 *
 * It is not recommended to use this method to add months or years to a date
 * object. Adding different parts of the date has different edge cases.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15);
 *
 * let d1 = datetime.addDays(d, 4); // => new Date(2019, 4, 19)
 * let d2 = datetime.addDays(d, -4); // => new Date(2019, 4, 11)
 *
 * // Cross the month boundary
 * let d3 = datetime.addDays(d, 20); // => new Date(2019, 5, 4);
 *
 * @param {Date} dt The input date
 * @param {number} days The number of days to add
 */
export function addDays(dt, days) {
  dt = clone(dt);
  dt.setDate(dt.getDate() + days);
  return dt;
};

/**
 * Create a clone of a `Date` object with a specified number of months added
 *
 * As the months are added, the date object is correctly adjusted for year and
 * date. For instance, adding one month to a December date object will result
 * in year shifting by one as well.
 *
 * Negative number of months can also be added, in which case the date is
 * shifted backwards.
 *
 * **CAVEAT:** This method will have unexpected behavior when the date of the
 * `Date` object is outside the range of dates in the target month.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15);
 *
 * let d1 = datetime.addMonths(d, 4); // => new Date(2019, 8, 15);
 * let d2 = datetime.addMonths(d, -2); // => new Date(2019, 2, 15);
 *
 * // Edge case demonstration (see caveat in the description)
 * let d3 = new Date(2019, 0, 31);
 * let d4 = datetime.addMonths(d3, 1); // => new Date(2019, 2, 3);
 *
 * @param {Date} dt The input date
 * @param {number} months The number of months to add
 */
export function addMonths(dt, months) {
  dt = clone(dt);
  dt.setMonth(dt.getMonth() + months);
  return dt;
};

/**
 * Create a clone of a `Date` object with a specified number of years added
 *
 * When the years are added, the date object is adjusted for possible changes
 * in the date. For example, if we are on Feb 29 of a leap year, and we add one
 * year, we end up on Mar 1 of the next year.
 *
 * Negative number of years can be added, and then the object is shifted
 * backwards.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15);
 *
 * let d1 = datetime.addYears(d, 3); // => new Date(2022, 4, 15);
 * let d2 = datetime.addYears(d, -1); // => new Date(2018, 4, 15);
 *
 * @param {Date} dt The input date
 * @param {number} years The number of years to add
 */
export function addYears(dt, years) {
  dt = clone(dt);
  dt.setFullYear(dt.getFullYear() + years);
  return dt;
};

/**
 * Create a clone of a `Date` object with time shifted by the specified delta
 *
 * The delta object does not have to be complete. As long as it has a numeric
 * `delta` property, it will work.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15, 12, 23);
 *
 * // Add 5 minutes
 * let dlt1 = dtdelta.createDelta(5 * 60 * 1000);
 * let dt1 = dateitme.addDelta(d, dlt1); // => new Date(2019, 4, 15, 12, 28)
 *
 * // Subtract 10 hours
 * let dlt2 = dtdelta.createDelta(10 * 60 * 60 * 1000);
 * let dt2 = datetime.addDelta(d, dlt2); // => new Date(2019, 4, 15, 2, 23)
 *
 * // We can cheat and use any object with `delta` property
 * let dlt3 = {delta: 10800000} // 3 hours
 * let dt3 = datetime.addDelta(d, dlt3); // => new Date(2019, 4, 14, 15, 23)
 *
 * @param {Date} dt The input date
 * @param {object} delta The delta object (e.g., created by `createDelta()`)
 */
export function addDelta(dt, {delta}) {
  dt = clone(dt);
  dt.setTime(dt.getTime() + delta);
  return dt;
};

/**
 * Create a clone of a `Date` object with the time reset to 0 (local time)
 *
 * **TIP:** JavaScript does not have "pure" date objects. The `Date` object,
 * despite its name, also contains the time. Furthermore, it is always in local
 * time.  Because of this, when we are dealing with date alone, this is not the
 * ideal object to use. It is recommended to create your own class for dates,
 * or use strings in a specific format.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15, 12, 23);
 * let d1 = dateitme.resetTime(d); // => new Date(2019, 4, 15, 0, 0)
 *
 * @param {Date} dt The input date
 */
export function resetTime(dt) {
  dt = clone(dt);
  dt.setHours(0);
  dt.setMinutes(0);
  dt.setSeconds(0);
  dt.setMilliseconds(0);
  return dt;
};

/**
 * Create a clone of a `Date` object with date reset to the start of the week
 *
 * The first day of the week is taken from the configuration object, which
 * defaults to `DEFAULT_CONFIG`. The `WEEK_START` configuration option is a
 * number between 0 and 6, where 0 is Sunday, 1 is Monday, and so on, through 6
 * as Saturday.
 *
 * @example
 *
 * let d = new Date(2019, 4, 15);
 *
 * // Reset to previous Sunday (default)
 * let d1 = datetime.resetWeek(d); // => new Date(2019, 4, 12)
 *
 * // Use Monday as custom week start
 * let conf = {WEEK_START: 1};
 * let d2 = datetime.resetWeek(d, conf); // => new Date(2019, 4, 13)
 *
 * @param {Date} dt The input date
 * @param {object} [config=DEFAULT_CONFIG] Optional configuration object
 */
export function resetWeek(dt, config = {}) {
  config = {...DEFAULT_CONFIG, ...config};

  let firstDay = config.WEEK_START;
  let weekDay = dt.getDay();

  if (weekDay === firstDay) {
    return clone(dt);
  }

  if (weekDay > firstDay) {
    return addDays(dt, firstDay - weekDay);
  }

  return addDays(dt, firstDay - weekDay - 7);
};

