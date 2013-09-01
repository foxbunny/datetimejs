###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Date and time formatting library
#
# This library provides a strftime-compatible API for formatting dates and time
# in JavaScript.
#
# This module is in UMD format and can be used in NodeJS, with an AMD loader
# such as RequireJS, or using a plain `<script>` tag.
define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    if typeof module is 'object' and module.exports
      (factory) -> module.exports = factory()
    else
      (factory) -> root.datetime = factory()
)(this)

define () ->
  DAY_MS = 86400000 # Number of milliseconds in a day
  REGEXP_CHARS = '^$[]().{}+*?|'.split ''
  PARSE_TOKEN_RE = /(%[bBdDfHiImMnNpsSryYz])/g

  dt =
    utils: {}
    datetime: {}

  #############################################################################
  # UTILITY METHODS
  #############################################################################

  # ## `datetime.utils.zeroPad(i, [digits, tail])`
  #
  # Zero-pads a number `i`.
  #
  # `digits` argument specifies the total number of digits. If omitted, it will
  # default to 3 for no particular reason. :)
  #
  # If `tail` argument is specified, the number will be considered a float, and
  # will zero-padded from the tail as well. The `tail` should be the number of
  # fractional digits after the dot.
  #
  # Tail is `false` by default. If you pass it a 0, it will floor the number
  # instead of not tailing, by removing the fractional part.
  #
  # Example:
  #
  #     datetime.utils.zeroPad(12, 4);
  #     // returns '0012'
  #
  #     datetime.utils.zeroPad(2.3, 5);
  #     // 002.3
  #
  #     datetime.utils.zeroPad(2.3, 5, 0);
  #     // 00002
  #
  #     datetime.utils.zeroPad(2.3, 5, 2);
  #     // 02.30
  #
  dt.utils.zeroPad = zeroPad = (i, digits=3, tail=false) ->
    if tail is false
      ((new Array digits).join('0') + i).slice -digits
    else
      [i, f] = i.toString().split('.')
      if tail is 0
        zeroPad i, digits - tail, false
      else
        i = zeroPad i, digits - 1 -tail, false
        f = zeroPad f.split('').reverse().join(''), tail, false
        f = f.split('').reverse().join('')
        [i, f].join('.')


  # ## `datetime.utils.cycle(i, max, [zeroIndex])`
  #
  # Keeps the number `i` within the `max` range. The range starts at 0 if
  # `zeroIndex` is `true` or 1 if `zeroIndex` is `false` (default).
  #
  # Example:
  #
  #     datetime.utils.cycle(4, 12);
  #     // Returns 4
  #
  #     datetime.utils.cycle(13, 12);
  #     // Returns 1
  #
  #     datetime.utils.cycle(13, 12, true);
  #     // Returns 1
  #
  #     datetime.utils.cycle(12, 12, true);
  #     // Returns 0
  #
  #     datetime.utils.cycle(12, 12, false);
  #     // Returns 12
  dt.utils.cycle = cycle = (i, max, zeroIndex=false) ->
    i % max or if zeroIndex then 0 else max

  # ## `datetime.utils.hour24(h, pm)`
  #
  # Converts the `h` hour into 24-hour format. The `pm` is `true` if the hour
  # is PM.
  dt.utils.hour24 = hour24 = (h, pm) ->
    return h if not pm
    h += 12
    if h is 24 then 0 else h


  #############################################################################
  # CONSTANTS*
  #
  # * Well, not really constants. These are more like values to be used for
  # customizing the behavior of all methods globally.
  #############################################################################

  # ## `datetime.MONTHS`
  #
  # Month names
  dt.MONTHS = MONTHS = [
    'January'
    'February'
    'March'
    'April'
    'May'
    'June'
    'July'
    'August'
    'September'
    'October'
    'November'
    'December'
  ]

  # ## `datetime.MNTH`
  #
  # Short month names (three-letter abbreviations).
  dt.MNTH = MNTH = [
    'Jan'
    'Feb'
    'Mar'
    'Apr'
    'May'
    'Jun'
    'Jul'
    'Aug'
    'Sep'
    'Oct'
    'Nov'
    'Dec'
  ]

  # ## `datetime.DAYS`
  #
  # Week day names, starting with Sunday.
  dt.DAYS = DAYS = [
    'Sunday'
    'Monday'
    'Tuesday'
    'Wednesday'
    'Thursday'
    'Friday'
    'Saturday'
  ]

  # ## `datetime.DY`
  #
  # Abbreviated week day names.
  dt.DY = DY = [
    'Sun'
    'Mon'
    'Tue'
    'Wed'
    'Thu'
    'Fri'
    'Sat'
  ]

  # ## `datetime.AM`
  #
  # Ante-meridiem shorthand
  dt.AM = AM = 'a.m.'

  # ## `datetime.PM`
  #
  # Post-meridiem shorthand
  dt.PM = PM = 'p.m.'


  # ## `datetime.WEEK_START`
  #
  # Day the week starts on. 0 is Sunday, 1 is Monday, and so on.
  dt.WEEK_START = 0

  # ## `datetime.FORMAT_TOKENS`
  #
  # Definitions of formatting tokens used by the `#strftime()` method. All
  # format functions are applied to a `Date` object so the `Date` methods can
  # be called on `this`.
  dt.FORMAT_TOKENS =
    # Shorthand day-of-week name
    '%a': () -> DY[@getDay()]

    # Full day-of-week name
    '%A': () -> DAYS[@getDay()]

    # Shorthand three-letter month name
    '%b': () -> MNTH[@getMonth()]

    # Full month name
    '%B': () -> MONTHS[@getMonth()]

    # Locale-formatted date and time (dependent on browser/platform/device),
    # here added for compatibility reasons.
    '%c': () -> @toLocaleString()

    # Zero-padded date (day of month)
    '%d': () -> zeroPad @getDate(), 2

    # * Non-zero-padded date (day of month)
    '%D': () -> "#{@getDate()}"

    # Zero-padded seconds with decimal part
    '%f': () ->
      s = @getSeconds()
      m = @getMilliseconds()
      fs = Math.round((s + m / 1000) * 100) / 100
      zeroPad fs, 5, 2

    # Zero-padded hour in 24-hour format
    '%H': () -> zeroPad @getHours(), 2

    # * Non-zero-padded hour in 12-hour format
    '%i': () -> cycle @getHours(), 12

    # Zero-padded hour in 12-hour format
    '%I': () -> zeroPad cycle(@getHours(), 12), 2

    # Zero-padded day of year
    '%j': () ->
      firstOfYear = new Date this.getFullYear(), 0, 1
      zeroPad Math.ceil((this - firstOfYear) / DAY_MS), 3

    # Zero-padded numeric month
    '%m': () -> zeroPad @getMonth() + 1, 2

    # Zero-padded minutes
    '%M': () -> zeroPad @getMinutes(), 2

    # * Non-zero-padded numeric month
    '%n': () -> "#{@getMonth() + 1}"

    # * Non-zero-padded minutes
    '%N': () -> "#{@getMinutes()}"

    # am/pm
    '%p': () -> ((h) -> if 0 <= h < 12 then AM else PM)(@getHours())

    # Non-zero-padded seconds
    '%s': () -> "#{@getSeconds()}"

    # Zero-padded seconds
    '%S': () -> zeroPad @getSeconds(), 2

    # Milliseconds
    '%r': () -> "#{@getMilliseconds()}"

    # Numeric day of week (0 == Sunday)
    '%w': () -> "#{@getDay()}"

    # Last two digits of the year
    '%y': () -> "#{@getFullYear()}"[-2..]

    # Full year
    '%Y': () -> "#{@getFullYear()}"

    # Locale-formatted date (without time)
    '%x': () -> @toLocaleDateString()

    # Locale-formatted time
    '%X': () -> @toLocaleTimeString()

    # Timezone in +HHMM or -HHMM format
    '%z': () ->
      pfx = if @getTimezoneOffset() >= 0 then '+' else '-'
      tz = Math.abs @getTimezoneOffset()
      "#{pfx}#{zeroPad ~~(tz / 60), 2}#{zeroPad tz % 60, 2}"

    # Literal percent character
    '%%': () -> '%'

    # Unsupported
    '%U': () -> ''
    '%Z': () -> ''

  # ## `datetime.PARSE_RECIPES`
  #
  # Functions for parsing the date.
  #
  # Each parser recipe corresponds to a format token. The recipe will return a
  # piece of regexp that will match the token within the string, and a function
  # that will convert the match.
  #
  # The converter function will take the matched string, and a meta object. The
  # meta object is later used as source of information for building the final
  # `Date` object.
  dt.PARSE_RECIPES =
    '%b': () ->
      re: "#{dt.MNTH.join '|'}"
      fn: (s, meta) ->
        mlc = mo.toLowerCase() for mo in dt.MNTH
        meta.month = mlc.indexOf s.toLowerCase()
    '%B': () ->
      re: "#{dt.MONTHS.join '|'}"
      fn: (s, meta) ->
        mlc = mo.toLowerCase() for mo in dt.MONTHS
        meta.month = mlc.indexOf s.toLowerCase()
    '%d': () ->
      re: '[0-2][0-9]|3[01]'
      fn: (s, meta) ->
        meta.date = parseInt s, 10
    '%D': () ->
      re: '3[01]|[12]?\\d'
      fn: (s, meta) ->
        meta.date = parseInt s, 10
    '%f': () ->
      re: '\\d{2}\\.\\d{2}'
      fn: (s, meta) ->
        s = parseFloat s
        meta.second = ~~s
        meta.millisecond = (s - ~~s) * 1000
    '%H': () ->
      re: '[0-1]\\d|2[0-3]'
      fn: (s, meta) ->
        meta.hour = parseInt s, 10
    '%i': () ->
      re: '1[0-2]|\\d'
      fn: (s, meta) ->
        meta.hour = parseInt s, 10
    '%I': () ->
      re: '0\\d|1[0-2]'
      fn: (s, meta) ->
        meta.hour = parseInt s, 10
    '%m': () ->
      re: '0\\d|1[0-2]'
      fn: (s, meta) ->
        meta.month = parseInt(s, 10) - 1
    '%M': () ->
      re: '[0-5]\\d'
      fn: (s, meta) ->
        meta.minute = parseInt s, 10
    '%n': () ->
      re: '1[0-2]|\\d'
      fn: (s, meta) ->
        meta.month = parseInt(s, 10) - 1
    '%N': () ->
      re: '[1-5]?\\d'
      fn: (s, meta) ->
        meta.minute = parseInt s, 10
    '%p': () ->
      re: "#{dt.PM.replace(/\./g, '\\.')}|#{dt.AM.replace(/\./g, '\\.')}"
      fn: (s, meta) ->
        meta.timeAdjust = dt.PM.toLowerCase() is s.toLowerCase()
    '%s': () ->
      re: '[1-5]?\\d'
      fn: (s, meta) ->
        meta.second = parseInt s, 10
    '%S': () ->
      re: '[0-5]\\d'
      fn: (s, meta) ->
        meta.second = parseInt s, 10
    '%r': () ->
      re: '\\d{1,3}'
      fn: (s, meta) ->
        meta.millisecond = parseInt s, 10
    '%y': () ->
      re: '\\d{2}'
      fn: (s, meta) ->
        c = (new Date()).getFullYear().toString()[..1]  # century
        meta.year = parseInt c + s, 10
    '%Y': () ->
      re: '\\d{4}'
      fn: (s, meta) ->
        meta.year = parseInt s, 10
    '%z': () ->
      re: '[+-](?1[01]|0\\d)[0-5]\\d|Z'
      fn: (s, meta) ->
        if s is 'Z'
          meta.timezone = 0
        else
          mult = if s[0] is '-' then -1 else 1
          h = parseInt s[1..2], 10
          m = parseInt s[3..4], 10
          meta.timezone = mult * (h * 60) + m

  dt.ISO_FORMAT = '%Y-%m-%dT%H:%M:%S.%r%Z'
  dt.ISO_UTC_FORMAT = '%Y-%m-%dT%H:%M:%S.%rZ'


  #############################################################################
  # `datetime` SUBMODULE (the business end)
  #############################################################################

  # ## `datetime.datetime.addDays(d, v)`
  #
  # Add `v` number of days to `d` and return the new date. `v` can be either a
  # positive or negative integer, or 0.
  dt.datetime.addDays = (d, v) ->
    d = new Date d
    d.setDate d.getDate() + v
    d

  # ## `datetime.datetime.addMonths(d, v)`
  #
  # Add `v` number of months to `d`. `v` can be either a postiive or negative
  # integer, or 0.
  dt.datetime.addMonths = (d, v) ->
    d = new Date d
    d.setMonth d.getMonth() + v
    d

  # ## `datetime.datetime.AddYears(d, v)`
  #
  # Add `v` number of years to `d`. `v` can be either a positive or negative
  # integer, or 0
  dt.datetime.addYears = (d, v) ->
    d = new Date d
    d.setFullYear d.getFullYear() + v
    d

  # ## `datetime.datetime.resetTime(d)`
  #
  # Reset the time part (hours, minutes, seconds, and milliseconds to 0).
  dt.datetime.resetTime = (d) ->
    d = new Date d
    d.setHours 0, 0, 0, 0
    d

  # ## `datetime.datetime.shiftTime(t)`
  #
  # Shift the time `t` milliseconds.
  dt.datetime.shiftTime = (t) ->
    d = new Date d
    d.setTime(d.getTime() + t)
    d

  # ## `datetime.datetime.toUTC(d)
  #
  # This method will return a date and time as if it were UTC. Note, however,
  # that JavaScript's native `Date` object generally has crappy support for
  # time zones so the resulting object will be in local time zone of the
  # platform/browser, and only the values will be UTC.
  dt.datetime.toUTC = (d) ->
    new Date d.getUTCFullYear(),
        d.getUTCMonth(),
        d.getUTCDate(),
        d.getUTCHours(),
        d.getUTCMinutes(),
        d.getUTCSeconds(),
        d.getUTCMilliseconds()

  # ## `datetime.datetime.today()`
  #
  # Returns a `Date` object for today's (local) date with time component set to
  # 0.
  dt.datetime.today = () ->
    d = new Date()
    @resetTime d

  # ## `datetime.datetime.thisMonth()`
  #
  # Returns a `Date` object that represents the 1st of current month.
  dt.datetime.thisMonth = () ->
    d = new Date()
    d.setDate 1
    @resetTime d

  # ## `datetime.datetime.thisWeek()`
  #
  # Returns a `Date` object that represents the first day of this week.
  dt.datetime.thisWeek = () ->
    d = new Date()
    # Difference in days between week start and today
    diff = d.getDay() - dt.WEEK_START
    d.setDate d.getDate() - diff
    @resetTime d

  # ## `datetime.datetime.delta(d1, d2)`
  #
  # Calculates the difference between two `Date` objects and returns a delta
  # object. The delta object has the following structure:
  #
  #     d.delta // relative difference
  #     d.milliseconds // difference in milliseconds (same as delta)
  #     d.seconds // difference rounded to seconds with no decimals
  #     d.minutes // difference rounded to minutes with no decimals
  #     d.hours // difference rounded to hours with no decimals
  #     d.days // difference rounded to days with no decimals
  #     d.composite // composite difference
  #
  # Relative difference means the difference between `d1` and `d2` relative to
  # `d1`. This can be a negative or positive number in milliseconds. All other
  # values (including the `milliseconds` key) are absolute, which means they
  # are always positive.
  #
  # The composite difference is an array containing the total difference in
  # days, hours, minutes, seconds, and milliseconds.
  #
  # Main difference between the composite values and the individual keys, is
  # that each individual key is a _total_ difference in given units, while the
  # composite is only total when you add up the individual components.
  dt.datetime.delta = (d1, d2) ->
    d1 = new Date d1
    d2 = new Date d2
    delta = d2 - d1  # absolute delta in ms
    absD = Math.abs delta

    # As a side note, the `~` operator is a bitwise NOT operator. It's an unary
    # operator, which floors a number if chained twice. Not sure where I picked
    # it up, but it seems to work fine.
    #
    # Here in the code below we use it to get the fraction part of float
    # numbers by subtracting the number from the double-bitwise-negated version
    # of the same number: x - ~~x

    days = absD / 1000 / 60 / 60 / 24  # diff in days, not rounded
    hrs = (days - ~~days) * 24 # fraction part of days in hours, not rounded
    mins = (hrs - ~~hrs) * 60 # fraction part of hours in minutes, not rounded
    secs = (mins - ~~mins) * 60 # fraction part of mins in seconds, not rounded
    msecs = (secs - ~~secs) * 1000 # fraction part of secs in milliseconds

    delta: delta
    milliseconds: absD
    seconds: Math.ceil absD / 1000
    minutes: Math.ceil absD / 1000 / 60
    hours: Math.ceil absD / 1000 / 60 / 60
    days: Math.ceil days
    composite: [~~days, ~~hrs, ~~mins, ~~secs, msecs]

  # ## `datetime.datetime.isBefore(d, d1)`
  #
  # Whether `d` is before `d1`.
  #
  # Note that here, `#isBefore()` is _not_ strictly the opposite of
  # `#isAfter()` becuase objects could also be equal.
  dt.datetime.isBefore = (d, d1) ->
    @delta(d, d1).delta < 0

  # ## `datetime.datetime.isAfter(d, d1)`
  #
  # Whether `d` is after `d1`.
  #
  # Note that here, `#isAfter()` is _not_ strictly the opposite of
  # `#isBefore()` becuase objects could also be equal.
  dt.datetime.isAfter = (d, d1) ->
    @delta(d, d1).delta > 0

  # ## `datetime.datetime.reorder(d, [d1, d2...])
  #
  # Reorder `Date` objects from oldest to newest and return an array.
  dt.datetime.reorder = (d...) ->
    d.sort (d1, d2) -> @delta(d1, d2).delta
    d

  # ## `datetime.datetime.isBetween(d, d1, d2)`
  #
  # Whether `d` is between `d1` and `d2`
  dt.datetime.isBetween = (d, d1, d2) ->
    [d1, d2] = @reorder d1, d2
    @isAfter(d, d1) and @isBefore(d, d2)

  # ## `datetime.datetime.isDateBefore(d, d1)`
  #
  # Whether `d` is before `d1` disregarding time.
  #
  # Note that `#isDateBefore()` is not strictly an opposite of `#isDateAfter()`
  # because the objects could also be equal.
  dt.datetime.isDateBefore = (d, d1) ->
    d = @resetTime d
    d1 = @resetTime d1
    @isBefore d, d1

  # ## `datetime.datetime.isDateAfter(d, d1)`
  #
  # Whether `d` is after `d1`.
  #
  # Note that `#isDateAfter()` is not strictly an opposite of `#isDateBefore()`
  # because the objects could also be equal.
  dt.datetime.isDateAfter = (d, d1) ->
    d = @resetTime d
    d1 = @resetTime d1
    @isAfter d, d1

  # ## `datetime.datetime.isDateBetween(d, d1, d2)`
  #
  # Whether `d` is between `d1` and `d2` datewise.
  dt.datetime.isDateBetween = (d, d1, d2) ->
    d = @resetTime d
    d1 = @resetTime d1
    d2 = @resetTime d2
    [d1, d2] = @reorder d1, d2
    @isDateAfter(d, d1) and @isDateBefore(d, d2)

  # ## `datetime.datetime.isLeapYear(d)`
  #
  # Returns `true` if the `d` is in leap year
  dt.datetime.isLeapYear = (d) ->
    d = new Date d
    d.setMonth 1
    d.setDate 29
    # This is a little hack that depends on how the `Date` constructor works in
    # JavaScript. If you try to set a date of February 29th, it only returns
    # the same date if it is a leap year.
    d.getDate() is 29

  # ## `datetime.strftime(d, format)`
  #
  # Formats `d` object using `format`. The formatting uses strftime-compatible
  # syntax with follwing tokens:
  #
  #  + %a - Short week day name (e.g. 'Sun', 'Mon'...)
  #  + %A - Long week day name (e.g., 'Sunday', 'Monday'...)
  #  + %b - Short month name (e.g., 'Jan', 'Feb'...)
  #  + %B - Full month name (e.g., 'January', 'February'...)
  #  + %c - Locale-formatted date and time (platform-dependent)
  #  + %d - Zero-padded date (e.g, 02, 31...)
  #  + %D - Non-zero-padded date (e.g., 2, 31...)
  #  + %f - Zero-padded decimal seconds (e.g., 04.23, 23.50)
  #  + %H - Zero-padded hour in 24-hour format (e.g., 8, 13, 0...)
  #  + %i - Non-zero-padded hour in 12-hour format (e.g., 8, 1, 12...)
  #  + %I - Zero-padded hour in 12-hour format (e.g., 08, 01, 12...)
  #  + %j - Zero-padded day of year (e.g., 002, 145, 364...)
  #  + %m - Zero-padded month (e.g., 01, 02...)
  #  + %M - Zero-padded minutes (e.g., 01, 12, 59...)
  #  + %n - Non-zero-padded month (e.g., 1, 2...)
  #  + %N - Non-zero-padded minutes (e.g., 1, 12, 59)
  #  + %p - AM/PM (a.m. and p.m.)
  #  + %s - Non-zero-padded seconds (e.g., 1, 2, 50...)
  #  + %S - Zero-padded seconds (e.g., 01, 02, 50...)
  #  + %r - Milliseconds (e.g., 1, 24, 500...)
  #  + %w - Numeric week day where 0 is Sunday (e.g., 0, 1...)
  #  + %y - Zero-padded year without the century part (e.g., 01, 13, 99...)
  #  + %Y - Full year (e.g., 2001, 2013, 2099...)
  #  + %z - Timezone in +HHMM or -HHMM format (e.g., +0200, -0530)
  #  + %x - Locale-formatted date (platform dependent)
  #  + %X - Locale-formatted time (platform dependent)
  #  + %% - Literal percent character %
  #
  # Because of the formatting token usage, you may safely mix non-date strings
  # in the formatting string. For example:
  #
  #     datetime.datetime.strftime(d, 'On %b %d at %i:%M %p');
  dt.strftime = (d, format) ->
    for token of dt.FORMAT_TOKENS
      r = new RegExp token, 'g'
      format = format.replace r, () ->
        dt.FORMAT_TOKENS[token].call(d)
    format


  # ## `datetime.strptime(s, format)`
  #
  # Parse a string `s` and return a `Date` object. The `format` string is used
  # to specify the format in which `s` date is represented.
  #
  # A subset of `#strftime()` tokens is used in parsing.
  #
  #  + %b - Short month name (e.g., 'Jan', 'Feb'...)
  #  + %B - Full month name (e.g., 'January', 'February'...)
  #  + %d - Zero-padded date (e.g, 02, 31...)
  #  + %D - Non-zero-padded date (e.g., 2, 31...)
  #  + %H - Zero-padded hour in 24-hour format (e.g., 8, 13, 0...)
  #  + %i - Non-zero-padded hour in 12-hour format (e.g., 8, 1, 12...)
  #  + %I - Zero-padded hour in 12-hour format (e.g., 08, 01, 12...)
  #  + %m - Zero-padded month (e.g., 01, 02...)
  #  + %M - Zero-padded minutes (e.g., 01, 12, 59...)
  #  + %n - Non-zero-padded month (e.g., 1, 2...)
  #  + %N - Non-zero-padded minutes (e.g., 1, 12, 59)
  #  + %p - AM/PM (a.m. and p.m.)
  #  + %s - Non-zero-padded seconds (e.g., 1, 2, 50...)
  #  + %S - Zero-padded seconds (e.g., 01, 02, 50...)
  #  + %r - Milliseconds (e.g., 1, 24, 500...)
  #  + %y - Zero-padded year without the century part (e.g., 01, 13, 99...)
  #  + %Y - Full year (e.g., 2001, 2013, 2099...)
  #  + %z - Time zone in +HHMM or -HHMM format or 'Z' (e.g., +1000, -0200)
  #
  # The `%z` token behaves slightly differently when parsing date and time
  # strings. In addition to formats that strftime outputs, it also supports
  # 'Z', which allows parsing of ISO timestamps.
  dt.strptime = (s, format) ->
    # Escape all regexp special characters
    rxp = format.replace /\\/, '\\\\'
    for schr in REGEXP_CHARS
      rxp = rxp.replace new RegExp('\\' + schr, 'g'), "\\#{schr}"

    # Interpolate the format tokens and obtain converter functions
    converters = []
    rxp = rxp.replace PARSE_TOKEN_RE, (m, token) ->
      # Get the token regexp and parser function
      {re, fn} = dt.PARSE_RECIPES[token]()
      converters.push fn
      "(#{re})"

    rxp = new RegExp "^#{rxp}$", "i"

    # Perform the match against the compiled parse regexp
    matches = s.match rxp

    # We consider the parse failed if nothing matched
    return null if not matches

    # Remove the first item from the matches, since we're not interested in it
    matches.shift()

    # Prepare the meta object
    meta =
      year: 0
      month: 0
      date: 0
      hour: 0
      minute: 0
      second: 0
      millisecond: 0
      timeAdjust: false
      timezone: null

    # Iterate parser functions and apply the function to each match
    for fn, idx in converters
      fn matches[idx], meta

    # Create the `Date` object using meta data
    d = new Date meta.year,
      meta.month,
      meta.date,
      (if meta.timeAdjust then hour24(meta.hour) else meta.hour),
      meta.minute,
      meta.second,
      meta.millisecond

    if meta.timezone?
      # Determine the relative offset of the original time to local time of
      # the platform.
      localOffset = d.getTimezoneOffset()
      # We need to shift the time by the difference of timezone and local
      # zone
      offset = (localOffset - meta.timezone) * 60 * 1000  # in ms
      d = dt.datetime.shiftTime offset

    d

  dt

