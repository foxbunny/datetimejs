/**
 * Calculate date and time differences and query dates and times
 *
 * @module datetimejs.dtdelta
 */

/**
 * Crate an object that represents the time delta
 *
 * The return value has the following keys:
 *
 * - `delta` - relative difference in milliseconds.
 * - `milliseconds` - absolute difference in milliseconds (same as `delta`).
 * - `seconds` - absolute difference rounded to seconds with no decimals.
 * - `minutes` - absolute difference rounded to minutes with no decimals.
 * - `hours` - absolute difference rounded to hours with no decimals.
 * - `days` - absolute difference rounded to days with no decimals.
 * - `composite` - array of values that represents the total absolute
 *   difference (`[days, hours, minutes, seconds, milliseconds]`).
 *
 * Relative difference means the difference between two time points relative
 * one of them. This can be a negative or positive number in milliseconds. All
 * other values (including the `milliseconds` key) are absolute, which means
 * they are always positive, and they are all rounded up.
 *
 * The composite difference is an array containing the total difference in
 * days, hours, minutes, seconds, and milliseconds.
 *
 * Main difference between the composite values and the individual keys, is
 * that each individual key *is* the total absolute difference expressed in
 * given units, while the values in the composite add up to the total.
 *
 * @example
 *
 * let dlt = dtdelta.createDelta(3000000);
 *
 * dlt.delta === 300000;
 * dtl.days === 1;
 * dlt.hours === 1;
 * dlt.minutes === 5;
 * dlt.seconds === 300;
 * dlt.milliseconds === 300000;
 *
 * dlt.composite; // => [0, 0, 5, 0, 0]
 *
 * @param {number} delta Time difference in milliseconds
 */
export function createDelta(delta) {
  let absDelta = Math.abs(delta)

  // For brevity we use the `~~` operator to `Math.floor()` numbers. The
  // expression `x - ~~x` therefore gives us the fractional part of a number.
  let days = absDelta / 86400000;
  let hrs = (days - ~~days) * 24;
  let mins = (hrs - ~~hrs) * 60;
  let secs = (mins - ~~mins) * 60;
  let msecs = (secs - ~~secs) * 1000;

  return {
    delta,
    milliseconds: absDelta,
    seconds: Math.ceil(absDelta / 1000),
    minutes: Math.ceil(absDelta / 60000),
    hours: Math.ceil(absDelta / 3600000),
    days: Math.ceil(days),
    composite: [
      Math.floor(days),
      Math.floor(hrs),
      Math.floor(mins),
      Math.floor(secs),
      Math.round(msecs),
    ],
  };
}

/**
 * Calculates the difference between two `Date` objects
 *
 * The return value is a delta object (see `createDelta`). The relative delta
 * between `d1` and `d2` is calculated relative to `d1`.
 *
 * If the second date is omitted, then it defaults to current time (`new
 * Date()`). This variation tells us how long ago `d1` was (if it's in the
 * past).
 *
 * @example
 *
 * let d1 = new Date(2019, 4, 12, 14, 50);
 * let d2 = new Date(2019, 4, 15, 12, 22);
 *
 * let dlt = dtdelta.delta(d1, d2);
 *
 * dtl.delta === 286320000;
 * dtl.days === 4;
 *
 * dlt.composite; // => [3, 7, 32, 0, 0]
 *
 * @param {Date} d1 Reference date object
 * @param {Date} [d2 = new Date] Subject date object
 */
export function delta(d1, d2) {
  if (typeof d2 === 'undefined') {
    d2 = new Date();
  }

  return createDelta(d2 - d1);
};

/**
 * Return true if year of a `Date` object is leap
 *
 * @example
 *
 * dtdelta.isLeapYear(new Date(2000, 0, 1)); // => false
 * dtdelta.isLeapYear(new Date(2004, 0, 1)); // => true
 * dtdelta.isLeapYear(new Date(2019, 0, 1)); // => false
 *
 * @param {Date} dt The input date
 */
export function isLeapYear(dt) {
  const year = dt.getFullYear();
  return year % 4 === 0 && year % 100 !== 0;
};
