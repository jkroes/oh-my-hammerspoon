-- Inpired by
-- http://thume.ca/2016/07/16/advanced-hackery-with-the-hammerspoon-window-manager/

local tabs = require "plugins.apps.tabs"
local mod = {}

mod.config = {
  apps = {
    "Atom",
    "Google Chrome",
  }
}

--- Initialize the module
function mod.init()

  local c = mod.config
  local a = mod.config.apps
  mod.tabkeys = {}
  local t = mod.tabkeys

  hs.fnutils.each(a, function(element)
    tabs.enableForApp(element)
  end)
  --tabs.enableForApp("Atom")
  --tabs.enableForApp("Google Chrome")

  for i=1,6 do
    t[tostring(i)] = function()
    --t.i = function()
      local app = hs.application.frontmostApplication()
      tabs.focusTab(app,i)
    end
  end

  hs.fnutils.each(t,
  function(element)
    hyper:bind({}, find(t,element),
    function()
      element()
    end)
  end)

end

return mod
