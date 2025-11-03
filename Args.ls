
  do ->

    { get-object-and-values-from-arguments: object-and-values } = dependency 'os.shell.Script'
    { try-string-as-number } = dependency 'value.Number'

    { value-as-string } = dependency 'prelude.reflection.Value'

    get-timeout = (args, timeout-arg = '') ->

      { object: { timeout: timeout-arg-values } } = object-and-values args

      if timeout-arg-values isnt void => [ timeout-arg ] = timeout-arg-values

      { value: timeout, error } = try-string-as-number "#timeout-arg"
      if error isnt void => timeout = void

      timeout

    {
      get-timeout
    }