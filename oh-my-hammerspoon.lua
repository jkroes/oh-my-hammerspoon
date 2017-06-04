package.path = package.path .. ';plugins/?.lua'
require("omh-lib")

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
      logger.df("Loading plugin %s", plugin)
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
            logger.i(string.format("Initializing plugin %s", plugin))
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

-- Specify config parameters for a plugin. First name
-- is the name as specified in OMH_PLUGINS, second is a table.
function omh_config(name, config)
   logger.df("omh_config, name=%s, config=%s", name, hs.inspect(config))
   OMH_CONFIG[name]=config
end

-- Load local code if it exists
local status, err = pcall(function() require("init-local") end)

if not status then
   -- A 'no file' error is OK, but anything else needs to be reported
   if string.find(err, 'no file') == nil then
      error(err)
   end
end

---- Notify when the configuration is loaded
omh.notify("Oh my Hammerspoon!", "Config loaded")
