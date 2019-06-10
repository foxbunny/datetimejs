import {advanceTo} from 'jest-date-mock';
import {createDelta, delta, isLeapYear} from '../src/dtdelta';
import * as dtdelta from '../src/dtdelta';

describe('createDelta', function () {

  it('should 0 if relative diff is 0', function() {
    let d = createDelta(0);
    expect(d.delta).toBe(0);
  });

  it('should have delta 10 if input is 10', function() {
    let d = createDelta(10);
    expect(d.delta).toBe(10);
  });

  it('should have negative delta if input is negative', function() {
    let d = createDelta(-10);
    expect(d.delta).toBe(-10);
  });

  it('returns absolute delta in milliseconds', function() {
    let d = createDelta(10);
    expect(d.days).toBe(1);
    expect(d.hours).toBe(1);
    expect(d.minutes).toBe(1);
    expect(d.seconds).toBe(1);
    expect(d.milliseconds).toBe(10);
  });

  it('returns absolute delta in seconds', function() {
    let d = createDelta(2000);
    expect(d.days).toBe(1);
    expect(d.hours).toBe(1);
    expect(d.minutes).toBe(1);
    expect(d.seconds).toBe(2);
    expect(d.milliseconds).toBe(2000);
  });

  it('rounds delta in seconds up', function() {
    let d = createDelta(2001);
    expect(d.seconds).toBe(3);
  });

  it('returns delta in minutes', function () {
    let d = createDelta(120000);
    expect(d.days).toBe(1);
    expect(d.hours).toBe(1);
    expect(d.minutes).toBe(2);
    expect(d.seconds).toBe(120);
    expect(d.milliseconds).toBe(120000);
  });

  it('rounds delta in minutes up', function() {
    let d = createDelta(120001);
    expect(d.minutes).toBe(3);
  });

  it('returns absolute delta in hours', function() {
    let d = createDelta(3600000);
    expect(d.days).toBe(1);
    expect(d.hours).toBe(1);
    expect(d.minutes).toBe(60);
    expect(d.seconds).toBe(3600);
    expect(d.milliseconds).toBe(3600000);
  });

  it('rounds delta in hours up', function() {
    let d = createDelta(3600001);
    expect(d.hours).toBe(2);
  });

  it('returns absolute delta in days', function() {
    let d = createDelta(172800000);
    expect(d.days).toBe(2);
    expect(d.hours).toBe(48);
    expect(d.minutes).toBe(2880);
    expect(d.minutes).toBe(2880);
    expect(d.seconds).toBe(172800);
    expect(d.milliseconds).toBe(172800000);
  });

  it('rounds delta in days up', function() {
    let d = createDelta(172800001);
    expect(d.days).toBe(3);
  });

  it('should give a composite delta', function() {
    let d = createDelta(172800000);
    expect(d.composite).toEqual([2, 0, 0, 0, 0]);
  });

  it('should give a composite delta with all values', function() {
    let d = createDelta(176461001);
    expect(d.composite).toEqual([2, 1, 1, 1, 1])
  });

});

describe('delta', function() {
  it('should 0 if dates are equal', function() {
    let d1, d2;
    d1 = d2 = new Date(2019, 8, 1, 12, 0, 0, 0);
    let d = delta(d1, d2);
    expect(d.delta).toBe(0);
  });

  it('should use a correct relative delta', function () {
    let d1 = new Date(2019, 8, 1, 12, 0, 0, 0);
    let d2 = new Date(2019, 8, 1, 12, 0, 5, 50);

    let d = delta(d1, d2);
    expect(d.delta).toBe(5050);

    d = delta(d2, d1);
    expect(d.delta).toBe(-5050);
  });

  it('should use current date if only one argument', function () {
    let d1 = new Date(2019, 8, 1, 12, 0, 0, 0);
    advanceTo(d1.getTime() + 2500)

    let d = delta(d1);
    expect(d.delta).toBe(2500);
  });

});

describe('isLeapYear', function () {

  it('should return true for leap year', function () {
    expect(isLeapYear(new Date(2008, 0, 1))).toBe(true);
    expect(isLeapYear(new Date(2004, 0, 1))).toBe(true);
  });

  it('should return false for centuries', function () {
    expect(isLeapYear(new Date(2000, 0, 1))).toBe(false);
    expect(isLeapYear(new Date(2100, 0, 1))).toBe(false);
  });

  it('should return false for non-leap years', function () {
    expect(isLeapYear(new Date(2003, 0, 1))).toBe(false);
    expect(isLeapYear(new Date(2010, 0, 1))).toBe(false);
  });

});
