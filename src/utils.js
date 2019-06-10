/**
 * Utility functions
 *
 * @module datetimejs.utils
 * @ignore
 */

/**
 * Lower-cases a string
 *
 * @param {string} s Input string
 */
export function lower(s) {
  return s.toLowerCase();
}

/**
 * Zero-pad a number
 *
 * @param {number} n The number to pad
 * @param {number} digits The total number of digits, defualts to 3
 * @param {number|boolean} tail Number of digits to use when padding the tail,
 * or `false` to treat both the tail and the fractional point as part of the
 * digits, defaults to `false`
 */
export function zeroPad(n, digits = 3, tail = false) {
  if (tail === false) {
    return ((new Array(digits)).join('0') + n).slice(-digits);
  }

  else {
    // Split the number into head and tail
    let [hd, tl = '0'] = n.toString().split('.');
    if (tail === 0) {
      // Strip out the tail (basically floor() the number)
      return zeroPad(hd, digits - tail, false);
    } else {
      // Pad the head side
      hd = zeroPad(hd, digits - 1 - tail, false);
      // Pad the tail side
      tl = zeroPad(tl.split('').reverse().join(''), tail, false);
      tl = tl.split('').reverse().join('');
      // Join the head and tail together
      return [hd, tl].join('.');
    }
  }
};

/**
 * Fits the number inside a range
 *
 * For numbers `n` and `max`, returns a number that is always within a range
 * between either `0` and `max - 1` or `1` and `max`. The number is calculated
 * using a modulo, where modulo 0 is treated as 0 if `zeroIndex` is a truthy
 * value, and `max` otherwise.
 *
 * For example, let's say we have an hour in 24-hour format, like 15. We want
 * to get 3, which is 3 PM. We would call cycle like this:
 *
 *     cycle(15, 12);
 *
 * @param {number} n Number for which to calculate the output
 * @param {number} max The maximum value (interpretation depends on `zeroPad`)
 * @param {number} zeroIndex Whether to treat the range as `0 ~ max - 1` or
 * `1 ~ max`
 */
export function cycle(n, max, zeroIndex = false) {
  return n % max || (zeroIndex ? 0 : max);
};

/**
 * Convert a 12-hour format hour to 24-hour
 *
 * @param {number} h The number of hours
 * @param {boolean} pm Whether hours are in PM, defaults to `false`
 */
export function h12to24(h, pm = false) {
  h = cycle(h, 12, true);
  if (pm) {
    return h + 12;
  }
  return h;
};

