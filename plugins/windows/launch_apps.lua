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

  local function moveWindow(corner, delay1, delay2, delay3)
    local timer1 = hs.timer.delayed.new(delay1, function()
      hs.eventtap.keyStroke({},"f13")
    end)
    local timer2 = hs.timer.delayed.new(delay2, function()
      hs.eventtap.keyStroke({},"q")
    end)
    local timer3 = hs.timer.delayed.new(delay3, function()
      hs.eventtap.keyStroke({},corner)
    end)
    timer1:start()
    timer2:start()
    timer3:start()
  end

  local function applicationWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched then
      if appName == "iTerm2" then
        moveWindow("j",0.2,0.5,0.8)
      elseif appName == "Dash" then
        moveWindow("u",2,3,4)
      end
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
