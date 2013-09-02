# # Test for datetime.dtdelta

if require?
  chai = require 'chai'
  datetime = require '../datetime'

if not GLOBAL?
  root = this
else
  root = GLOBAL

assert = chai.assert

describe 'datetime.dtdelta', () ->
  describe '#delta', () ->
    it 'should return an object with required properties', () ->
      d1 = d2 = new Date()
      delta = datetime.dtdelta.delta d1, d2
      assert.ok delta.hasOwnProperty('delta'), 'missing `delta`'
      assert.ok delta.hasOwnProperty('milliseconds'), 'missing `milliseconds`'
      assert.ok delta.hasOwnProperty('seconds'), 'missing `seconds`'
      assert.ok delta.hasOwnProperty('minutes'), 'missing `minutes`'
      assert.ok delta.hasOwnProperty('hours'), 'missing `hours`'
      assert.ok delta.hasOwnProperty('composite'), 'missing `composite`'

    it 'should return 0 if dates are equal', () ->
      d1 = d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.delta, 0

    it 'should return difference in milliseconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 10
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.delta, 10

    it 'can return negative delta if d2 is before d1', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 10
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.delta, -10

    it 'returns absolute delta in milliseconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 10
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.milliseconds, 10

    it 'returns absolute delta in seconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.seconds, 2

    it 'rounds delta in seconds up', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.seconds, 3

    it 'should express seconds in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.milliseconds, 2 * 1000

    it 'returns absolute delta in minutes', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.minutes, 2

    it 'rounds delta in minutes up', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.minutes, 3

    it 'should express minutes in seconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.seconds, 2 * 60

    it 'should express minutes in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.milliseconds, 2 * 60 * 1000

    it 'returns absolute delta in hours', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.hours, 1

    it 'rounds delta in hours up', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.hours, 2

    it 'should express hours in minutes as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.minutes, 60

    it 'should express hours in seconds as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.seconds, 60 * 60

    it 'should express hours in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.milliseconds, 60 * 60 * 1000

    it 'returns absolute delta in days', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.days, 2

    it 'rounds delta in days up', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.days, 3

    it 'should express days in hours as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.hours, 2 * 24

    it 'should express days in minutes as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.minutes, 2 * 24 * 60

    it 'should express days in seconds as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.seconds, 2 * 24 * 60 * 60

    it 'should express days in milliseconds as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.milliseconds, 2 * 24 * 60 * 60 * 1000

    it 'should give a composite delta', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.composite[0], 2  # days
      assert.equal delta.composite[1], 0  # hours
      assert.equal delta.composite[2], 0  # minutes
      assert.equal delta.composite[3], 0  # seconds
      assert.equal delta.composite[4], 0  # milliseconds

    it 'should give a composite delta with all values', () ->
      d1 = new Date 2013, 8, 3, 13, 1, 1, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.dtdelta.delta d1, d2
      assert.equal delta.composite[0], 2, 'days'
      assert.equal delta.composite[1], 1, 'hours'
      assert.equal delta.composite[2], 1, 'minutes'
      assert.equal delta.composite[3], 1, 'seconds'
      # We do not compare milliseconds due to rounding errors

  describe '#reorder', () ->
    it 'should return ordered dates', () ->
      d1 = new Date 2013, 8, 1
      d2 = new Date 2013, 8, 2
      d3 = new Date 2013, 8, 3
      sorted = datetime.dtdelta.reorder d3, d1, d2
      assert.equal d1, sorted[0]
      assert.equal d2, sorted[1]
      assert.equal d3, sorted[2]

  describe '#isBefore', () ->
    it 'should basically work :)', () ->
      old = new Date 2013, 8, 1, 12, 0, 0, 0
      neu = new Date 2013, 8, 1, 12, 1, 0, 0
      assert.ok datetime.dtdelta.isBefore old, neu
      assert.notOk datetime.dtdelta.isBefore neu, old

    it 'should return false when dates are equal', () ->
      old = neu = new Date 2013, 8, 1, 12, 0, 0, 0
      assert.notOk datetime.dtdelta.isBefore old, neu
      assert.notOk datetime.dtdelta.isBefore neu, old

  describe '#isAfter', () ->
    it 'should basically work... again', () ->
      old = new Date 2013, 8, 1, 12, 0, 0, 0
      neu = new Date 2013, 8, 1, 12, 1, 0, 0
      assert.notOk datetime.dtdelta.isAfter old, neu
      assert.ok datetime.dtdelta.isAfter neu, old

    it 'should return false if dates are equal', () ->
      old = neu = new Date 2013, 8, 1, 12, 0, 0, 0
      assert.notOk datetime.dtdelta.isAfter old, neu
      assert.notOk datetime.dtdelta.isAfter neu, old

  describe '#isBetwen', () ->
    it 'should return true when date is between two dates', () ->
      d1 = new Date 2013, 8, 1
      d2 = new Date 2013, 8, 2
      d3 = new Date 2013, 8, 3
      assert.ok datetime.dtdelta.isBetween d2, d1, d3

    it "should't care about order of the two extremes", () ->
      d1 = new Date 2013, 8, 1
      d2 = new Date 2013, 8, 2
      d3 = new Date 2013, 8, 3
      assert.ok datetime.dtdelta.isBetween d2, d3, d1

    it "should return false if middle date matches an extereme", () ->
      d1 = new Date 2013, 8, 1
      d2 = d3 = new Date 2013, 8, 2
      assert.notOk datetime.dtdelta.isBetween d2, d1, d3

    it "should return false if date is outside extremes", () ->
      d1 = new Date 2013, 8, 1
      d2 = new Date 2013, 8, 2
      d3 = new Date 2013, 8, 3
      assert.notOk datetime.dtdelta.isBetween d1, d2, d3

  describe '#isDateBefore', () ->
    it 'should return false if only times differ', () ->
      old = new Date 2013, 8, 1, 5
      neu = new Date 2013, 8, 1, 12
      assert.notOk datetime.dtdelta.isDateBefore old, neu
      assert.notOk datetime.dtdelta.isDateBefore neu, old

    it 'should return false if if date is after', () ->
      old = new Date 2013, 8, 1
      neu = new Date 2013, 8, 2
      assert.notOk datetime.dtdelta.isDateBefore neu, old

    it 'should return true if date is before', () ->
      old = new Date 2013, 8, 1
      neu = new Date 2013, 8, 2
      assert.ok datetime.dtdelta.isDateBefore old, neu

  describe '#isDateAfter', () ->
    it 'should return false if only times differ', () ->
      old = new Date 2013, 8, 1, 5
      neu = new Date 2013, 8, 1, 12
      assert.notOk datetime.dtdelta.isDateAfter neu, old
      assert.notOk datetime.dtdelta.isDateAfter old, neu

    it 'should return false if date is before', () ->
      old = new Date 2013, 8, 1
      neu = new Date 2013, 8, 2
      assert.notOk datetime.dtdelta.isDateAfter old, neu

    it 'should return true if date is after', () ->
      old = new Date 2013, 8, 1
      neu = new Date 2013, 8, 2
      assert.ok datetime.dtdelta.isDateAfter neu, old

