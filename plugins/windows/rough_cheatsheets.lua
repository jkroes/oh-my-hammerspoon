-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local mod = {}

mod.config = {
  path = "~/Documents/cheatsheets/",
  navkeys = {"a","s","d","f","g","h","j","k","l",";"},
  git = "g"
}

--- Initialize the module
function mod.init()
  local c = mod.config
  local path = c.path
  local navkeys = c.navkeys
  c.path = nil -- allow easy looping
  c.navkeys = nil -- same
  local hyper = omh.modes[1]
  parent = omh.modes[7]

  hs.fnutils.each(c,
  function(element)
    local child = hs.hotkey.modal.new() -- One modal hotkey per foldername specified in winmod.config
    table.insert(omh.modes, child) -- hyper.watch only exits from modal objects stored in omh.modes, when the hyperkey is pressed.
    local phrase = omh.find(c,element)
    omh.bindMode2Mode(omh.modes, 7, child, element, phrase, true)

    path = path .. phrase .. "/"
    files = omh.listcheatfiles(path) -- Directories are assumed to have .pdf,.png, and/or .md, and the latter are ignored. Files are assumed to be named with letters, numbers, and/or underscores.

    local numfiles = #files
    for i = 1,numfiles do
      child:bind({},navkeys[i],
      function()
        hs.execute("open " .. path .. files[i])
        --child:exit(); hyper.watch = nil -- Enable if you want to exit after opening one cheatsheet
        -- Otherwise "Q" is bound to enter cheaters mode, while hyperkey will exit any foldername mode (e.g. "g" for git).
      end)
    end
  end)
end

return mod

--TODO: Show available shortcuts or at least cheat titles in a window when the mode is entered, likely via hs.notify.show's information parameter.
