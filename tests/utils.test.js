import {zeroPad, cycle, h12to24} from '../src/utils';

describe('zeroPad', function() {

  it('should generate total of 4 digits when called with 4', function() {
    let i = 10;
    let s = zeroPad(i, 4);
    expect(s.length).toBe(4);
  });

  it('should truncates numbers that are too long', function() {
    let i = 10;
    let s = zeroPad(i, 1);
    expect(s).toBe('0');
  });

  it('should pad floats normally unless tailed with 0', function() {
    let f = 2.5;
    let s = zeroPad(f, 5);
    expect(s).toEqual('002.5');
  });

  it('should floor the float if tailed with 0', function() {
    let f = 2.5;
    let s = zeroPad(f, 5, 0);
    expect(s).toBe('00002');
  });

  it('should account for floating digits if told to tail', function() {
    let f = 2.5;
    let s = zeroPad(f, 5, 2);
    expect(s).toBe('02.50');
  });

  it('should handle a 0 normally', function() {
    expect(zeroPad(0, 5, 2)).toBe('00.00');
  });

});

describe('cycle', function () {

  it('should return the number that fits a rage', function () {
    expect(cycle(16, 15)).toBe(1);
  });

  it('should return the number as is if it already fits', function () {
    expect(cycle(15, 15)).toBe(15);
  });

  it('should treat number as zero-indexed when told to', function () {
    expect(cycle(15, 15, true)).toBe(0);
  });

  it('should treat 0 as max normally', function () {
    expect(cycle(0, 15)).toBe(15);
  });

  it('should treat 0 as 0 if zero-indexed', function () {
    expect(cycle(0, 15, true)).toBe(0);
  });

});

describe('h12to24', function () {

  it('should correctly convert to 24-hour format', function() {
    expect(h12to24(3)).toBe(3);
    expect(h12to24(5, true)).toBe(17);
  });

  it('should handle 12 hours correctly', function () {
    expect(h12to24(12)).toBe(0);
    expect(h12to24(12, true)).toBe(12);
  });

});
