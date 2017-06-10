---- Configuration file management
---- Original code from http://www.hammerspoon.org/go/#fancyreload

local obj={}
local configFileWatcher

obj.auto_reload = true
obj.manual_reload_key = {{"cmd", "alt", "ctrl"}, "r"}

-- Automatic config reload if any files in ~/.hammerspoon change
function reloadConfig(files)
   local doReload = false
   for _,file in pairs(files) do
      if file:sub(-4) == ".lua" and (not string.match(file, '/[.]#')) then
         doReload = true
      end
   end
   if doReload then
      hs.reload()
   end
end

function obj:start()

  if self.auto_reload then
    configFileWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
    configFileWatcher:start()
  end

  -- Manual config reload
  if next(self.manual_reload_key) then
    hs.hotkey.bind(self.manual_reload_key[1], self.manual_reload_key[2], hs.reload)
  end

end

return obj
