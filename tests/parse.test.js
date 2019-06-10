import {DEFAULT_CONFIG} from '../src/config';
import {strptime} from '../src/parse';

describe('strptime', function() {

  it('should return null when input is bogus', function() {
    expect(strptime('bogus input', '%Y-%m-%d')).toBeNull();
  });

  it.each(DEFAULT_CONFIG.MONTHS.map(function (val, idx) {
    return [val, idx];
  }))(
    'should parse full month name, like %s',
    function (val, idx) {
      let d = strptime(`${val} 1 2019`, '%B %D %Y');
      expect(d.getMonth()).toBe(idx);
    }
  );

  it.each(DEFAULT_CONFIG.MONTHS.map(function (val, idx) {
    return [val.toLowerCase(), idx];
  }))(
    'should parse full month like %s case-insensitively',
    function (val, idx) {
      let d = strptime(`${val} 1 2019`, '%B %D %Y');
      expect(d.getMonth()).toBe(idx);
    }
  );

  it.each(DEFAULT_CONFIG.MNTH.map(function (val, idx) {
    return [val, idx];
  }))(
    'should parse short month name, like %s',
    function(val, idx) {
      let d = strptime(`${val} 1 2019`, '%b %D %Y');
      expect(d.getMonth()).toBe(idx);
    }
  );

  it.each(DEFAULT_CONFIG.MNTH.map(function (val, idx) {
    return [val.toLowerCase(), idx];
  }))(
    'should parse short month like %s case-insensitively',
    function(val, idx) {
      let d = strptime(`${val} 1 2019`, '%b %D %Y');
      expect(d.getMonth()).toBe(idx);
    }
  );

  it('should parse seconds with fractional part', function() {
    let d = strptime('2019-12-01 12:00:01.12', '%Y-%m-%d %H:%M:%f');
    expect(d.getSeconds()).toBe(1);
    expect(d.getMilliseconds()).toBe(120);
  });

  it('should parse AM', function() {
    let d = strptime('2019-12-01 09:00 a.m.', '%Y-%m-%d %I:%M %p');
    expect(d.getHours()).toBe(9);
  });

  it('should parse PM', function () {
    let d = strptime('2019-12-01 09:00 p.m.', '%Y-%m-%d %I:%M %p');
    expect(d.getHours()).toBe(21);
  });

  it('should parse only with year, and no date or month)', function() {
    let d = strptime("2019", '%Y');
    expect(d.getFullYear()).toBe(2019);
  });

  it.each(DEFAULT_CONFIG.MNTH.map(function (val, idx) {
    return [val, idx];
  }))(
    'should parse with short month name like %s and year, and no date',
    function (val, idx) {
      let d = strptime(`${val} 2019`, '%b %Y');
      expect(d.getMonth()).toBe(idx);
    }
  );

  it('should parse a literal percent character', function () {
    let d = strptime('06 % 05 % 2019', '%m %% %d %% %Y');
    expect(d).not.toBeNull();
    let n = strptime('06 05 % 2019', '%m %% %d %% %Y');
    expect(n).toBeNull();
  });

  it('should allow custom configuration', function () {
    let MNTH = ['јан', 'феб', 'мар', 'апр', 'мај', 'јун', 'јул', 'авг', 'сеп',
      'окт', 'нов', 'дец'];
    const dt = strptime('1. сеп 2009.', '%D. %b %Y.', {MNTH})
    expect(dt.getFullYear()).toBe(2009);
    expect(dt.getMonth()).toBe(8);
    expect(dt.getDate()).toBe(1);
  });

});

