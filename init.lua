-- Reload
hs.loadSpoon('reloadConfig')
local s = spoon
local rC = s.reloadConfig
rC.auto_reload = true
rC.manual_reload_key = {}
rC:start()

-- Hyper
hs.loadSpoon('sequentialKeys')
local sK = s.sequentialKeys
--sK.notifications = false
sK:bindMode2Mode("hyper", "f13", "HYPER", true) -- bound to caps lock via
-- Karabiner Elements
local hyper = sK.modes.hyper

-- Clipboard
hs.loadSpoon('TextClipboardHistory')
local TCH = s.TextClipboardHistory
TCH.show_in_menubar = false
TCH.paste_on_select = true
TCH.honor_ignoredidentifiers = true -- default; just in case
TCH:start()
hyper:bind({}, 'v', function()
  TCH:toggleClipboard()
  sK:exitSequentialMode("hyper")
end)

-- Switch windows
hyper:bind({}, "space", function()
  -- print(hs.inspect(hs.keycodes.map))
  hs.eventtap.keyStroke({"cmd"}, "`")
  sK:exitSequentialMode("hyper")
end)

-- Zoom
hyper:bind({}, "z", function()
  local frontApp = hs.application.frontmostApplication()
  local zoom = {"Window", "Zoom"}
  frontApp:selectMenuItem(zoom)
  --frontApp:selectMenuItem(zoom) -- a second time returns to previous size, but now the window will be on-screen
  sK:exitSequentialMode("hyper")
end)

-- Windows manipulations
hs.loadSpoon('windowManipulation')
local wM = s.windowManipulation
local m = wM.maximize
local s = wM.screens -- these will break if the names are ever changed in the config file. Need to make this robust.
local h = wM.halves
local t = wM.thirds
local q = wM.quarters

hyper:bind({}, m, function()
  wM.resizeCurrentWindow(wM.find(wM,m))
  sK:exitSequentialMode("hyper")
end)

local function assign(moveType)
  -- Create movement modes and bind to hyper
  local modalKey = moveType.modalKey; moveType.modalKey = nil
  local modalPhrase = wM.find(wM, moveType)
  sK:bindMode2Mode("hyper", modalKey, modalPhrase)
  local mode = sK.modes[modalPhrase]
  -- Bind keys to movement modes
  hs.fnutils.each(moveType, function(movement)
    mode:bind({}, movement, function()
      wM.resizeCurrentWindow(wM.find(moveType, movement))
      sK:exitSequentialMode(mode)
    end)
  end)
end

assign(s)
assign(h)
assign(t)
assign(q)

-- Launch apps




-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
-- http://www.hammerspoon.org/Spoons/URLDispatcher.html

--require("oh-my-hammerspoon")

-- Load modules
--load_plugins({
  --"apps.windowtabs",
  --"windows.launch_apps",
  --"windows.launch_epichrome",
  --"windows.rough_cheatsheets",
  --"windows.screen_rotate",
  --"misc.grocery_list",
  --"misc.statuslets",
  --"misc.url_handling" --Even though this wasn't enabled, every reload would ask to use hs as my default browser. Then it stopped. Chrome has also been crashing. The app wouldn't open, or would throw other weird error msgs. Now that the file's code is commented out, things seem OK.
--})
