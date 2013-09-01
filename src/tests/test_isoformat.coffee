# ISO format test

if require?
  chai = require 'chai'
  datetime = require '../datetime'

assert = chai.assert

describe 'datetime', () ->
  describe '#isoformat()', () ->
    it 'should format date as ISO', () ->
      d = new Date(2013, 8, 1, 16)
      # Compensate for local timezone
      d.setMinutes d.getMinutes() - d.getTimezoneOffset()
      assert.equal datetime.isoformat(d), '2013-09-01T16:00:00.00'

  describe '#isoparse()', () ->
    it 'should parse date in ISO format', () ->
      d = datetime.isoparse '2013-09-01T16:00:00.00'
      # Compensate for local timezone
      d.setMinutes d.getMinutes() - d.getTimezoneOffset()
      assert.equal d.getFullYear(), 2013
      assert.equal d.getMonth(), 8
      assert.equal d.getHours(), 16
      assert.equal d.getMinutes(), 0


