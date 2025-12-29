
  do ->

    { get-object-and-values-from-args: object-and-values } = dependency 'os.shell.Script'
    { try-string-as-number } = dependency 'value.Number'

    { value-as-string } = dependency 'prelude.reflection.Value'

    get-timeout = (args, timeout-arg = '') ->

      { object: { timeout: timeout-arg-values } } = object-and-values args

      if timeout-arg-values isnt void => [ timeout-arg ] = timeout-arg-values

      { value: timeout, error } = try-string-as-number "#timeout-arg"
      if error isnt void => timeout = void

      timeout

    #

    parse-card-args = (args) ->

      { object, values } = object-and-values args

      wrap-enabled = 'wrap' in values
      word-wrap-enabled = 'word-wrap' in values

      max-width = void

      { "max-width": max-width-values } = object
      if max-width-values isnt void

        max-width-string = if typeof max-width-values is 'string' then max-width-values else max-width-values.toString!
        max-width = parse-int max-width-string, 10
        if isNaN max-width => max-width = void

      { wrap-enabled, max-width, word-wrap-enabled }

    {
      get-timeout,
      parse-card-args
    }