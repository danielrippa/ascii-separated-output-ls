
  { read-stdin, stdout } = dependency 'os.shell.IO'
  { script-arguments: argv } = dependency 'os.shell.Script'
  { string-as-lines } = dependency 'value.string.Text'
  { get-timeout } = dependency 'Args'
  { control-chars: { lf } } = dependency 'value.string.Ascii'

  void-as-empty = -> if it is void => '' else it

  get-timeout argv |> read-stdin |> void-as-empty |> string-as-lines |> (* "#lf") |> stdout