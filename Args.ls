
  do ->

    { create-error-context } = dependency 'prelude.error.Context'
    { get-object-and-values-from-arguments: object-and-values } = dependency 'os.shell.Script'
    { value-or-error } = dependency 'prelude.error.Value'
    { try-string-as-number } = dependency 'value.Number'

    { value-as-string } = dependency 'prelude.reflection.Value'

    { create-error, contextualized } = create-error-context 'AsciiSeparatedOutput.Args'

    get-timeout = (args, default-timeout) ->

      return default-timeout if args.length is 0

      { object: { timeout: timeout-arg-values } } = object-and-values args
      if timeout-arg-values is void => throw create-error "Invalid parameter(s) '#{ args * ' ' }'."

      [ timeout-arg ] = timeout-arg-values

      { value: timeout, error } = try-string-as-number timeout-arg
      throw contextualized error unless error is void

      timeout

    try-get-timeout = (args, default-timeout) -> value-or-error -> get-timeout args, default-timeout

    {
      get-timeout, try-get-timeout
    }