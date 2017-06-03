omh={}

-- Some useful global variables
hostname = hs.host.localizedName()
logger = hs.logger.new('oh-my-hs')
hs_config_dir = hs.configdir
--hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- Display a notification
function notify(title, message)
   hs.notify.new({title=title, informativeText=message}):send()
end

-- Algorithm to choose whether white/black as the most contrasting to a given
-- color, from http://gamedev.stackexchange.com/a/38561/73496
--[[
function chooseContrastingColor(c)
   local L = 0.2126*(c.red*c.red) + 0.7152*(c.green*c.green) + 0.0722*(c.blue*c.blue)
   local black = { ["red"]=0.000,["green"]=0.000,["blue"]=0.000,["alpha"]=1 }
   local white = { ["red"]=1.000,["green"]=1.000,["blue"]=1.000,["alpha"]=1 }
   if L>0.5 then
      return black
   else
      return white
   end
end
--]]

-- Return the sorted keys of a table
function sortedkeys(tab)
   local keys={}
   -- Create sorted list of keys
   for k,v in pairs(tab) do table.insert(keys, k) end
   table.sort(keys)
   return keys
end

-- Return table key based on value. Note that this will only return one binding, even if multiple keys can lead to the same value.

function find(tbl, val)
    for k, v in pairs(tbl) do
        if v == val then return k end
    end
    return nil
end

function listcheatfiles(path)
  local files = {}
  local filestring = hs.execute("ls -1 " .. path .. " | grep -v '.md'")
  -- Pipe to wc -l for line count in bash
  for file in string.gmatch(filestring, "[%a%.%d_]+") do
    table.insert(files,file)
  end
  return files
end

-- Bind a key, simply a bridge between the OMH config format and hs.hotkey.bind
function omh.bind(keyspec, fun)
   hs.hotkey.bind(keyspec[1], keyspec[2], fun)
end

-- From Hammerspoon's hs.hotkey.modal API:
-- "This method [enter()] will enable all of the hotkeys defined in the modal state via hs.hotkey.modal:bind(), and disable the hotkey that entered the modal state (if one was defined) [e.g. a parent mode]."
-- Likewise, exit() disables hotkeys for the current modal state and reenables the parent hotkey or parent mode's hotkeys
-- This means that one can design mode entry and exit such that pressing a key enables a child mode, while a second press enables the parent mode
function hyper_bind2toggle(parent, child, key, phrase, cheats)

  function child:entered()
    hs.notify.show('Hammerspoon', 'Entered ' .. phrase .. ' mode', '')
  end

  -- prevent an exit call if already exited elsewhere
  function child:exited()
    child.active = nil
    hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
  end

  -- first keypress enters, second exits unless another modal action is taken
  -- e.g. succesfully launching an app, which is set to exit automatically
  local function activate(mode)
    if mode.active then mode:exit()
    else mode.active = true; mode:enter()
    end
  end

  if cheats then
    parent:bind({}, key, function() child:enter() end)
    child:bind({}, "Q", function() child:exit() end)
  elseif child ~= parent then
  -- bind children modes
    parent:bind({}, key, function() activate(child) end)
  -- bind HYPER key, which doesn't have a predecessor mode
  else hs.hotkey.bind({}, key, function() activate(child) end)
  end
end

function side_effects(expression)
  -- Since return is nil, this function is only useful for modifying state (i.e. its side effects)
  local x = load(expression)
  x()
end

function insert_numbers(str, num1, num2, append)
  local x = {str}
  if append then
    for i = num1,num2 do
      table.insert(x, str..i)
    end
  else --insert on left side of underscore; assumes word is only letters and underscore
    for i = num1,num2 do
      local prefix = string.match(str,"%a+")
      local suffix = string.match(str,"_%a+")
      local newStr = prefix..i..suffix
      table.insert(x, newStr)
    end
  end
  -- for i = num1,num2 do
  --   table.insert(x, str .. i)
  -- end
  return x
end

-- Use when you only want variables to differ in name by a numeric suffix, either appended at the end of a basename variable (append = true), or before the underscore in a name that consists only of letters separarted by an underscore (append = false). Works for strings that represent functions (valsAreFuns = true) and actual strings (valsAreFuns = false).
function repetitive_assignment(baseVar, vals, numVars, append, valsAreFuns)
  local vars = insert_numbers(baseVar, 2, numVars, append)
  local val = vals
  local expr
  for i=1,numVars do
    local var = vars[i]
    if type(vals) == "table" then val = vals[i] end
    if valsAreFuns then expr = var.."="..val
    else expr = var..'='.."\""..val.."\""
    end
    side_effects(expr)
    print(expr) -- helps to see what string is being loaded
  end
end

--repetitive_assignment("hyper_key", hyperKeys,#hyperKeys)

return omh
