# strftime formatting tests

assert = require 'assert'
datetime = require '../datetime'

eq = assert.equal
sft = datetime.strftime
d = new Date(2013, 8, 1, 18, 7, 8, 200)
d1 = new Date(2013, 8, 1, 8, 7, 8, 200)

describe 'datetime.strftime', () ->
  it 'should return the short week day name', () ->
    eq sft(d, '%a'), 'Sun'

  it 'should return the long week day name', () ->
    eq sft(d, '%A'), 'Sunday'

  it 'should return the short month name', () ->
    eq sft(d, '%b'), 'Sep'

  it 'should return the long month name', () ->
    eq sft(d, '%B'), 'September'

  it 'should return the zero-padded date', () ->
    eq sft(d, '%d'), '01'

  it 'should return the non-padded date', () ->
    eq sft(d, '%D'), '1'

  it 'should return zero-padded seconds with fraction', () ->
    eq sft(d, '%f'), '08.20'

  it 'should return zero-padded hours in 24-hour format', () ->
    eq sft(d, '%H'), '18'

  it 'should return non-padded hours in 12-hour format', () ->
    eq sft(d, '%i'), '6'

  it 'should return zero-padded hours in 12-hour format', () ->
    eq sft(d, '%I'), '06'

  it 'should return zer-padded day of year', () ->
    eq sft(d, '%j'), '244'

  it 'should return zero-padded numeric month', () ->
    eq sft(d, '%m'), '09'

  it 'should return zero-padded minutes', () ->
    eq sft(d, '%M'), '07'

  it 'should return non-padded month', () ->
    eq sft(d, '%n'), '9'

  it 'should return non-padded minutes', () ->
    eq sft(d, '%N'), '7'

  it 'should return PM', () ->
    eq sft(d, '%p'), 'p.m.'

  it 'should return AM', () ->
    d.setHours 9
    eq sft(d, '%p'), 'a.m.'
    d.setHours 18

  it 'should return non-padded seconds', () ->
    eq sft(d, '%s'), '8'

  it 'should return padded seconds', () ->
    eq sft(d, '%S'), '08'

  it 'should return miliseconds', () ->
    eq sft(d, '%r'), '200'

  it 'should return numeric weed day', () ->
    eq sft(d, '%w'), '0'

  it 'should return year without century', () ->
    eq sft(d, '%y'), '13'

  it 'should return full year', () ->
    eq sft(d, '%Y'), '2013'

  it 'should return timezone', () ->
    # We must mock the timezone method
    original = d.getTimezoneOffset
    d.getTimezoneOffset = () -> -120  # minus 2 hours
    eq sft(d, '%z'), '+0200'
    d.getTimezoneOffset = () -> 360  # plus 6 hours
    eq sft(d, '%z'), '-0600'
    d.getTimezoneOffset = original

  it 'should return literal percent', () ->
    eq sft(d, '%%'), '%'

  it 'should retain non-formatting character', () ->
    f = sft(d, 'The year is %Y, around %i %p on %B %D')
    eq f, "The year is 2013, around 6 p.m. on September 1"
