-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local mod = {}

mod.config = {
}

--- Initialize the module
function mod.init()

  -- Launch and focus apps
  local c = mod.config
  --print(hs.inspect(c))
  local modalPhrase = c.modalPhrase; c.modalPhrase = nil
  local modalKey = c. modalKey; c.modalKey = nil
  local hyper = omh.modes.hyper
  omh.bindMode2Mode(hyper, modalKey, modalPhrase)
  local launchMode = omh.modes[modalPhrase]

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
    launchMode:bind({}, element[1],
    function()
      local appName = element[2]
      hs.application.launchOrFocus(appName)
      hyper.watch = nil -- must come before exit()!!!
      launchMode:exit()
    end)
  end)


end

return mod
