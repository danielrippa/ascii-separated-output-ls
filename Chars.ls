
  do ->

    { console-supports-unicode } = dependency 'Console'
    { single-chars } = dependency 'value.string.unicode.BoxDrawing'
    { object-from-arrays } = dependency 'value.Object'
    { repeat-array-item } = dependency 'value.Array'

    char-names = <[ vertical horizontal nw ne sw se ]>

    single-char = (name) -> single-chars[name].as-string!

    unicode-chars = { [ name, single-char name ] for name in char-names }
    ascii-chars = object-from-arrays char-names, <[ | - ]> ++ (repeat-array-item 4, -> '+')

    get-boxdrawing-chars = -> if console-supports-unicode! then unicode-chars else ascii-chars

    {
      get-boxdrawing-chars
    }