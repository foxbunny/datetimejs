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
  describe '#clone', () ->
    it 'should create identical version of date object', () ->
      d = new Date 2013, 8, 1
      d1 = datetime.datetime.clone d
      assert.equal d1 - d, 0

    it 'should create distinct instances', () ->
      d = new Date 2013, 8, 1
      d1 = datetime.datetime.clone d
      assert.notEqual d1, d

  describe '#addDays', () ->
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

  describe '#addMonths', () ->
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

  describe '#addYears', () ->
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

  describe '#resetTime', () ->
    it 'should reset the time to 0', () ->
      d = new Date 2013, 8, 1, 15, 22, 59, 333
      d = datetime.datetime.resetTime d
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0

  describe '#today', () ->
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

  describe '#thisMonth', () ->
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

  describe '#thisWeek', () ->
    it 'should be this Sunday', () ->
      nativeDate = Date

      # This vars will hold values thrown at Date methods
      date = null

      # We'll mock the global Date object
      root.Date = () ->
        getDay: () -> 4  # Thursday
        getDate: () -> 10
        setDate: (d) -> date = d
        setHours: () ->
        getTime: () ->

      datetime.datetime.thisWeek()
      assert.equal date, 6  # date of 10 adjusted by -4

      root.Date = nativeDate

    it 'should have reset time', () ->
      d = datetime.datetime.thisWeek()
      assert.equal d.getHours(), 0
      assert.equal d.getMinutes(), 0
      assert.equal d.getSeconds(), 0
      assert.equal d.getMilliseconds(), 0


