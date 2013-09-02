# strftime formatting tests

if require?
  chai = require 'chai'
  datetime = require '../datetime'

assert = chai.assert

d = new Date(2013, 8, 1, 18, 7, 8, 200)
d1 = new Date(2013, 8, 1, 8, 7, 8, 200)

describe 'datetime.format', () ->
  describe 'strftime()', () ->
    it 'should return the short week day name', () ->
      assert.equal datetime.strftime(d, '%a'), 'Sun'

    it 'should return the long week day name', () ->
      assert.equal datetime.strftime(d, '%A'), 'Sunday'

    it 'should return the short month name', () ->
      assert.equal datetime.strftime(d, '%b'), 'Sep'

    it 'should return the long month name', () ->
      assert.equal datetime.strftime(d, '%B'), 'September'

    it 'should return the zero-padded date', () ->
      assert.equal datetime.strftime(d, '%d'), '01'

    it 'should return the non-padded date', () ->
      assert.equal datetime.strftime(d, '%D'), '1'

    it 'should return zero-padded seconds with fraction', () ->
      assert.equal datetime.strftime(d, '%f'), '08.20'

    it 'should return zero-padded hours in 24-hour format', () ->
      assert.equal datetime.strftime(d, '%H'), '18'

    it 'should return non-padded hours in 12-hour format', () ->
      assert.equal datetime.strftime(d, '%i'), '6'

    it 'should return zero-padded hours in 12-hour format', () ->
      assert.equal datetime.strftime(d, '%I'), '06'

    it 'should return zer-padded day of year', () ->
      assert.equal datetime.strftime(d, '%j'), '244'

    it 'should return zero-padded numeric month', () ->
      assert.equal datetime.strftime(d, '%m'), '09'

    it 'should return zero-padded minutes', () ->
      assert.equal datetime.strftime(d, '%M'), '07'

    it 'should return non-padded month', () ->
      assert.equal datetime.strftime(d, '%n'), '9'

    it 'should return non-padded minutes', () ->
      assert.equal datetime.strftime(d, '%N'), '7'

    it 'should return PM', () ->
      assert.equal datetime.strftime(d, '%p'), 'p.m.'

    it 'should return AM', () ->
      d.setHours 9
      assert.equal datetime.strftime(d, '%p'), 'a.m.'
      d.setHours 18

    it 'should return non-padded seconds', () ->
      assert.equal datetime.strftime(d, '%s'), '8'

    it 'should return padded seconds', () ->
      assert.equal datetime.strftime(d, '%S'), '08'

    it 'should return miliseconds', () ->
      assert.equal datetime.strftime(d, '%r'), '200'

    it 'should return numeric weed day', () ->
      assert.equal datetime.strftime(d, '%w'), '0'

    it 'should return year without century', () ->
      assert.equal datetime.strftime(d, '%y'), '13'

    it 'should return full year', () ->
      assert.equal datetime.strftime(d, '%Y'), '2013'

    it 'should return timezone', () ->
      # We must mock the timezone method
      original = d.getTimezoneOffset
      d.getTimezoneOffset = () -> -120  # minus 2 hours
      assert.equal datetime.strftime(d, '%z'), '+0200'
      d.getTimezoneOffset = () -> 360  # plus 6 hours
      assert.equal datetime.strftime(d, '%z'), '-0600'
      d.getTimezoneOffset = original

    it 'should return literal percent', () ->
      assert.equal datetime.strftime(d, '%%'), '%'

    it 'should retain non-formatting character', () ->
      f = datetime.strftime(d, 'The year is %Y, around %i %p on %B %D')
      assert.equal f, "The year is 2013, around 6 p.m. on September 1"

  describe '#isoformat()', () ->
    it 'should format date as ISO', () ->
      d = new Date(2013, 8, 1, 16)
      # Compensate for local timezone
      d.setMinutes d.getMinutes() - d.getTimezoneOffset()
      assert.equal datetime.isoformat(d), '2013-09-01T16:00:00.00'
