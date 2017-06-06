-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local mod = {}

mod.config = {
}

--- Initialize the module
function mod.init()
  local c = mod.config
  local path = c.path; c.path = nil
  local navkeys = c.navkeys; c.navkeys = nil
  local exitAfterOpen = c.exitAfterOpen; c.exitAfterOpen = nil
  local modalPhrase = c.modalPhrase; c.modalPhrase = nil
  local modalKey = c. modalKey; c.modalKey = nil
  local hyper = omh.modes.hyper
  omh.bindMode2Mode(hyper, modalKey, modalPhrase)
  local launchMode = omh.modes[modalPhrase]


  hs.fnutils.each(c,
  function(folderKey)
    -- local child = hs.hotkey.modal.new() -- One modal hotkey per foldername specified in winmod.config
    -- table.insert(omh.modes, child) -- hyper.watch only exits from modal objects stored in omh.modes, when the hyperkey is pressed.
    local folderName = omh.find(c,folderKey)
    omh.bindMode2Mode(omh.modes[modalPhrase], folderKey, folderName, false, true)

    path = path .. folderName .. "/"
    files = omh.listcheatfiles(path) -- Directories are assumed to have .pdf,.png, and/or .md, and the latter are ignored. Files are assumed to be named with letters, numbers, and/or underscores.

    local child = omh.modes[folderName]
    local numfiles = #files
    for i = 1,numfiles do
      child:bind({},navkeys[i],
      function()
        hs.execute("open " .. path .. files[i])
        if exitAfterOpen then hyper.watch = nil; child:exit() end
        -- Otherwise "Q" is bound to re-enter cheaters mode, while hyperkey will exit any foldername mode (e.g. "g" for git).
      end)
    end
  end)
end

return mod

--TODO: Show available shortcuts or at least cheat titles in a window when the mode is entered, likely via hs.notify.show's information parameter.
