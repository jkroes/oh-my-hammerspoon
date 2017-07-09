-- print(hs.inspect(hs.keycodes.map))

-- Configure HS
if not hs.autoLaunch then hs.autoLaunch = true end
if not hs.menuIcon then hs.menuIcon = true end
if hs.dockIcon then hs.dockIcon = nil end

-- Show enabled hotkeys
hs.hotkey.showHotkeys({"cmd","alt","ctrl"}, "s")

-- Convert capslock to hyper key (replacement for Karabiner-Elements)
package.path = package.path..';foundation/?.lua'
local FRemap = require('foundation_remapping')
local remapper = FRemap.new()
remapper:remap('capslock', 'f13')
remapper:register() -- NOTICE: Remapping is effective until system termination
-- even after quit Hammerspoon. Use remapper:unregister()

-- -- Testing hyper key library
-- package.path = package.path..';hyperex/?.lua'
-- local hyperex = require('hyperex')
-- hx = hyperex.new('f1'):withMessage("testEnter","testExit",0.5)
-- hx:sticky('toggle')
-- hx:bind('x'):to(function() hs.eventtap.keyStroke({}, 'x') end)

-- Weather menubar app
package.path = package.path..';hs-weather/?.lua'
local weather = require("weather")
weather.start()

-- Library
local omh = require('omh-lib')
local find = omh.find

-- Modules
local fnutils = hs.fnutils
local each = fnutils.each
local partial = fnutils.partial
local concat = fnutils.concat
local indexOf = fnutils.indexOf

local eventtap = hs.eventtap
local keyStroke = eventtap.keyStroke

local app = hs.application
local frontmost = app.frontmostApplication
local watcher = app.watcher
local get = app.get
local launchOrFocus = app.launchOrFocus

local screen = hs.screen
local allScreens = screen.allScreens
local mainScreen = screen.mainScreen
local setPrimary = screen.setPrimary

local osascript = hs.osascript
local applescript = osascript.applescript

local iMessage = hs.messages.iMessage

local grid = hs.grid

-- Other local variables
local shift = 0.075

-- Spoons
hs.loadSpoon('reloadConfig')
hs.loadSpoon('sequentialKeys')
hs.loadSpoon('TextClipboardHistory')
hs.loadSpoon('windowManipulation')
local s = spoon
-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
-- http://www.hammerspoon.org/Spoons/URLDispatcher.html

-- reloadConfig
local rC = s.reloadConfig
rC.auto_reload = true
rC.manual_reload_key = {} -- disable manual reload
rC:start() -- start filepath watcher

-- Clipboard
local tCH = s.TextClipboardHistory
tCH.show_in_menubar = false
tCH.paste_on_select = true
tCH.honor_ignoredidentifiers = true -- default; just in case
tCH:start()

-- Determine modal sequence
local sK = s.sequentialKeys
local bindModes = partial(sK.bindModes, sK)
local exitMode = partial(sK.exitSequentialMode, sK)
local modes = sK.modes
local hyper = modes.hyper

local lE = {}
local lA = {}
lay = {}
wM = s.windowManipulation
wM.screens.phrase=find(wM, wM.screens)
wM.halves.phrase=find(wM, wM.halves)
wM.thirds.phrase=find(wM, wM.thirds)
wM.quarters.phrase=find(wM, wM.quarters)
lE.phrase = "epichrome launch"
lA.phrase = "app launch"
lay.phrase = "layout"

bindModes{key="f13", phrase="hyper"} -- named args require brackets
 -- bound to caps lock via Karabiner Elements
bindModes{parent="hyper", key="s", phrase=wM.screens.phrase}
bindModes{parent="hyper", key="h", phrase=wM.halves.phrase}
bindModes{parent="hyper", key="t", phrase=wM.thirds.phrase}
bindModes{parent="hyper", key="q", phrase=wM.quarters.phrase}
bindModes{parent="hyper", key="e", phrase=lE.phrase}
bindModes{parent="hyper", key="a", phrase=lA.phrase}
bindModes{parent="hyper", key="l", phrase=lay.phrase}

-- Bind keys to modes
local hyperKeys -- forward declaration
local function assign(keyDict, fn)
  local mode; if keyDict == hyperKeys then mode = hyper
  else mode = modes[keyDict.phrase]; keyDict.phrase = nil end

  each(keyDict, function(element)
    local mod = {} -- default key modifier
    local key; if element.key then key = element.key -- all else besides...
    else key = element end -- ...window manipulation
    if type(key) == "table" then mod=key[1]; key=key[2] end
    if element.fn then fun = element.fn -- hyper
    else fun = partial(fn, keyDict, element, mode) end -- not hyper
    mode:bind(mod, key, fun)
  end)
end --

hyperKeys = {
  {
    key="c",
    fn=function()
      hs.execute('open ' .. hs.configdir .. '/init.lua')
      exitMode("hyper")
    end
  },
  {
    key="g",
    fn=function()
      launchOrFocus("/Users/justinkroes/Applications/Gmail.app")
      exitMode("hyper")
    end
  },
  {
    key="escape",
    fn=function()
      hs.execute('diskutil unmount /dev/disk2s2')
    end
  },
  {
    key="space",
    fn=partial(keyStroke, {"cmd"}, "`")
  }, -- switch windows
  {
    key="u",
    fn=partial(keyStroke, {}, "pageup")
  }, -- switch windows
  {
    key="d",
    fn=partial(keyStroke, {}, "pagedown")
  }, -- switch windows
  {
    key="z",
    fn=function()
      local frontApp = frontmost()
      local zoom = {"Window", "Zoom"}
      frontApp:selectMenuItem(zoom)
      exitMode("hyper")
    end
  }, -- zoom to retrieve off-screen windows, allowing you to resize them
  {
    key='v',
    fn=function()
      tCH:toggleClipboard()
      exitMode("hyper")
    end
  }, -- contextual copy-paste
  {
    key='m',
    fn=function()
      wM:resizeCurrentWindow(find(wM,wM.maximize))
      exitMode("hyper")
    end
  }, -- maximize focused window
  {
    key={{"cmd"},"m"},
    fn=function()
      exitMode("hyper")
      local as = 'set theResponse to display dialog "Enter message" default '
      .. 'answer "" with icon note buttons {"Cancel", "Continue"} default '
      .. 'button "Continue" \
      return (text returned of theResponse)'
      _,message,_ = applescript(as)
      if message then

        local function messageWatch(appName, eventType, appObject)
          if eventType == watcher.launched or
          eventType == watcher.activated then
            if appName == "Messages" then
              iMessage("9167996697", message)
              get("Messages"):kill()
            end
          end
        end

        local msgWatcher = watcher.new(messageWatch)
        msgWatcher:start()

        launchOrFocus("Messages") -- if application
        -- is closed, then first text will only open the app, not send

      end
    end
  },
  -- {
  --   key = "y",
  --   fn=function()
  --     hs.mjomatic.go({
  --     "CCCCCCCCCCCCCiiiiiiiiiii",
  --     "",
  --     "C Google Chrome",
  --     "i iTerm2"})
  --     exitMode("hyper")
  --   end
  -- },
  {
    key = "'",
    fn=function()
      local gridSize = '4x4'
      local function setGrid()
        local main = mainScreen();
        local frame = main:frame()

        if main:name() == "Color LCD" then -- cracked screen
          frame = main:toUnitRect(frame)
          frame._x = frame._x + shift; frame._w = frame._w - shift
          frame = main:fromUnitRect(frame)
        end
        grid.setGrid(gridSize, main, frame)
      end

      setGrid()
      grid.toggleShow()
    end
  } -- toggle fails if using any of the main keyboard
  -- keys, because they're disabled; see contents of hs.grid.HINTS

  -- I don't automatically exit hyper after moving a window in the grid
  -- If only a single window is selected, set to exit grid mode automatically
  -- Otherwise, need to hit key for grid toggle before key for hyper
  -- because hyper first will disable grid toggle without exiting first
  -- THE ABOVE CAN BE IMPLEMENTED BY INSERTING hs.grid.toggleShow() INTO
  -- Hyper's exit callback
  -- Switching windows (currently bound to 'space') doesn't exit hyper
  -- Use tab to switch between windows
  -- Press a letter twice to resize, or 2 letters to resize in sub-grid
  -- that connects these letters (play around with a 4x4 grid to see)
  -- To move without resize, letter-ENTER
  -- Arrow keys move b/w screens

}
assign(hyperKeys)

concat(lE,
{
  { key = "h", app = "/Users/justinkroes/Applications/GitHub.app" },
  { key = "o", app = "/Users/justinkroes/Applications/Gmail Offline.app" },
})
local lefn = function(dict, element, mode)
  launchOrFocus(element.app)
  exitMode(mode)
end
assign(lE, lefn)

concat(lA,
{
  { key = "a", app = "Atom" },
  { key = "c", app = "Calendar" },
  { key = "d", app = "Dash" },
  { key = "e", app = "Microsoft Excel" },
  --{ key = "g", app = "Google Chrome" },
  { key = "h", app = "Hammerspoon" },
  { key = "i", app = "iTerm" },
  { key = "m", app = "Activity Monitor" },
  { key = "n", app = "nvALT" },
  { key = "p", app = "Microsoft PowerPoint" },
  { key = "r", app = "RStudio" },
  { key = "s", app = "Spotify" },
  { key = "w", app = "Microsoft Word" },
  { key = "z", app = "Zotero" },
  { key = ".", app = "Adobe Acrobat Reader DC" },
}) -- App names, or absolute paths, as shown in Finder/terminal, not app titles
local lafn = function(dict, element, mode)
  -- local function moveWindow(corner, delay1, delay2, delay3)
  --   local timer1 = hs.timer.delayed.new(delay1, function()
  --     keyStroke({},"f13")
  --   end)
  --   local timer2 = hs.timer.delayed.new(delay2, function()
  --     keyStroke({},"q")
  --   end)
  --   local timer3 = hs.timer.delayed.new(delay3, function()
  --     keyStroke({},corner)
  --   end)
  --   timer1:start()
  --   timer2:start()
  --   timer3:start()
  -- end

  -- local function applicationWatcher(appName, eventType, appObject)
  --   if eventType == hs.application.watcher.launched then
  --     if appName == "iTerm2" then
  --       moveWindow("j",0.2,0.5,0.8)
  --     elseif appName == "Dash" then
  --       moveWindow("u",2,3,4)
  --     end
  --   elseif eventType == hs.application.watcher.activated then
  --     appObject:selectMenuItem({"Window", "Bring All to Front"})
  --   end
  -- end
  --
  -- local appWatcher = hs.application.watcher.new(applicationWatcher)
  -- appWatcher:start()
  launchOrFocus(element.app)
  exitMode(mode)
end
assign(lA, lafn)

local all = allScreens()
local screenwatcher = hs.screen.watcher.new(function()
	hs.reload()
end)
screenwatcher:start()
if all[1]:name() ~= "Color LCD" then setPrimary(all[2]) end
if all[1]:name() ~= "Color LCD" then
  error("Expected first element of hs.screen.allScreens() to be the "
  .. "primary screen")
end
wM.shift = 0
twoScreens = {
  {"Dash", nil, all[2], wM:left()},
  {"Gmail", nil, all[2], wM:right()},
}
wM.shift = 0.075
concat(twoScreens, {
  {"Atom", nil, all[1], wM:left()},
  {"Hammerspoon", nil, all[1], wM:bottom_right()},
  {"iTerm2", nil, all[1], wM:bottom_left()},
  {"nvALT", nil, all[1], wM:top_right()}
})
concat(lay,
{
  {
    key = "2",
    layout = twoScreens
  }
})
wM.shift = 0.075
oneScreen = {
  {"Atom", nil, all[1], wM:left()},
  {"Dash", nil, all[1], wM:right()},
  {"Hammerspoon", nil, all[1], wM:bottom_right()},
  {"nvALT", nil, all[1], wM:top_right()},
  {"iTerm2", nil, all[1], wM:bottom_left()},
  {"Gmail", nil, all[1], wM:right()},
  {"Microsoft Word", nil, all[1], wM:left()},
}
concat(lay,
{
  {
    key = "1",
    layout = oneScreen
  }
})

local layfn = function(dict, element, mode)
  hs.layout.apply(element.layout)
  exitMode(mode)
end
assign(lay, layfn)

-- -- Consider using code here: https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
local wmfn = function(dict, windowKey, windowMode)
  wM:resizeCurrentWindow(find(dict, windowKey))
  exitMode(windowMode)
end
assign(wM.screens, wmfn)
assign(wM.halves, wmfn)
assign(wM.thirds, wmfn)
assign(wM.quarters, wmfn)


-- Cheatsheets
-- local ch = {
--   modalPhrase = "cheaters",
--   modalKey = "t",
--   path = "~/Documents/cheatsheets/",
--   navkeys = {"a","s","d","f","g","h","j","k","l",";"},
--   exitAfterOpen = false,
--   git = "g"
-- } -- Note that variable names (aside from path and navkeys) are names of
-- -- individual subdirectories on path. Because the navigation keys may conflict
-- -- with the foldername keys (e.g. git = "g") and the foldername mode is the
-- -- parent of the navigation mode, the same key originally would both open a
-- -- cheatfile and exit the parent foldername mode. I've tweaked
-- -- bindModalKeys2ModeToggle(), so that instead of pressing the same key to exit
-- -- foldername mode, you press "Q", which takes you back to cheat mode, where
-- -- you can specify a new foldername.
--
-- function ch:start()
--   local path = self.path; self.path = nil
--   local navkeys = self.navkeys; self.navkeys = nil
--   local exitAfterOpen = self.exitAfterOpen; self.exitAfterOpen = nil
--   local modalPhrase = self.modalPhrase; self.modalPhrase = nil
--   local modalKey = self.modalKey; self.modalKey = nil
--   bindModes{"hyper", modalKey, modalPhrase}
--   local launchMode = sK.modes[modalPhrase]
--
--   temp = {}
--   hs.fnutils.each(self, function(folderKey)
--     if type(folderKey) ~= "function" then -- exclude methods
--       local folderName = find(self,folderKey)
--       bindModes{phrase=modalPhrase,key=folderKey,parent=folderName,altEscapeKey="Q"}
--
--       path = path .. folderName .. "/"
--       files = omh.listcheatfiles(path) -- Directories are assumed to have .pdf,.png, and/or .md, and the latter are ignored. Files are assumed to be named with letters, numbers, and/or underscores.
--
--       local child = sK.modes[folderName]
--       local numfiles = #files
--       for i = 1,numfiles do
--         child:bind({},navkeys[i],
--         function()
--           hs.execute("open " .. path .. files[i])
--           if exitAfterOpen then exitMode(child) end
--           -- Otherwise "Q" is bound to re-enter cheaters mode, while hyperkey will exit any foldername mode (e.g. "g" for git).
--         end)
--       end
--     end
--   end)
-- end
--
-- ch:start()
