-- print(hs.inspect(hs.keycodes.map))
-- package.path = package.path..';<path>?.lua'

-- Show enabled hotkeys
hs.hotkey.showHotkeys({"cmd","alt","ctrl"}, "s")

-- Library
local omh = require('omh-lib')
local find = omh.find

-- Modules
local fnutils = hs.fnutils
local each = fnutils.each
local partial = fnutils.partial
local concat = fnutils.concat

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

local osascript = hs.osascript
local applescript = osascript.applescript

local iMessage = hs.messages.iMessage

local grid = hs.grid

-- Other local variables
local all = allScreens()
local shift = 0.075

-- Spoons
hs.loadSpoon('reloadConfig')
hs.loadSpoon('sequentialKeys')
hs.loadSpoon('TextClipboardHistory')
hs.loadSpoon('windowManipulation')
local s = spoon
local rC = s.reloadConfig
local sK = s.sequentialKeys
local bindModes = partial(sK.bindModes, sK)
local exitMode = partial(sK.exitSequentialMode, sK)
local modes = sK.modes
local hyper = modes.hyper
local tCH = s.TextClipboardHistory
local wM = s.windowManipulation
local lE = {}
local lA = {}
local lay = {}
-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
-- http://www.hammerspoon.org/Spoons/URLDispatcher.html

-- reloadConfig
rC.auto_reload = true
rC.manual_reload_key = {} -- disable manual reload
rC:start() -- start filepath watcher

-- Clipboard
tCH.show_in_menubar = false
tCH.paste_on_select = true
tCH.honor_ignoredidentifiers = true -- default; just in case
tCH:start()

-- Determine modal sequence
wM.screens.phrase=find(wM, wM.screens)
wM.halves.phrase=find(wM, wM.halves)
wM.thirds.phrase=find(wM, wM.thirds)
wM.quarters.phrase=find(wM, wM.quarters)
lE.phrase = "epichrome launch"
lA.phrase = "app launch"
lay.phrase = "layout"

bindModes{key="f13", phrase="HYPER"} -- named args require brackets
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
    key="space",
    fn=partial(keyStroke, {"cmd"}, "`")
  }, -- switch windows
  {
    key="z",
    fn=function()
      local frontApp = frontmost()
      local zoom = {"Window", "Zoom"}
      frontApp:selectMenuItem(zoom)
      frontApp:selectMenuItem(zoom)
      exitMode()
    end
  }, -- zoom to retrieve off-screen windows
  {
    key='v',
    fn=function()
      tCH:toggleClipboard()
      exitMode()
    end
  }, -- contextual copy-paste
  {
    key='m',
    fn=function()
      wM.resizeCurrentWindow(find(wM,wM.maximize))
      exitMode()
    end
  }, -- maximize focused window
  {
    key={{"cmd"},"m"},
    fn=function()
      exitMode()
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
  --     exitMode()
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
  { key = "g", app = "/Users/justinkroes/Applications/Gmail.app" },
  { key = "h", app = "/Users/justinkroes/Applications/GitHub.app" },
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
  { key = "g", app = "Google Chrome" },
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

concat(lay,
{
  {
    key = "2", -- dual-screen
    layout = {
      {"Atom", nil, all[1], hs.layout.left50},
      {"Hammerspoon", nil, all[1], {1/2,1/2,1/2,1/2}},
      {"iTerm2", nil, all[1], {1/2,0,1/2,1/2}},
      {"nvALT", nil, all[1], {1/2,1/2,1/2,1/2}},
      -- {"Dash", nil, all[2], {shift,1/2,1-shift,1/2}},
      -- {"Google Chrome", nil, all[2], {shift,0,1-shift,1/2}},
      {"Dash", nil, all[2], {shift,0,(1-shift)/2,1}},
      {"Google Chrome", nil, all[2], {(1-shift)/2+shift,0,(1-shift)/2,1}},
    }
  },
  { key = "1", -- single-screen
    layout = {
      {"Atom", nil, all[1], {shift,0,(1-shift)/2,1}},
      {"Hammerspoon", nil, all[1], {shift+(1-shift)/2,1/2,(1-shift)/2,1/2}},
      {"nvALT", nil, all[1], {shift+(1-shift)/2,1/2,(1-shift)/2,1/2}},
      {"iTerm2", nil, all[1], {shift+(1-shift)/2,0,(1-shift)/2,1/2}},
      {"Dash", nil, all[1], {shift+(1-shift)/2,0,1-(shift+(1-shift)/2),1}},
      {"Google Chrome", nil, all[1], {shift,0,(1-shift)/2,1}},
    }
  }
})
local layfn = function(dict, element, mode)
  hs.layout.apply(element.layout)
  exitMode(mode)
end
assign(lay, layfn)

-- Consider using code here: https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
local wmfn = function(dict, windowKey, windowMode)
  wM.resizeCurrentWindow(find(dict, windowKey))
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
--   bindModes("hyper", modalKey, modalPhrase)
--   local launchMode = sK.modes[modalPhrase]
--
--   temp = {}
--   hs.fnutils.each(self, function(folderKey)
--     if type(folderKey) ~= "function" then -- exclude methods
--       local folderName = find(self,folderKey)
--       bindModes(modalPhrase, folderKey, folderName, false, true)
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
--
