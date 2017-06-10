local omh = require('omh-lib')

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
-- Window management
--- Diego Zamboni <diego@zzamboni.org>

local lA = {
  modalPhrase = "app launch",
  modalKey = "l",
  {"a", "Atom"},
  {"c", "Calendar"},
  {"d", "Dash"},
  {"e", "Microsoft Excel"},
  {"f", "Finder"},
  {"g", "Google Chrome"},
  {"h", "Hammerspoon"},
  {"i", "iTerm"},
  {"m", "Activity Monitor"},
  {"n", "nvALT"},
  {"p", "Microsoft PowerPoint"},
  {"r", "RStudio"},
  {"s", "Spotify"},
  {"w", "Microsoft Word"},
  {"z", "Zotero"},
} -- Get a list of all running app names
-- hs.fnutils.each(hs.application.runningApplications(), function(app)
-- print(app:title()) end)
-- Apparently we should use the actual app name as shown in finder, and an
-- absolute path can also be used. Not the results of the code above...

function lA:start()
  -- Launch and focus apps
  local modalPhrase = self.modalPhrase; self.modalPhrase = nil
  local modalKey = self.modalKey; self.modalKey = nil
  sK:bindMode2Mode("hyper", modalKey, modalPhrase)
  local launchMode = sK.modes[modalPhrase]

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

  hs.fnutils.ieach(self,
  function(element)
    launchMode:bind({}, element[1],
    function()
      local appName = element[2]
      hs.application.launchOrFocus(appName)
      -- hyper.watch = nil -- must come before exit()!!!
      -- launchMode:exit()
      sK:exitSequentialMode(launchMode)
    end)
  end)
end

lA:start()

-- Launch epichrome
lE = {
  modalPhrase = "epichrome launch",
  modalKey = "e",
  {"g", "/Users/justinkroes/Applications/Gmail.app"},
  {"h", "/Users/justinkroes/Applications/GitHub.app"},
}

function lE:start()
  local modalPhrase = self.modalPhrase; self.modalPhrase = nil
  local modalKey = self. modalKey; self.modalKey = nil
  sK:bindMode2Mode("hyper", modalKey, modalPhrase)
  local launchMode = sK.modes[modalPhrase]

  hs.fnutils.ieach(self,
  function(element)
    launchMode:bind({}, element[1],
    function()
      hs.application.launchOrFocus(element[2])
      -- hyper.watch = nil -- must come before exit()!!!
      -- launchMode:exit()
      sK:exitSequentialMode(launchMode)
    end)
  end)
end

lE:start()

-- Grocery lists
hyper:bind({"cmd"}, "m", function()
  sK:exitSequentialMode(hyper)
  local as = 'set theResponse to display dialog "Enter message" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue" \
  return (text returned of theResponse)'
  _,message,_ = hs.osascript.applescript(as)
  if message then
    hs.messages.iMessage("9167996697", message)
    hs.messages.SMS("9167996697", message)
  end
  local timer = hs.timer.delayed.new(3, function() hs.application.get("Messages"):kill() end)
  timer:start()
end)

-- Cheatsheets

-- rC = {
--   modalPhrase = "cheaters",
--   modalKey = "t",
--   path = "~/Documents/cheatsheets/",
--   navkeys = {"a","s","d","f","g","h","j","k","l",";"},
--   exitAfterOpen = false,
--   git = "g"
-- } -- Note that variable names (aside from path and navkeys) are names of individual subdirectories on path
-- -- Because the navigation keys may conflict with the foldername keys (e.g. git = "g") and the foldername mode is the parent of the navigation mode, the same key originally would both open a cheatfile and exit the parent foldername mode. I've tweaked bindModalKeys2ModeToggle(), so that instead of pressing the same key to exit foldername mode, you press "Q", which takes you back to cheat mode, where you can specify a new foldername.
--
-- function rC:start()
--   local path = self.path; self.path = nil
--   local navkeys = self.navkeys; self.navkeys = nil
--   local exitAfterOpen = self.exitAfterOpen; self.exitAfterOpen = nil
--   local modalPhrase = self.modalPhrase; self.modalPhrase = nil
--   local modalKey = self.modalKey; self.modalKey = nil
--   sK:bindMode2Mode("hyper", modalKey, modalPhrase)
--   local launchMode = sK.modes[modalPhrase]
--
--   hs.fnutils.each(self,
--   function(folderKey)
--     -- local child = hs.hotkey.modal.new() -- One modal hotkey per foldername specified in winmod.config
--     -- table.insert(omh.modes, child) -- hyper.watch only exits from modal objects stored in omh.modes, when the hyperkey is pressed.
--     local folderName = omh.find(self,folderKey)
--     print(folderKey)
--     sK:bindMode2Mode(modalPhrase, folderKey, folderName, false, true)
--
--     path = path .. folderName .. "/"
--     files = omh.listcheatfiles(path) -- Directories are assumed to have .pdf,.png, and/or .md, and the latter are ignored. Files are assumed to be named with letters, numbers, and/or underscores.
--
--     local child = sK.modes[folderName]
--     local numfiles = #files
--     for i = 1,numfiles do
--       child:bind({},navkeys[i],
--       function()
--         hs.execute("open " .. path .. files[i])
--         if exitAfterOpen then hyper.watch = nil; child:exit() end
--         -- Otherwise "Q" is bound to re-enter cheaters mode, while hyperkey will exit any foldername mode (e.g. "g" for git).
--       end)
--     end
--   end)
-- end
--
-- rC:start()

-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
-- http://www.hammerspoon.org/Spoons/URLDispatcher.html
