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
local sK = spoon.sequentialKeys -- Compare to hetima/hammerspoon-hyperex sometime

hs.loadSpoon('windowManipulation')
local wM = spoon.windowManipulation
-- !!!!!!!!!!!!!!!!!
-- Requires you to uncheck System Preferences>Mission Control>Displays Have Separate Spaces
-- NOTE: See the windowManipulation spoon code. I believe this is used to
-- interact with X-based nvim-qt started after running dockervim's ./nvim.fish
-- NOTE: I think I used to have nvim-qt installed in docker. I stopped using
-- nvim-qt, since I could still spawn R plots in an X window from within
-- terminal nvim in a docker instance.
-- wM.x11app = 'Neovim'
-- !!!!!!!!!!!!!!!!!

-- Rebind caps lock to hyper
-- https://github.com/hetima/hammerspoon-foundation_remapping
package.path = package.path..';/Users/jkroes/.hammerspoon/foundation/?.lua'
local FRemap = require('foundation_remapping')
remapper = FRemap.new()
remapper:remap('capslock', 'f13')
remapper:register() -- NOTICE: Remapping is effective until system termination
-- even after quit Hammerspoon. Use remapper:unregister()

-- Window filter to swap cmd with ctrl key in Pycharm, for consistency of MacOS keymap with Windows keymap.
-- remapper2 = FRemap.new()
-- local function swapCMDWithCTRL()
--  print('on')
--  remapper:unregister()
--  remapper2:remap('capslock', 'f13')
--  remapper2:remap('lcmd', 'lctrl')
--  remapper2:remap('lctrl', 'lcmd')
--  remapper2:remap('rcmd', 'rctrl')
--  remapper2:remap('rctrl', 'rcmd')
--  remapper2:register()
-- end

-- local function unswapCMDWithCTRL()
--  print('off')
--  remapper2:unregister()
--  remapper:register()
-- end
-- NOTE: This is only necessary for GUI Vim. iTerm2 supports modifier remapping
-- NOTE: Avalonia Application is the name recognized for FVim
-- via "Preferences>Keys>Remap Modifiers"
-- local wf = hs.window.filter
-- local wf_vim = wf.new{'Avalonia Application'}
-- wf_vim:subscribe(wf.windowFocused, swapCMDWithCTRL)
-- wf_vim:subscribe(wf.windowUnfocused, unswapCMDWithCTRL)

-- Launch and focus applications
--hs.application.enableSpotlightForNameSearches(true)
local function launchFun(app, mode)
  hs.application.launchOrFocus(app)
  -- Emacs doesn't focus via launchOrFocus if already launched
  if app == "Emacs" then
    hs.application.get("Emacs"):activate()
  end
  mode:exit()
end

-- Keys bound to hyper
-- Use app names, or absolute paths, as shown in Finder or terminal
sK:bindModalKeys{
  name = 'hyper',
  key = 'f13',
  dict = {
    {
      key="space",
      fn=function(mode)
        sK.keyRestriction:stop() -- Disable modal key restriction to pass through this keypress
        hs.eventtap.keyStroke({"cmd"}, "`")
        sK.keyRestriction:start() -- Reenable restrictions
      end
    }, -- switch windows
    {
      key=".",
      fn=hs.fnutils.partial(launchFun, "Preview")
    },
    {
      key="b",
      fn=hs.fnutils.partial(launchFun, "Google Chrome")
    },
    {
      key="c",
      mod="shift",
      fn=function(mode)
        hs.execute('open ' .. hs.configdir .. '/init.lua')
        mode:exit()
      end
    },
    {
      key="d",
      fn=hs.fnutils.partial(launchFun, "Dash")
    },
    {
      key="e",
      fn=hs.fnutils.partial(launchFun, "Emacs")
    },
    {
      key="i",
      fn=hs.fnutils.partial(launchFun, "imdone")
    },
    {
      key='m',
      fn=function(mode)
        wM:resizeCurrentWindow('maximize')
        mode:exit()
      end
    }, -- maximize focused window
    {
      key="m",
      mod="shift",
      fn=hs.fnutils.partial(launchFun, "Spotify")
    },
    {
      key="n",
      fn=hs.fnutils.partial(launchFun, "nvALT")
    },
    {
      key="o",
      fn=hs.fnutils.partial(launchFun, "Obsidian")
    },
    {
      key="p",
      fn=hs.fnutils.partial(launchFun, "Pycharm")
    },
    {
      key="t",
      fn=hs.fnutils.partial(launchFun, "iTerm")
    },
    {
      key='v',
      fn=function(mode)
        spoon.TextClipboardHistory:toggleClipboard()
        mode:exit()
      end
    }, -- contextual copy-paste; TODO: integrate with emacs/vim
    {
      key="z",
      fn=hs.fnutils.partial(launchFun, "Zotero")
    }
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
      { key = 'h', 'left' },
      { key = 'l', 'right' },
      { key = 'k', 'top' },
      { key = 'j', 'bottom' }
  }
}

-- Reload script if screen changes
local screenwatcher = hs.screen.watcher.new(function()
	hs.reload()
end)
screenwatcher:start()
