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

-- Spoons
hs.loadSpoon('reloadConfig')
spoon.reloadConfig.auto_reload = true
spoon.reloadConfig.manual_reload_key = {} -- disable manual reload
spoon.reloadConfig:start() -- start filepath watcher

hs.loadSpoon('TextClipboardHistory')
spoon.TextClipboardHistory.show_in_menubar = false
spoon.TextClipboardHistory.paste_on_select = true
spoon.TextClipboardHistory.honor_ignoredidentifiers = true -- default; just in case
spoon.TextClipboardHistory:start()

hs.loadSpoon('sequentialKeys')
local sK = spoon.sequentialKeys

hs.loadSpoon('windowManipulation')
local wM = spoon.windowManipulation
-- !!!!!!!!!!!!!!!!!
-- Requires you to uncheck System Preferences>Mission Control>Displays Have Separate Spaces
wM.x11app = 'Neovim'
-- !!!!!!!!!!!!!!!!!

-- Rebind caps lock to hyper 
-- https://github.com/hetima/hammerspoon-foundation_remapping
package.path = package.path..';foundation/?.lua'
local FRemap = require('foundation_remapping')
remapper = FRemap.new()
remapper:remap('capslock', 'f13')
remapper:register() -- NOTICE: Remapping is effective until system termination
-- even after quit Hammerspoon. Use remapper:unregister()

-- Keys bound to hyper
sK:bindModalKeys{
  name = 'hyper',
  key = 'f13',
  dict = {
    {
      key="c",
      fn=function(mode)
        hs.execute('open ' .. hs.configdir .. '/init.lua')
        mode:exit()
      end
    },
    {
      key="space",
      fn=function(mode)
        sK.keyRestriction:stop() -- Disable modal key restriction to pass through this keypress
        hs.eventtap.keyStroke({"cmd"}, "`")
        sK.keyRestriction:start() -- Reenable restrictions
      end
    }, -- switch windows
    {
      key='v',
      fn=function(mode)
        spoon.TextClipboardHistory:toggleClipboard()
        mode:exit()
      end
    }, -- contextual copy-paste
    {
      key='m',
      fn=function(mode)
        wM:resizeCurrentWindow('maximize')
        mode:exit()
      end
    } -- maximize focused window
  }
}

-- Manage windows: all but maximize
local function windowFun(how, mode)
  wM:resizeCurrentWindow(how)
  mode:exit()
end

sK:bindModalKeys{
  name = 'screens',
  key = 's',
  parent = 'hyper',
  fn = windowFun, 
  dict = {
      { key = 'j', 'screen_left' },
      { key = 'l', 'screen_right' }
  }
}

sK:bindModalKeys{
  name = 'quarters',
  key = 'q',
  parent = 'hyper',
  fn = windowFun, 
  dict = {
      { key = 'j', 'bottom_left' },
      { key = 'k', 'bottom_right' },
      { key = 'u', 'top_left' },
      { key = 'i', 'top_right' }
  }
}

sK:bindModalKeys{
  name = 'halves',
  key = 'h',
  parent = 'hyper',
  fn = windowFun, 
  dict = {
      { key = 'j', 'left' },
      { key = 'l', 'right' },
      { key = 'i', 'top' },
      { key = 'm', 'bottom' }
  }
}
  
-- Launch and focus applications
--hs.application.enableSpotlightForNameSearches(true)
local function launchFun(app, mode)
  hs.application.launchOrFocus(app)
  if app == "Emacs" then -- Emacs doesn't focus via launchOrFocus if already launched
    hs.application.get("Emacs"):activate() 
  end
  mode:exit()
end

sK:bindModalKeys{
  name = 'app launch',
  key = 'a',
  parent = 'hyper',
  fn = launchFun,
  dict = {
    { key = "a", "Atom" },
    { key = "c", "Calendar" },
    { key = "d", "Dash" },
    { key = "e", "Emacs" },
    { key = "i", "iTerm" },
    { key = "m", "Spotify" },
    { key = "n", "nvALT" },
    { key = "p", "PyCharm" },
    { key = "r", "RStudio" },
    { key = "s", "Safari" },
    { key = "w", "Microsoft Word" },
    { key = "z", "Zotero" },
    { key = ".", "Adobe Acrobat Reader DC" },
  }
} -- App names, or absolute paths, as shown in Finder/terminal, not app titles



-- Handling graphical application window running via docker and X11 server
-- TODO: If hs.application.get('XQuartz') is hs.application.frontmostApplication()
--  then e.g. HYPER-q-u should pass the coordinates necessary to fit the upper left
--  portion of the screen. Passing slightly different (-1 in each dimension) coordinates
--  followed by the previous coordinates can activate it similar to launchOrFocus
-- TODO: Remove container when done
-- TODO: Add workspace volume with arg to persist on macos filesystem after work completes or do a git hook or something
--   to prevent work being lost. Alternatively, learn how to restart containers as needed
-- TODO: Install R and python packages in dockerfile
-- TODO: Run neovim in background with -d flag to docker run, so you can use that shell to control docker


-- Reload script if screen changes
local screenwatcher = hs.screen.watcher.new(function()
	hs.reload()
end)
screenwatcher:start()


    

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
