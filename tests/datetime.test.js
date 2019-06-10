import {
  clone,
  addDays,
  addMonths,
  addYears,
  addDelta,
  resetTime,
  resetWeek,
  resetMonth,
  today,
} from '../src/datetime';

describe('clone', function () {

  let d = new Date(2019, 8, 1);

  it('should create identical version of date object', function() {
    let d1 = clone(d);
    expect(d1.getTime()).toBe(d.getTime());
  });

  it('should create distinct instances', function() {
    let d1 = clone(d);
    expect(d1).not.toBe(d);
  });

});

describe('addDays', function() {
  let d;

  beforeEach(function () {
    d = new Date(2019, 8, 1);
  });

  it('should add one day to date if passed date and 1', function() {
    d = addDays(d, 1);
    expect(d.getDate()).toBe(2);
  });

  it('should go back 1 day if passed date and -1', function() {
    d = addDays(d, -1);
    expect(d.getDate()).toBe(31);
    expect(d.getMonth()).toBe(7);
  });

  it('should change the year if necessary', function() {
    var d;
    d = new Date(2019, 11, 31);
    d = addDays(d, 1);
    expect(d.getDate()).toBe(1);
    expect(d.getMonth()).toBe(0);
    expect(d.getFullYear()).toBe(2020);
  });

});


describe('addMonths', function() {
  let d;

  beforeEach(function () {
    d = new Date(2019, 8, 1);
  });

  it('should add one month if passed a date and 1', function() {
    d = addMonths(d, 1);
    expect(d.getMonth()).toBe(9);
  });

  it('should go back one month if passed -1', function() {
    d = addMonths(d, -1);
    expect(d.getMonth()).toBe(7);
  });

  it('should change years if we add past a year boundary', function() {
    d = addMonths(d, 4);
    expect(d.getMonth()).toBe(0);
    expect(d.getFullYear()).toBe(2020);
  });

  it('should have unavoidable edge case with date shift', function () {
    d = new Date(2019, 0, 31);
    d = addMonths(d, 1);
    expect(d.getMonth()).toBe(2);
    expect(d.getDate()).toBe(3);
  });

});

describe('addYears', function() {

  it('should add a year if passed 1', function() {
    var d;
    d = new Date(2019, 0, 1);
    d = addYears(d, 1);
    expect(d.getFullYear()).toBe(2020);
  });

  it('should go back in time if passed -1', function() {
    var d;
    d = new Date(2019, 0, 1);
    d = addYears(d, -1);
    expect(d.getFullYear()).toBe(2018);
  });

  it('should go to to next date on leap year', function() {
    var d;
    d = new Date(2018, 1, 29);
    d = addYears(d, 1);
    expect(d.getDate()).toBe(1);
    expect(d.getMonth()).toBe(2);
    expect(d.getFullYear()).toBe(2019);
  });

});

describe('addDelta', function () {

  it('should add a delta object to a date object', function () {
    let dt = new Date(2019, 8, 1, 15, 22, 0, 0);
    let d = {delta: 2000};
    let dt1 = addDelta(dt, d);
    expect(dt1.getMinutes()).toBe(22);
    expect(dt1.getSeconds()).toBe(2);
  });

  it('should use negative delta', function () {
    let dt = new Date(2019, 8, 1, 15, 22, 0, 0);
    let d = {delta: -2000};
    let dt1 = addDelta(dt, d);
    expect(dt1.getMinutes()).toBe(21);
    expect(dt1.getSeconds()).toBe(58);
  });

});

describe('resetTime', function() {

  it('should reset the time to 0', function() {
    let d = new Date(2019, 8, 1, 15, 22, 59, 333);
    d = resetTime(d);
    expect(d.getHours()).toBe(0);
    expect(d.getMinutes()).toBe(0);
    expect(d.getSeconds()).toBe(0);
    expect(d.getMilliseconds()).toBe(0);
  });

});

describe('resetWeek', function () {

  it('should reset the time to the first day of the week', function () {
    let d = new Date(2019, 5, 8, 15, 22, 59, 333); // Sat
    d = resetWeek(d); // Sun
    expect(d.getFullYear()).toBe(2019);
    expect(d.getMonth()).toBe(5);
    expect(d.getDate()).toBe(2);
  });

  it('should leave the date as is if already start of week', function () {
    let d = new Date(2019, 5, 9, 15, 22, 59, 333); // Sun
    d = resetWeek(d); // Sun
    expect(d.getFullYear()).toBe(2019);
    expect(d.getMonth()).toBe(5);
    expect(d.getDate()).toBe(9);
  });

  it('should reset to a custom week start if specified', function () {
    let d = new Date(2019, 5, 9, 15, 22, 59, 333); // Sun
    d = resetWeek(d, {WEEK_START: 1}); // Mon
    expect(d.getFullYear()).toBe(2019);
    expect(d.getMonth()).toBe(5);
    expect(d.getDate()).toBe(3);
  });

  it('should keep the time as is', function () {
    let d = new Date(2019, 5, 8, 15, 22, 59, 333);
    d = resetWeek(d);
    expect(d.getHours()).toBe(15);
  });

});

