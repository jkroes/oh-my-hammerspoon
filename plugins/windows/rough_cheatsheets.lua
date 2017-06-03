-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
  path = "~/Documents/cheatsheets/",
  navkeys = {"a","s","d","f","g","h","j","k","l",";"},
  git = "g"
}

--- Initialize the module

function winmod.init()
  local c = winmod.config
  local path = c.path
  local navkeys = c.navkeys
  c.path = nil -- allow easy looping
  c.navkeys = nil

  hs.fnutils.each(c,
  function(element)
    local hyper_local = hs.hotkey.modal.new() -- One modal hotkey per foldername specified in winmod.config
    bindModalKeys2ModeToggle(hyper7, hyper_local, element, find(c,element), true)

    local key = find(c,element)
    path = path .. key .. "/"
    files = listcheatfiles(path) -- Directories are assumed to have .pdf,.png, and/or .md, and the latter are ignored. Files are assumed to be named with letters, numbers, and/or underscores.

    local numfiles = #files
    for i = 1,numfiles do
      --hyper_local:bind({}, string.format(i),
      hyper_local:bind({},navkeys[i],
      function()
        hs.execute("open " .. path .. files[i])
        --print("open " .. path .. files[i])
        hyper_local:exit()
        hyper7:exit()
        hyper:exit()
      end)
    end
  end)
end

return winmod

--TODO: Show available shortcuts or at least cheat titles in a window when the mode is entered, likely via hs.notify.show's information parameter.
