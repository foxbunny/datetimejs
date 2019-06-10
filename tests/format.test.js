import {strftime} from '../src/format';

describe('strftime', function() {
  let d, d1;

  beforeEach(function () {
    d = new Date(2013, 8, 1, 18, 7, 8, 200);
    d1 = new Date(2013, 8, 1, 8, 7, 8, 200);
  });

  it('should return the short week day name', function() {
    expect(strftime(d, '%a')).toBe('Sun');
  });

  it('should return the long week day name', function() {
    expect(strftime(d, '%A')).toBe('Sunday');
  });

  it('should return the short month name', function() {
    expect(strftime(d, '%b')).toBe('Sep');
  });

  it('should return the long month name', function() {
    expect(strftime(d, '%B')).toBe('September');
  });

  it('should return the zero-padded date', function() {
    expect(strftime(d, '%d')).toBe('01');
  });

  it('should return the non-padded date', function() {
    expect(strftime(d, '%D')).toBe('1');
  });

  it('should return zero-padded seconds with fraction', function() {
    expect(strftime(d, '%f')).toBe('08.20');
  });

  it('should return zero-padded hours in 24-hour format', function() {
    expect(strftime(d, '%H')).toBe('18');
  });

  it('should return non-padded hours in 12-hour format', function() {
    expect(strftime(d, '%i')).toBe('6');
  });

  it('should return zero-padded hours in 12-hour format', function() {
    expect(strftime(d, '%I')).toBe('06');
  });

  it('should return zer-padded day of year', function() {
    expect(strftime(d, '%j')).toBe('244');
  });

  it('should return zero-padded numeric month', function() {
    expect(strftime(d, '%m')).toBe('09');
  });

  it('should return zero-padded minutes', function() {
    expect(strftime(d, '%M')).toBe('07');
  });

  it('should return non-padded month', function() {
    expect(strftime(d, '%n')).toBe('9');
  });

  it('should return non-padded minutes', function() {
    expect(strftime(d, '%N')).toBe('7');
  });

  it('should return PM', function() {
    expect(strftime(d, '%p')).toBe('p.m.');
  });

  it('should return AM', function() {
    d.setHours(9);
    expect(strftime(d, '%p')).toBe('a.m.');
  });

  it('should return non-padded seconds', function() {
    expect(strftime(d, '%s')).toBe('8');
  });

  it('should return padded seconds', function() {
    expect(strftime(d, '%S')).toBe('08');
  });

  it('should return miliseconds', function() {
    expect(strftime(d, '%r')).toBe('200');
  });

  it('should return numeric weed day', function() {
    expect(strftime(d, '%w')).toBe('0');
  });

  it('should return year without century', function() {
    expect(strftime(d, '%y')).toBe('13');
  });

  it('should return full year', function() {
    expect(strftime(d, '%Y')).toBe('2013');
  });

  it('should return timezone', function() {
    d.getTimezoneOffset = function() {
      return -120;
    };
    expect(strftime(d, '%z')).toBe('+0200');
    d.getTimezoneOffset = function() {
      return 360;
    };
    expect(strftime(d, '%z')).toBe('-0600');
  });

  it('should return literal percent', function() {
    expect(strftime(d, '%%')).toBe('%');
  });

  it('should retain non-formatting character', function() {
    let f = strftime(d, 'The year is %Y, around %i %p on %B %D');
    expect(f).toBe('The year is 2013, around 6 p.m. on September 1');
  });

  it('should allow customization of the config', function () {
    let MNTH = ['јан', 'феб', 'мар', 'апр', 'мај', 'јун', 'јул', 'авг', 'сеп',
      'окт', 'нов', 'дец'];
    expect(strftime(d, '%b %D.', {MNTH})).toBe('сеп 1.');
  });

});
