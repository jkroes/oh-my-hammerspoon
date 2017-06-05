-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local winmod = {}

winmod.config = {
  {"g", "Google Chrome"},
}

--- Initialize the module
function winmod.init()

  -- Launch and focus apps
  local c = winmod.config
  local hyper = omh.modes[1]
  local parent = omh.modes[2]

  local function applicationWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched then
      --print(2+2) -- example to demonstrate this works
      --Need to implement: appObject:window move to location
      -- if appName == "iTerm" then
      --   appObject:focusedWindow.
    elseif eventType == hs.application.watcher.activated then
      appObject:selectMenuItem({"Window", "Bring All to Front"})
    end
  end
  local appWatcher = hs.application.watcher.new(applicationWatcher)
  appWatcher:start()

  hs.fnutils.ieach(c,
  function(element)
    parent:bind({}, element[1],
    function()
      local appName = element[2]
      hs.application.launchOrFocus(appName)
      hyper.watch = nil -- must come before exit()!!!
      parent:exit()
    end)
  end)

end

return winmod
