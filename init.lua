-- https://github.com/Hammerspoon/hammerspoon/issues/1268
-- Open init.lua in ZeroBrane Studio
-- Project | Start Debugger Server
-- Reload HS config
--[[local ZBS = "/Applications//ZeroBraneStudio.app/Contents/ZeroBraneStudio"
package.path = package.path .. ";" .. ZBS .. "/lualibs/?/?.lua;" .. ZBS .. "/lualibs/?.lua"
package.cpath = package.cpath .. ";" .. ZBS .. "/bin/?.dylib;" .. ZBS .. "/bin/clibs53/?.dylib"
require("mobdebug").start()]]

-- print(hs.inspect(hs.keycodes.map))

-- Based on communications with Andrew Williams on how to fix a broken screen
-- Note that this requires me to change the shift of the windowsManipulation
-- module. I will comment out the previous lines that are not redundant.
-- hs.screen.primaryScreen():setMode(1920, 1080, 1)

-- hs.inspect(hs.screen.primaryScreen():availableModes())

-- Configure HS
if not hs.autoLaunch then hs.autoLaunch = true end
if not hs.menuIcon then hs.menuIcon = true end
if hs.dockIcon then hs.dockIcon = nil end

-- Show enabled hotkeys (hold CMD-ALT-CRL s)
hs.hotkey.showHotkeys({"cmd","alt","ctrl"}, "s")

-- -- Testing hyper key library
-- package.path = package.path..';hyperex/?.lua'
-- local hyperex = require('hyperex')
-- hx = hyperex.new('f1'):withMessage("testEnter","testExit",0.5)
-- hx:sticky('toggle')
-- hx:bind('x'):to(function() hs.eventtap.keyStroke({}, 'x') end)

-- Library
local omh = require('omh-lib')

-- Modules
hs.loadSpoon('reloadConfig')
spoon.reloadConfig.auto_reload = true
spoon.reloadConfig.manual_reload_key = {} -- disable manual reload
spoon.reloadConfig:start() -- start filepath watcher

hs.loadSpoon('TextClipboardHistory')
spoon.TextClipboardHistory.show_in_menubar = false
spoon.TextClipboardHistory.paste_on_select = true
spoon.TextClipboardHistory.honor_ignoredidentifiers = true -- default; just in case
spoon.TextClipboardHistory:start()

-- Determine modal sequence
hs.loadSpoon('sequentialKeys')
-- Passing object to its method via partial allows for calling method
-- similar to a function, without colon syntax
local bindModes = hs.fnutils.partial(spoon.sequentialKeys.bindModes,
				     spoon.sequentialKeys)
local exitMode = hs.fnutils.partial(spoon.sequentialKeys.exitSequentialMode,
				    spoon.sequentialKeys)

-- https://github.com/hetima/hammerspoon-foundation_remapping
package.path = package.path..';foundation/?.lua'
local FRemap = require('foundation_remapping')
remapper = FRemap.new()
remapper:remap('capslock', 'f13')
remapper:register() -- NOTICE: Remapping is effective until system termination
-- even after quit Hammerspoon. Use remapper:unregister()
-- Binding for the hyper key (rebound to capslock by remapper)
spoon.sequentialKeys:bindHyper("f13")

local lA = {}
lA.phrase = "app launch"
bindModes{parent="hyper", key="a", phrase=lA.phrase}

hs.loadSpoon('windowManipulation')
local wM = spoon.windowManipulation
wM.screens.phrase = omh.find(wM, wM.screens)
wM.halves.phrase = omh.find(wM, wM.halves)
wM.quarters.phrase = omh.find(wM, wM.quarters)
bindModes{parent="hyper", key="s", phrase=wM.screens.phrase}
bindModes{parent="hyper", key="h", phrase=wM.halves.phrase}
bindModes{parent="hyper", key="q", phrase=wM.quarters.phrase}

-- Bind keys to modes
local hyperKeys -- forward declaration
local function assign(keyDict, fn)
   local mode
   if keyDict == hyperKeys then mode = spoon.sequentialKeys.modes.hyper
   else mode = spoon.sequentialKeys.modes[keyDict.phrase]; keyDict.phrase = nil end

  hs.fnutils.each(keyDict, function(element)
    local mod = {} -- default key modifier
    local key; if element.key then key = element.key -- all else besides...
    else key = element end -- ...window manipulation
    if type(key) == "table" then mod=key[1]; key=key[2] end
    if element.fn then fun = element.fn -- hyper
    else fun = hs.fnutils.partial(fn, keyDict, element, mode) end -- not hyper
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
    key="space",
    fn=function()
      spoon.sequentialKeys.rest:stop()
      hs.eventtap.keyStroke({"cmd"}, "`")
      spoon.sequentialKeys.rest:start()
    end
  }, -- switch windows
  {
    key='v',
    fn=function()
      spoon.TextClipboardHistory:toggleClipboard()
      exitMode("hyper")
    end
  }, -- contextual copy-paste
  {
    key='m',
    fn=function()
      wM:resizeCurrentWindow(omh.find(wM,wM.maximize))
      exitMode("hyper")
    end
  } -- maximize focused window
}
assign(hyperKeys)

--hs.application.enableSpotlightForNameSearches(true)

hs.fnutils.concat(lA,
{
  { key = "a", app = "Atom" },
  { key = "c", app = "Calendar" },
  { key = "d", app = "Dash" },
  --{ key = "g", app = "Google Chrome" },
  { key = "h", app = "Hammerspoon" },
  { key = "i", app = "iTerm" },
  { key = "m", app = "Spotify"},
  -- { key = "m", app = "Activity Monitor" },
  { key = "n", app = "nvALT" },
  { key = "p", app = "PyCharm" },
  { key = "r", app = "RStudio" },
  { key = "s", app = "Safari" },
  { key = "w", app = "Microsoft Word" },
  { key = "z", app = "Zotero" },
  { key = ".", app = "Adobe Acrobat Reader DC" },
}) -- App names, or absolute paths, as shown in Finder/terminal, not app titles
local lafn = function(dict, element, mode)
  hs.application.launchOrFocus(element.app)
  exitMode(mode)
end
assign(lA, lafn)

-- launchOrFocus won't focus an already launched Emacs!
spoon.sequentialKeys.modes["app launch"]:bind({}, "e",
  function()
    hs.application.launchOrFocus("Emacs")
    hs.application.get("Emacs"):activate()
    exitMode("app launch")
  end
                                            )

-- Reload script if screen changes
local screenwatcher = hs.screen.watcher.new(function()
	hs.reload()
end)
screenwatcher:start()

local wmfn = function(dict, windowKey, windowMode)
  wM:resizeCurrentWindow(omh.find(dict, windowKey))
  exitMode(windowMode)
end
assign(wM.screens, wmfn)
assign(wM.halves, wmfn)
assign(wM.quarters, wmfn)

-- Window filter to swap cmd with ctrl key in Pycharm, for consistency of MacOS keymap with Windows keymap.
--remapper2 = FRemap.new()
--local function swapCMDWithCTRL()
--  remapper:unregister()
--  remapper2:remap('capslock', 'f13')
--  remapper2:remap('lcmd', 'lctrl')
--  remapper2:remap('lctrl', 'lcmd')
--  remapper2:remap('rcmd', 'rctrl')
--  remapper2:remap('rctrl', 'rcmd')
--  remapper2:register()
--end

--local function unswapCMDWithCTRL()
--  remapper2:unregister()
--  remapper:register()
--end

--local charmWindowFilter = hs.window.filter.new(false):setAppFilter('PyCharm')
--charmWindowFilter:subscribe(hs.window.filter.windowFocused, swapCMDWithCTRL)
--charmWindowFilter:subscribe(hs.window.filter.windowUnfocused, unswapCMDWithCTRL)

-- Just in case I didn't understand the API as well as I thought
-- local all = allScreens()
-- if hs.screen.primaryScreen() ~= all[1] then
--   error("I thought the primary screen was always the first element of hs.screen.allScreens(). Wtf")
-- end

