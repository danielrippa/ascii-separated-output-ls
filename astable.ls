
  { read-stdin, stdout-lines, stdout-lf } = dependency 'os.shell.IO'
  { script-arguments: argv } = dependency 'os.shell.Script'
  { get-timeout, parse-card-args } = dependency 'Args'
  { deserialize-objects } = dependency 'value.string.AsciiSeparators'
  { objects-as-table: as-table } = dependency 'Table'

  void-as-empty = -> if it is void then '' else it

  { wrap-enabled: wrap-content, max-width, word-wrap-enabled: wrap-content-at-words } = parse-card-args argv
  objects-as-table = (objects) -> as-table objects, max-width, wrap-content, wrap-content-at-words

  output-table = (table-lines) -> stdout-lines table-lines ; stdout-lf!

  get-timeout argv |> read-stdin |> void-as-empty |> deserialize-objects |> objects-as-table |> output-table