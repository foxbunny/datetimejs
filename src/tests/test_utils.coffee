# Test utility methods

assert = require 'assert'
datetime = require '../datetime'

utils = datetime.utils

describe 'datetime.utils', () ->
  describe '#zeroPad()', () ->
    it 'should generate total of 4 digits when called with 4', () ->
      i = 10
      s = utils.zeroPad i, 4
      assert.equal s.length, 4

    it 'should truncates numbers that are too long', () ->
      i = 10
      s = utils.zeroPad i, 1
      assert.equal s.length, 1
      assert.equal s, '0'

    it 'should pad floats normally unless tailed with 0', () ->
      f = 2.5
      s = utils.zeroPad f, 5
      assert.equal s, '002.5'

    it 'should floor the float if tailed with 0', () ->
      f = 2.5
      s = utils.zeroPad f, 5, 0
      assert.equal s, '00002'

    it 'should account for floating digits if told to tail', () ->
      f = 2.5
      s = utils.zeroPad f, 5, 2
      assert.equal s, '02.50'

    it 'should handle a 0 normally', () ->
      assert.equal utils.zeroPad(0, 5, 2), '00.00'

