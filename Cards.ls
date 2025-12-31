
  do ->

    { get-boxdrawing-chars } = dependency 'Chars'
    { get-console-width } = dependency 'Console'
    { object-member-names, object-from-arrays, repeat-item } = dependency 'value.Object'
    { string-repeat } = dependency 'value.String'
    { flatten-arrays, repeat-array-item, fold-array-items } = dependency 'value.Array'
    { wrap-text-by-words, wrap-text-by-chars } = dependency 'value.string.Text'
    { string-as-chars } = dependency 'value.string.CodeUnit'

    { value-as-string } = dependency 'prelude.reflection.Value'

    border-padding = 4

    # Get proper character count (not code units)
    char-length = (text) -> (string-as-chars text).length

    create-horizontal-border = (width, start-char, end-char) ->

      { horizontal } = get-boxdrawing-chars!
      "#start-char#{ string-repeat horizontal, width }#end-char"

    create-top-border = (width) -> { nw, ne } = get-boxdrawing-chars! ; create-horizontal-border width, nw, ne

    create-bottom-border = (width) -> { sw, se } = get-boxdrawing-chars! ; create-horizontal-border width, sw, se

    wrap-content-line = (content, total-width) ->

      { vertical } = get-boxdrawing-chars! 
      content-char-length = char-length content
      padding-needed = total-width - content-char-length
      padding = string-repeat ' ', padding-needed
      "#vertical #content#padding #vertical"

    get-max-line-width = (lines) -> fold-array-items lines, 0, (max, line) -> Math.max max, char-length line

    needs-auto-wrapping = (object, label-map) ->

      console-width = get-console-width!

      check-field = (label) ->

        value = object[ label ] ; field-line = "#{ label-map[ label ] }#value"
        field-width = char-length(field-line) + border-padding
        exceeds-console-width = field-width > console-width

        exceeds-console-width

      labels = object-member-names label-map
      for label in labels => return yes if check-field label
      no

    wrap-member-value = (value, available-width, wrap-content-at-words) ->

      wrap-text = if wrap-content-at-words then wrap-text-by-words else wrap-text-by-chars
      wrap-text value, available-width

    get-member-lines = (label, value, available-width, wrap-content-at-words) ->

      wrapped-lines = wrap-member-value value, available-width, wrap-content-at-words
      padding = string-repeat ' ', label.length

      compose-line = (line, index) -> "#{ if index is 0 then label else padding }#line"
      [ compose-line line, index for line, index in wrapped-lines ]

    get-content-lines = (object, label-map, width, wrap-content-at-words) ->

      get-label-width = (member-name) -> label-map[member-name].length
      max-label-width = fold-array-items (object-member-names label-map), 0, (max, name) -> Math.max max, get-label-width name

      compose-member-lines = (member-name) ->

        label = label-map[ member-name ] ; value = object[ member-name ]
        padded-label = label + string-repeat ' ', max-label-width - label.length

        if width isnt void
          available-width = width - max-label-width - border-padding
          get-member-lines padded-label, value, available-width, wrap-content-at-words
        else
          [ "#padded-label#value" ]

      member-lines = [ compose-member-lines member-name for member-name in object-member-names label-map ]
      flatten-arrays member-lines

    compose-card-lines = (content-lines, target-width) ->

      natural-max-width = get-max-line-width content-lines
      
      content-padding = 2 ; vertical-borders = 2 
      
      total-card-overhead = content-padding + vertical-borders
      border-overhead = vertical-borders
      
      if target-width isnt void
        content-width = target-width - total-card-overhead
        border-width = target-width - border-overhead
      else
        content-width = natural-max-width
        border-width = natural-max-width + border-overhead

      compose-content-line = -> wrap-content-line it, content-width
      content-wrapped = [ compose-content-line line for line in content-lines ]

      top-border = create-top-border border-width
      bottom-border = create-bottom-border border-width

      [ top-border ] ++ content-wrapped ++ [ bottom-border ]

    get-wrapping-width = (wrap-content, max-width, needs-wrapping) ->

      console-width = get-console-width!

      switch
        | wrap-content or max-width isnt void
          if max-width isnt void then max-width else console-width
        | needs-wrapping then console-width
        else void

    object-as-card = (object, max-width, wrap-content, wrap-content-at-words) ->

      compose-label-pair = -> [ it, "#it: " ]
      label-pairs = [ compose-label-pair label for label in object-member-names object ]
      label-map = { [key, value] for [key, value] in label-pairs }

      wrapping-width = get-wrapping-width wrap-content, max-width, (needs-auto-wrapping object, label-map)

      content-lines = get-content-lines object, label-map, wrapping-width, wrap-content-at-words

      target-card-width = if max-width isnt void then max-width else void
      compose-card-lines content-lines, target-card-width

    objects-as-cards = (objects, max-width, wrap-content = no, wrap-content-at-words = no) ->

      compose-card = -> object-as-card it, max-width, wrap-content, wrap-content-at-words
      [ compose-card object for object in objects ]

    {
      objects-as-cards,
      object-as-card,
      compose-card-lines,
      get-content-lines,
      wrap-content-line,
      get-max-line-width,
      char-length,
      wrap-member-value,
      get-member-lines,
      get-wrapping-width,
      needs-auto-wrapping
    }