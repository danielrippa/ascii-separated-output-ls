
  do ->

    { is-empty-array, each-array-item, fold-array-items, flatten-arrays } = dependency 'value.Array'
    { get-boxdrawing-chars } = dependency 'Chars'
    { string-repeat } = dependency 'value.String'
    { wrap-text-by-words, wrap-text-by-chars } = dependency 'value.string.Text'
    { stroke-kind, single-chars } = dependency 'value.string.unicode.BoxDrawing'
    { object-member-names } = dependency 'value.Object'
    { get-console-width } = dependency 'Console'

    { none, single } = stroke-kind
    { vertical-and-horizontal, t-top, t-bottom, t-left, t-right } = single-chars

    t-junctions = [t-top, t-bottom, t-left, t-right, vertical-and-horizontal]
    [top-t, bottom-t, left-t, right-t, cross] = [ it.as-string! for it in t-junctions ]

    get-string-length = (object, column) -> "#{ object[ column ] }".length

    get-column-width = (objects, column) ->

      lengths = [ (get-string-length object, column) for object in objects ]
      fold-array-items lengths, 0, (max, length) -> Math.max max, length

    get-total-width = (objects, columns) ->

      left-border = 2 ; column-padding = 2

      add-column = (total, column) ->

        column-width = get-column-width objects, column
        total + column-width + column-padding

      columns-total = fold-array-items columns, 0, add-column

      left-border + columns-total

    get-wrapping-width = (wrap-content, max-width, needs-wrapping) ->

      console-width = get-console-width! ; switch

        | wrap-content or max-width isnt void

          if max-width isnt void => max-width else console-width

        | needs-wrapping => console-width

        else void

    make-natural-width = (objects, column) -> [ column, (get-column-width objects, column) ]

    make-fixed-width = (column, width) -> [ column, width ]

    get-natural-column-widths = (objects, columns) -> { [ column, get-column-width objects, column ] for column in columns }

    get-fixed-column-widths = (columns, table-width) ->

      available-width = table-width - (columns.length + 1) * 2
      column-width = Math.floor available-width / columns.length

      { [ column, column-width ] for column in columns }

    get-column-widths = (objects, columns, table-width) ->

      if table-width is void
        get-natural-column-widths objects, columns
      else
        get-fixed-column-widths columns, table-width

    wrap-cell = (content, width, wrap-words) ->

      wrap-text = if wrap-words then wrap-text-by-words else wrap-text-by-chars
      wrap-text content, width

    pad-line = (line, width) ->

      padding-needed = width - line.length
      padding = string-repeat ' ', padding-needed

      "#line#padding"

    get-padded-line = (wrapped-column, width, line-index) ->

      has-content = line-index < wrapped-column.length

      if has-content

        line = wrapped-column[ line-index ]
        pad-line line, width

      else

        string-repeat ' ', width

    get-column-part = (column-lines, row-index) -> content = column-lines[ row-index ] ; " #content "

    get-wrapped-columns = (row-data, columns, column-widths, wrap-words) ->

      make-wrapped-column = (column) ->

        content = row-data[ column ] ; width = column-widths[ column ]
        wrap-cell content, width, wrap-words

      [ make-wrapped-column column for column in columns ]

    get-max-column-height = (wrapped-columns) ->

      heights = [ (wrapped-column.length) for wrapped-column in wrapped-columns ]

      fold-array-items heights, 0, (max, height) -> Math.max max, height

    get-padded-columns = (wrapped-columns, columns, column-widths, max-height) ->

      compose-padded-column = (wrapped-column, index) ->

        column = columns[ index ] ; width = column-widths[ column ]

        make-padded-line = -> get-padded-line wrapped-column, width, it

        [ (make-padded-line index) for index til max-height ]

      [ (compose-padded-column wrapped-column, index) for wrapped-column, index in wrapped-columns ]

    compose-row-at-index = (padded-columns, row-index) ->

      { vertical } = get-boxdrawing-chars!

      get-column-part = (column-lines) -> column-content = column-lines[ row-index ] ; " #column-content "

      column-parts = [ (get-column-part column-lines) for column-lines in padded-columns ] * "#vertical"

      "#vertical#column-parts#vertical"

    compose-table-row = (row-data, column-widths, columns, wrap-words) ->

      wrapped-columns = get-wrapped-columns row-data, columns, column-widths, wrap-words

      max-height = get-max-column-height wrapped-columns
      padded-columns = get-padded-columns wrapped-columns, columns, column-widths, max-height

      [ (compose-row-at-index padded-columns, index) for index til max-height ]

    compose-separator = (left, middle, right, column-widths, columns) ->

      { horizontal } = get-boxdrawing-chars!

      parts = [ left ] ; each-array-item columns, (column, index) ->

        column-width = column-widths[ column ]
        horizontal-line = string-repeat horizontal, column-width + 2
        is-last-column = index is columns.length - 1

        separator = if is-last-column then right else middle

        parts.push horizontal-line, separator

      parts * ''

    get-top-and-bottom-separators = (column-widths, columns) ->

      { nw, ne, sw, se } = get-boxdrawing-chars!

      top: compose-separator nw, top-t, ne, column-widths, columns
      bottom: compose-separator sw, bottom-t, se, column-widths, columns

    column-as-string-pair = (object, column) -> [ column, "{ object[ column ] }" ]

    get-row-data = (object, columns) -> { [ column, "#{object[column]}" ] for column in columns }  # Remove make-key-value-pairs line

    objects-as-rows = (objects, columns, column-widths, wrap-words) ->

      row-object = ->

        row-data = get-row-data it, columns
        compose-table-row row-data, column-widths, columns, wrap-words

      [ (row-object object) for object in objects ]

    get-separators-and-table-rows = (objects, columns, table-width, wrap-content, wrap-words) ->

      column-widths = get-column-widths objects, columns, table-width

      separators = get-top-and-bottom-separators column-widths, columns

      table-rows = objects-as-rows objects, columns, column-widths, wrap-words

      { separators, table-rows: flatten-arrays table-rows }

    needs-auto-wrapping = (objects, columns) ->

      table-width = get-total-width objects, columns
      console-width = get-console-width!

      table-width > console-width

    get-columns-width-and-wrap-mode = (objects, max-width, wrap-content) ->

      [ first-object ] = objects ; columns = object-member-names first-object

      needs-wrapping = needs-auto-wrapping objects, columns

      table-width = get-wrapping-width wrap-content, max-width, needs-wrapping

      wrap-content = if needs-wrapping and not wrap-content then yes else wrap-content

      { columns, table-width, wrap-content }

    #

    objects-as-table = (objects, max-width, wrap-content = no, wrap-words = no) ->

      return [] if is-empty-array objects

      [ first-object ] = objects ; columns = object-member-names first-object
      header-object = { [ column, column ] for column in columns }
      objects-with-header = [ header-object ] ++ objects

      { columns, table-width, wrap-content } = get-columns-width-and-wrap-mode objects-with-header, max-width, wrap-content
      { separators, table-rows } = get-separators-and-table-rows objects-with-header, columns, table-width, wrap-content, wrap-words
      { top: top-separator, bottom: bottom-separator } = separators

      column-widths = get-column-widths objects-with-header, columns, table-width
      header-separator = compose-separator left-t, cross, right-t, column-widths, columns

      [ top-separator, table-rows.0, header-separator ] ++ table-rows[1 to] ++ [ bottom-separator ]

    {
      objects-as-table
    }