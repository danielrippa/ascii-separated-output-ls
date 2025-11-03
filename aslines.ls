
  { read-stdin, stdout } = dependency 'os.shell.IO'
  { script-arguments: argv } = dependency 'os.shell.Script'
  { get-timeout } = dependency 'Args'
  { string-as-lines } = dependency 'value.string.Text'
  { control-chars: { lf } } = dependency 'value.string.Ascii'

  { value-as-string } = dependency 'prelude.reflection.Value'

  void-as-empty = -> if it is void then '' else it

  get-timeout argv |> read-stdin |> void-as-empty |> string-as-lines |> (* "#lf") |> stdout