# # Parser tests

if require?
  chai = require 'chai'
  datetime = require '../datetime'

if not GLOBAL?
  root = this
else
  root = GLOBAL

assert = chai.assert

describe 'datetime.parse', () ->
  describe '#strptime', () ->
    it 'should return null when input is bogus', () ->
      d = datetime.strptime 'bogus input', '%Y-%m-%d'
      assert.equal d, null

    it 'should parse full month name', () ->
      for month, idx in datetime.MONTHS
        d = datetime.strptime "#{month} 1 2013", '%B %D %Y'
        assert.equal d.getMonth(), idx

    it 'should parse full month case insensitively', () ->
      for month, idx in datetime.MONTHS
        d = datetime.strptime "#{month.toLowerCase()} 1 2013", '%B %D %Y'
        assert.equal d.getMonth(), idx

    it 'should parse short month name', () ->
      for month, idx in datetime.MNTH
        d = datetime.strptime "#{month} 1 2013", '%b %D %Y'
        assert.equal d.getMonth(), idx

    it 'should parse short month names case insensitively', () ->
      for month, idx in datetime.MNTH
        d = datetime.strptime "#{month.toLowerCase()} 1 2013", '%b %D %Y'
        assert.equal d.getMonth(), idx

    it 'should parse decimal seconds', () ->
      d = datetime.strptime '2013-12-01 12:00:01.12', '%Y-%m-%d %H:%M:%f'
      assert.equal d.getSeconds(), 1
      assert.equal d.getMilliseconds(), 120

    it 'should parse AM PM', () ->
      d = datetime.strptime '2013-12-01 09:00 a.m.', '%Y-%m-%d %I:%M %p'
      assert.equal d.getHours(), 9
      d = datetime.strptime '2013-12-01 09:00 p.m.', '%Y-%m-%d %I:%M %p'
      assert.equal d.getHours(), 21

  describe '#isoparse()', () ->
    it 'should parse date in ISO format', () ->
      d = datetime.isoparse '2013-09-01T16:00:00.00'
      # Compensate for local timezone
      d.setMinutes d.getMinutes() + d.getTimezoneOffset()
      assert.equal d.getFullYear(), 2013
      assert.equal d.getMonth(), 8
      assert.equal d.getHours(), 16
      assert.equal d.getMinutes(), 0

