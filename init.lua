require("oh-my-hammerspoon")

-- Load modules
load_plugins({
  --"apps.windowtabs",
  "windows.manipulation",
  "windows.launch_apps",
  "windows.launch_epichrome",
  --"windows.rough_cheatsheets",
  --"windows.screen_rotate",
  --"misc.grocery_list",
  --"misc.statuslets",
  --"misc.url_handling" --Even though this wasn't enabled, every reload would ask to use hs as my default browser. Then it stopped. Chrome has also been crashing. The app wouldn't open, or would throw other weird error msgs. Now that the file's code is commented out, things seem OK.
})

-- Reload
hs.loadSpoon('reloadConfig')
local s = spoon
local rC = s.reloadConfig
rC.auto_reload = true
rC.manual_reload_key = {}
rC:start()

-- Clipboard
hs.loadSpoon('TextClipboardHistory')
local TCH = s.TextClipboardHistory
TCH.show_in_menubar = false
TCH.paste_on_select = true
TCH.honor_ignoredidentifiers = true -- default; just in case
TCH:start()
--omh.modes.hyper:bind({"shift"}, "s", function() TCH:showClipboard() end)
omh.modes.hyper:bind({}, 'v', function() TCH:toggleClipboard() end)


-- http://www.hammerspoon.org/Spoons/WiFiTransitions.html
-- http://www.hammerspoon.org/Spoons/URLDispatcher.html
