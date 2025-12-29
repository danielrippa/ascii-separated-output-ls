  do ->

    { get-console-window } = dependency 'os.shell.console.Window'

    console-window = get-console-window!

    get-console-width = -> console-window.get-width! - 2  # Simple margin for scrollbar
      
    console-supports-unicode = -> console-window.get-code-page! is 65001

    {
      get-console-width,
      console-supports-unicode
    }