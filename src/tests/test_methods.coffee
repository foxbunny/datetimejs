# ## Test methods in datetime

if require?
  chai = require 'chai'
  datetime = require '../datetime'

if not GLOBAL?
  root = this
else
  root = GLOBAL

assert = chai.assert

describe 'datetime.datetime', () ->
  describe '#addDays()', () ->
    it 'should add one day to date if passed date and 1', () ->
      d = new Date 2013, 8, 1
      d = datetime.datetime.addDays d, 1
      assert.equal d.getDate(), 2

    it 'should go back 1 day if passed date and -1', () ->
      d = new Date 2013, 8, 1
      d = datetime.datetime.addDays d, -1
      assert.equal d.getDate(), 31
      assert.equal d.getMonth(), 7

    it 'even changes the year if necessary', () ->
      d = new Date 2013, 11, 31
      d = datetime.datetime.addDays d, 1
      assert.equal d.getDate(), 1
      assert.equal d.getMonth(), 0
      assert.equal d.getFullYear(), 2014

  describe '#addMonths()', () ->
    it 'should add one month if passed a date and 1', () ->
      d = new Date 2013, 8, 1
      d = datetime.datetime.addMonths d, 1
      assert.equal d.getMonth(), 9

    it 'should go back one month if passed -1', () ->
      d = new Date 2013, 8, 1
      d = datetime.datetime.addMonths d, -1
      assert.equal d.getMonth(), 7

    it 'changes years if we push it', () ->
      d = new Date 2013, 8, 1
      d = datetime.datetime.addMonths d, 4
      assert.equal d.getMonth(), 0
      assert.equal d.getFullYear(), 2014

  describe '#addYears()', () ->
    it 'should add a year if passed 1', () ->
      d = new Date 2013, 0, 1
      d = datetime.datetime.addYears d, 1
      assert.equal d.getFullYear(), 2014

    it 'should go back in time if passed -1', () ->
      d = new Date 2013, 0, 1
      d = datetime.datetime.addYears d, -1
      assert.equal d.getFullYear(), 2012

    it 'should go to to next date on leap year', () ->
      d = new Date 2012, 1, 29
      d = datetime.datetime.addYears d, 1
      assert.equal d.getDate(), 1
      assert.equal d.getMonth(), 2
      assert.equal d.getFullYear(), 2013

  describe '#resetTime()', () ->
    it 'should reset the time to 0', () ->
      d = new Date 2013, 8, 1, 15, 22, 59, 333
      d = datetime.datetime.resetTime d
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0

  describe '#today()', () ->
    it 'should be today', () ->
      d1 = new Date()
      d2 = datetime.datetime.today()
      assert.equal d1.getFullYear(), d2.getFullYear()
      assert.equal d1.getMonth(), d2.getMonth()
      assert.equal d1.getDate(), d2.getDate()

    it 'should have reset time', () ->
      d = datetime.datetime.today()
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0

  describe '#thisMonth()', () ->
    it "should be this month's 1st", () ->
      d1 = new Date()
      d2 = datetime.datetime.thisMonth()
      assert.equal d1.getFullYear(), d2.getFullYear()
      assert.equal d1.getMonth(), d2.getMonth()
      assert.equal d2.getDate(), 1

    it 'should have reset time', () ->
      d = datetime.datetime.thisMonth()
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0

  describe '#thisWeek()', () ->
    it 'should be this Sunday', () ->
      # We'll mock the global Date object
      nativeDate = Date

      # This vars will hold values thrown at Date methods
      date = null

      root.Date = () ->
        getDay: () ->
          4  # Thursday
        getDate: () ->
          10
        setDate: (d) ->
          date = d
        setHours: () ->

      datetime.datetime.thisWeek()
      assert.equal date, 6  # date of 10 adjusted by -4

      root.Date = nativeDate

    it 'should have reset time', () ->
      d = datetime.datetime.thisWeek()
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0

  describe '#delta()', () ->
    it 'should return an object with required properties', () ->
      d1 = d2 = new Date()
      delta = datetime.datetime.delta d1, d2
      assert.ok delta.hasOwnProperty('delta'), 'missing `delta`'
      assert.ok delta.hasOwnProperty('milliseconds'), 'missing `milliseconds`'
      assert.ok delta.hasOwnProperty('seconds'), 'missing `seconds`'
      assert.ok delta.hasOwnProperty('minutes'), 'missing `minutes`'
      assert.ok delta.hasOwnProperty('hours'), 'missing `hours`'
      assert.ok delta.hasOwnProperty('composite'), 'missing `composite`'

    it 'should return 0 if dates are equal', () ->
      d1 = d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.delta, 0

    it 'should return difference in milliseconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 10
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.delta, 10

    it 'can return negative delta if d2 is before d1', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 10
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.delta, -10

    it 'returns absolute delta in milliseconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 0, 10
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.milliseconds, 10

    it 'returns absolute delta in seconds', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.seconds, 2

    it 'rounds delta in seconds up', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.seconds, 3

    it 'should express seconds in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 0, 2, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.milliseconds, 2 * 1000

    it 'returns absolute delta in minutes', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.minutes, 2

    it 'rounds delta in minutes up', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.minutes, 3

    it 'should express minutes in seconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.seconds, 2 * 60

    it 'should express minutes in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 12, 2, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.milliseconds, 2 * 60 * 1000

    it 'returns absolute delta in hours', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.hours, 1

    it 'rounds delta in hours up', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.hours, 2

    it 'should express hours in minutes as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.minutes, 60

    it 'should express hours in seconds as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.seconds, 60 * 60

    it 'should express hours in milliseconds as well', () ->
      d1 = new Date 2013, 8, 1, 13, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.milliseconds, 60 * 60 * 1000

    it 'returns absolute delta in days', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.days, 2

    it 'rounds delta in days up', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.days, 3

    it 'should express days in hours as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.hours, 2 * 24

    it 'should express days in minutes as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.minutes, 2 * 24 * 60

    it 'should express days in seconds as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.seconds, 2 * 24 * 60 * 60

    it 'should express days in milliseconds as well', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.milliseconds, 2 * 24 * 60 * 60 * 1000

    it 'should give a composite delta', () ->
      d1 = new Date 2013, 8, 3, 12, 0, 0, 0
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.composite[0], 2  # days
      assert.equal delta.composite[1], 0  # hours
      assert.equal delta.composite[2], 0  # minutes
      assert.equal delta.composite[3], 0  # seconds
      assert.equal delta.composite[4], 0  # milliseconds

    it 'should give a composite delta with all values', () ->
      d1 = new Date 2013, 8, 3, 13, 1, 1, 1
      d2 = new Date 2013, 8, 1, 12, 0, 0, 0
      delta = datetime.datetime.delta d1, d2
      assert.equal delta.composite[0], 2, 'days'
      assert.equal delta.composite[1], 1, 'hours'
      assert.equal delta.composite[2], 1, 'minutes'
      assert.equal delta.composite[3], 1, 'seconds'
      # We do not compare milliseconds due to rounding errors
