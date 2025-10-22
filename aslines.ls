
  { try-read-input-text, stderr-lines, stdout-lf } = dependency 'os.shell.IO'
  { script-arguments: argv, script-arguments-count: argc, exit } = dependency 'os.shell.Script'
  { try-get-timeout } = dependency 'Args'
  { string-as-lines } = dependency 'value.string.Text'

  fail-on-error = (error, exit-code) -> return if error is void ; stderr-lines [ error.message ] ; exit exit-code

  errorlevel = 1 ; { value: timeout, error } = try-get-timeout argv, 200 ; fail-on-error error, errorlevel
  errorlevel++ ; { value: input-text, error } = try-read-input-text timeout ; fail-on-error error, errorlevel

  for line in string-as-lines input-text => stdout-lf line