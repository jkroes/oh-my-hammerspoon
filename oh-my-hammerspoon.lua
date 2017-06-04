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
local status, err = pcall(function()

  p =  require("init-local")

end)

if not status then
   -- A 'no file' error is OK, but anything else needs to be reported
   if string.find(err, 'no file') == nil then
      error(err)
   end
end

omh.notify("Oh my Hammerspoon!", "Config loaded")

-- Create sequential modes

---- Create variables, assign, and return names
local len = #p.hyperKeys
modal_keys = omh.assignment("hyper_key", p.hyperKeys, len, false, false)
modes = omh.assignment("hyper", "hs.hotkey.modal.new()", len, true, true)

---- Swap variable names out for variable values
omh.modal_keys = omh.queryGlobal(modal_keys)
omh.modes = omh.queryGlobal(modes)
--omh.insert_queryGlobal(modal_keys)
--omh.insert_queryGlobal(modes)

---- Nix global variables created by omh.assignment()
omh.globeSafe("hyper_key", len, false)
omh.globeSafe("hyper", len, true)

-------------------------------------------------------
-------------------------------------------------------
--Portion of library that depends on omh.modes---------
-------------------------------------------------------
-------------------------------------------------------
-- return function() print(2+2) end -- Need `return` for anon functions; otherwise name-type error
-- return function(x) return x end -- objects require a return statement, or they fail; can't define body of function that way; however, note that anon functions require return before the function constructor, in place of a name.
omh.bind2Mode = {}
function omh.bind2Mode.base(idx, mod, key, fun)
  parent = omh.modes[idx]
  parent:bind(mod, key, fun)
end
function omh.bind2Mode.NoMod(idx, key, fun)
  omh.bind2Mode.base(idx, {}, key, fun)
end
function omh.bind2Mode.Hyper(mod, key, fun)
  omh.bind2Mode.base(1, mod, key, fun)
end
function omh.bind2Mode.HyperNoMod(key, fun)
  omh.bind2Mode.base(1, {}, key, fun)
end

-- First keypress enters hyper, second exits any active mode, unless hyper.watch = nil
-- e.g. succesfully launching an app should set hyper.watch = nil before exiting the active mode so that the second keypress re-enters hyper.
local function hyperactive(hyper, modes)
  if not hyper.watch then
    hyper:enter(); hyper.watch = true
  else
    hyper.watch = nil -- must come before exit()
    hs.fnutils.ieach(modes, function(element)
      if element.active then element:exit() end
    end)
  end
end

-- Notification types:
----Tab, tab: Enter hyper, exit hyper
----Tab,childkey,tab: Enter hyper, enter child, exit child
----Tab, childkey, childkey: Enter hyper, enter child, exit hyper, enter hyper
----Expected behavior for 3+-deep modal chains, such as cheaters
function omh.bindMode2Mode(modeTable, parentIdx, child, key, phrase, cheats)
  local hyper = modeTable[parentIdx]
  if not cheats then child = modeTable[child] end

  -- Overwrite modal objects' enter-exit methods
  function child:entered()
    print('Entered ' .. phrase .. ' mode', '')
    hs.notify.show('Hammerspoon', 'Entered ' .. phrase .. ' mode','')
    child.active = true
  end

  function child:exited()
    print('Exited ' .. phrase .. ' mode', '')
    if not (hyper.watch) then
      hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
    end
    child.active = nil
  end

  if child ~= hyper then
    hyper:bind({}, key, function() hyper:exit(); child:enter() end)
    if cheats then key = "Q" end
    child:bind({}, key, function() child:exit(); hyper:enter() end)
  else
    hs.hotkey.bind({}, key, function() hyperactive(child, modeTable) end)
  end
end

-------------------------------------------------------
-------------------------------------------------------
--Create modal bindings-------------------------------
-------------------------------------------------------
-------------------------------------------------------

for i=1,len do
  omh.bindMode2Mode(omh.modes,1, i, omh.modal_keys[i], p.hyperPhrase[i])
end
