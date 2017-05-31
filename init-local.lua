-- Uncomment to set non-default log level
-- logger.setLogLevel('debug')

-- Hyper init
hyper = hs.hotkey.modal.new()
hyper_key = { {}, "f18"} -- mapped to caps lock by karabiner-elements
omh.bind(hyper_key, function() hyper:enter() end) --Bind hyper key to hyper mode

-- Sequential hyper keys for windows.launch_apps
hyper2 = hs.hotkey.modal.new()
hyper2_key = "l"
hyper:bind({}, hyper2_key, function() hyper2:enter() end)

-- Sequential hyper keys for windows.manipulation
hyper3 = hs.hotkey.modal.new()
hyper3_key = "s" -- move between screens
hyper:bind({}, hyper3_key, function() hyper3:enter() end)
hyper4 = hs.hotkey.modal.new()
hyper4_key = "h" -- halves
hyper:bind({}, hyper4_key, function() hyper4:enter() end)
hyper5 = hs.hotkey.modal.new()
hyper5_key = "t" -- thirds
hyper:bind({}, hyper5_key, function() hyper5:enter() end)

-- Plugin configuration
omh_config("apps.hammerspoon_config_reload",
           {
             auto_reload = false,
             manual_reload_key = {{"cmd", "alt", "ctrl"}, "z"}
           })

omh_config("audio.headphones_watcher",
           {
             control_spotify = true,
             control_itunes  = false,
           })

-- Condider using named arguments: https://www.lua.org/pil/5.3.html
--[[
omh_config("windows.grid",
           {
             grid_key = { {"Ctrl", "Alt", "Cmd"}, "g"},
             grid_geometries = {
                                { "2x2" },
                                --myscreen = hs.screen.mainScreen()
                               }
           })
--]]

-- Get a list of all running app names
-- hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:title()) end)
omh_config("windows.launch_apps",
{
  {"g", "Google Chrome"},
  {"z", "Zotero"},
  {"a", "Atom"},
  {"s", "Spotify"},
  {"d", "Dash"},
  {"h", "Hammerspoon"},
  {"r", "RStudio"},
  {"n", "nvALT"},
  {"w", "Microsoft Word"},
  {"e", "Microsoft Excel"},
  {"p", "Microsoft PowerPoint"},
  {"i", "iTerm"}, -- not "iTerm2" for some reason
  {"2", "Calendar"},
  {"3", "Activity Monitor"},
  {"1", "Gmail"},
  {"4", "Cheaters"},
  {"f", "Finder"}
}) -- iTerm2 is currently SHIFT+ENTER to show/unshow

omh_config("windows.manipulation",
{
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
})

omh_config("windows.screen_rotate",
{
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
})

-- Full screen Chrome is crashing. Need to read source code for clue why.
--[[
omh_config("apps.windowtabs",
{
  apps = {
    "Atom",
    "Microsoft Word",
    "Microsoft Excel",
    "Microsoft PowerPoint"
    }
})
]]
