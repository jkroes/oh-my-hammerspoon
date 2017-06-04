-- Uncomment to set non-default log level
-- logger.setLogLevel('debug')

local plugins = {}

-- Plugin configuration
plugins.hammerspoon_config_reload = {
  auto_reload = true,
  manual_reload_key = {{"cmd", "alt", "ctrl"}, "z"}
}

plugins.headphones_watcher = {
   control_spotify = true,
   control_itunes  = false
}

plugins.rough_cheatsheets = {
  path = "~/Documents/cheatsheets/",
  navkeys = {"a","s","d","f","g","h","j","k","l",";"},
  git = "g"
} -- Note that variable names (aside from path and navkeys) are names of individual subdirectories on path
-- Because the navigation keys may conflict with the foldername keys (e.g. git = "g") and the foldername mode is the parent of the navigation mode, the same key originally would both open a cheatfile and exit the parent foldername mode. I've tweaked bindModalKeys2ModeToggle(), so that instead of pressing the same key to exit foldername mode, you press "Q", which takes you back to cheat mode, where you can specify a new foldername.

plugins.launch_epichrome = {
   {"g", "/Users/justinkroes/Applications/Gmail.app"},
   {"h", "/Users/justinkroes/Applications/GitHub.app"},
}

plugins.launch_apps = {
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
-- hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:title()) end)
-- Apparently we should use the actual app name as shown in finder, and an absolute path can also be used. Not the results of the code above...

plugins.manipulation = {
  maximize = "m",
  screens = {
    screen_right = "l",
    screen_left = "j"
  },
  halves = {
    left = "j",
    right = "l",
    top = "i",
    bottom = "m"
  },
  thirds = {
    third_left = "j",
    third_right = "l",
    third_up = "i",
    third_down = "m"
  },
}

plugins.screen_rotate = {
   toggle_rotate_modifier = { "Ctrl", "Cmd", "Alt"},
   toggle_rotate_keys = {
      [".*"] = "f15"
-- e.g.
--                 ["HP Z24i"] = "f13",
--                 ["SyncMaster"] = "f15",
   },
    -- Lua patterns for screens that shouldn't be rotated, even if they match one of the patterns
   screens_to_skip = { "Color LCD" },
   rotating_angles = { 0, 90 }, -- normal, rotated
   rotated = { },
}

-- Hyper/child mode configuration
-- Order is vitally important. You can see the order of each string by looking at each plugin file's parent variable.
plugins.hyperKeys = {"f13","l","s","h","f19","e","t"}
plugins.hyperPhrase = {"HYPER", "app launch", "screen", "halves", "thirds", "epichrome launch", "cheaters"}

-- Function call required for every instance of a plugins table, though error will not be thrown otherwise
omh_config("apps.hammerspoon_config_reload", plugins.hammerspoon_config_reload)
omh_config("audio.headphones_watcher", plugins.headphones_watcher)
omh_config("windows.launch_epichrome", plugins.launch_epichrome)
omh_config("windows.launch_apps", plugins.launch_apps)
omh_config("windows.rough_cheatsheets", plugins.rough_cheatsheets)
omh_config("windows.manipulation", plugins.manipulation)
omh_config("windows.screen_rotate", plugins.screen_rotate)

return plugins
