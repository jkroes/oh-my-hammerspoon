package.path = package.path .. ';plugins/?.lua'
omh = require("omh-lib") -- If omh isn't global, then plugins that call omh outside of mod.init() will fail, even if omh is passed through mod.init(). Alternatively, you could require omh-lib from each plugin file.

omh.plugin_cache={}
local OMH_PLUGINS={}
local OMH_CONFIG={}

function load_plugins(plugins)
   plugins = plugins or {}
   for i,p in ipairs(plugins) do
      table.insert(OMH_PLUGINS, p)
   end -- Why not simply OMH_PLUGINS=plugins above? Same result as far as I can tell -JK
   -- For debugging:
   --print("Look at me:")
   --hs.inspect(OMH_PLUGINS)
   for i,plugin in ipairs(OMH_PLUGINS) do
     -- How to access this log? -JK
      omh.logger.df("Loading plugin %s", plugin)
      -- First, load the plugin
      local mod = require(plugin)
      -- If it returns a table (like a proper module should), then
      -- we may be able to access additional functionality
      if type(mod) == "table" then
         -- If the user has specified some config parameters, merge
         -- them with the module's 'config' element (creating it
         -- if it doesn't exist)
         if OMH_CONFIG[plugin] ~= nil then --Value is set in omh_config() below, and this function is called in init-local.lua, where plugin configuration takes place.
           -- Prep mod.config for table indexing in for loop below
            if mod.config == nil then
               mod.config = {}
            end
            -- mod.config is originally set in plugin files
            for k,v in pairs(OMH_CONFIG[plugin]) do --
               mod.config[k] = v
            end
         end
         -- If it has an init() function, call it
         if type(mod.init) == "function" then
            omh.logger.i(string.format("Initializing plugin %s", plugin))
            mod.init()
         end
         -- print("See below:")
         -- print_r(OMH_CONFIG)
         --
      end
      -- Cache the module (with any changes)
      -- As far as I can tell, this isn't used for anything, but would be accessible from the console. May be for user reference.
      omh.plugin_cache[plugin] = mod
   end
end

-- Specify config parameters for a plugin. name must be a plugin module string as specified to require (e.g. "apps.hammerspoon_config_reload"), where the prefix is a folder and the suffix is a file.
-- I've left this as a global function for init-local to access, because the user needs to cutomize how many times this function is called as they add their own plugins.
function omh_config(name, config)
   omh.logger.df("omh_config, name=%s, config=%s", name, hs.inspect(config))
   OMH_CONFIG[name]=config
end

-- Load local code if it exists and notify when configuration is loaded, or throw an error
local p
local status, err = pcall(function() p =  require("init-local") end)

if not status then
   -- A 'no file' error is OK, but anything else needs to be reported
   if string.find(err, 'no file') == nil then
      error(err)
   end
end

omh.notify("Oh my Hammerspoon!", "Config loaded")

-- Create hyper mode
omh.modes = {}
omh.modes.hyper = hs.hotkey.modal.new()

-- Notification types:
----Tab, tab: Enter hyper, exit hyper
----Tab,childkey,tab: Enter hyper, enter child, exit child
----Tab, childkey, childkey: Enter hyper, enter child, exit hyper, enter hyper
----Expected behavior for 3+-deep modal chains, such as cheaters
function omh.bindMode2Mode(parent, key, phrase, createHyper, cheats)
  local hyper = omh.modes.hyper
  local child
  if not createHyper then -- pressing a key enters a new mode, pressing again enters the old mode. Only one mode is active at any time to prevent conflicting keybindings.
    child = hs.hotkey.modal.new()
    --if not cheats then child = modeTable[child] end
    omh.modes[phrase] = child -- Make mode visible so that hyper can exit the active mode if the hyperkey is pressed. Also makes visible to plugin files that reference the new mode.
    parent:bind({}, key, function() parent:exit(); child:enter() end)
    if cheats then key = "Q" end
    child:bind({}, key, function() child:exit(); parent:enter() end)
  else -- First hyper keypress enters hyper, second exits any active mode, unless hyper.watch = nil. After a succesful action from a non-hyper mode, such as launching an app, hyper.watch should be set to nil within the function that generates the action (see plugin files).
    hs.hotkey.bind({}, key, function()
      if not hyper.watch then
        hyper:enter(); hyper.watch = true
      else
        hyper.watch = nil -- must come before exit()
        hs.fnutils.each(omh.modes, function(element)
          if element.active then element:exit() end
        end)
      end
    end)
    child = hyper
  end

  -- Overwrite modal objects' enter-exit methods
  function child:entered()
    print('Entered ' .. phrase .. ' mode', '')
    hs.notify.show('Hammerspoon', 'Entered ' .. phrase .. ' mode','')
    child.active = true
  end

  -- Prevent exit messages if a mode is entered. Setting hyper.watch to nil after a successful action in a plugin file will allow an exit message for that mode.
  function child:exited()
    print('Exited ' .. phrase .. ' mode', '')
    if not hyper.watch then
      hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
    end
    child.active = nil
  end
end

omh.bindMode2Mode(omh.modes.hyper, p.hyper.key, p.hyper.phrase, true)