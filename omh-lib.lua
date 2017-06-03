omh={}

-- Some useful global variables
hostname = hs.host.localizedName()
logger = hs.logger.new('oh-my-hs')
hs_config_dir = hs.configdir -- Need to replace all omh occurrences with hs.config.dir
--hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- Display a notification
function notify(title, message)
   hs.notify.new({title=title, informativeText=message}):send()
end

-- From http://lua-users.org/wiki/CopyTable
-- Copy a table recursively
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Reverse a list
function reverseList(orig)
  local rev = {}
  local len = #orig+1
  for i,v in ipairs(orig) do
    local j = len-i
    rev[j] = v
  end
  return rev
end

-- Return the sorted keys of a table
function sortedkeys(tab)
   local keys={}
   -- Create sorted list of keys
   for k,v in pairs(tab) do table.insert(keys, k) end
   table.sort(keys)
   return keys
end


-- Return table key based on value. !!!Note that this will only return one binding, even if multiple keys lead to the same value.!!!
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

-- Print enabled hotkeys to console
function enabled_hotkeys()
  local x = deepcopy(hs.hotkey.getHotkeys())
  hs.fnutils.ieach(x, function(element)
    for k,v in pairs(element) do if k ~= "idx" then element[k] = nil end end
    print(element.idx)
  end)
  --print(hs.inspect(x))
end

-- First keypress enters, second exits, unless another modal action is taken
-- e.g. succesfully launching an app, which is set to exit automatically
-- Exception is hyper: second keypress exits all modes, including hyper
-- Second exception is cheats: its mode is exited with "Q", regardless of the key that enters cheat mode.

function bindModalKeys2ModeToggle(modeTable, keyTable, idx, phraseTable, cheats)
  local disabled
  local parent = modeTable[1]
  local child = modeTable[idx]
  local key = keyTable[idx]
  local phrase = phraseTable[idx]

  function child:entered()
      hs.notify.show('Hammerspoon', 'Entered ' .. phrase .. ' mode','')
      print('Entered ' .. phrase .. ' mode', '')
  end

  function child:exited()
    if not disabled then
      hs.notify.show('Hammerspoon', 'Exited ' .. phrase .. ' mode', '')
      print('Exited ' .. phrase .. ' mode', '')
    end
  end

  local function hyperactive()
    if child.active then
      disabled = nil -- always display exit notificaiton for hyper
      child:exit()
      disabled = true
      hs.fnutils.ieach(modes, function(element)
        element:exit() -- currently exits all modes, even if they're inactive
      end)
      child.active = nil
      -- then make sure to set hyper.active = true in each script that successfully completes a mode. use "Q" to exit foldermode in cheats.
      -- set information parameter of notifications to list of button options
    else child:enter(); child.active = true  end
  end

  if child ~= parent then
    disabled = true -- disable modal exit notifications
    parent:bind({}, key, function() parent:exit(); child:enter() end)
    child:bind({}, key, function() child:exit(); parent:enter() end)
  else
    hs.hotkey.bind({}, key, function() hyperactive(child) end)
  end
end

-- Execute string
function side_effects(expression)
  -- Since return is nil, this function is only useful for modifying state (i.e. its side effects)
  local x = load(expression)
  x()
end

-- Append number, either at at the end of a basename variable (append = true), or before the underscore in a name that consists only of letters separarted by an underscore (append = false)
function insert_numbers(str, num1, num2, append)
  local x = {str}
  if append then
    for i = num1,num2 do
      table.insert(x, str..i)
    end
  else
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

-- Creates list of similarly named variables and assign a common value or a value with matching index in a value-table. Works for strings that represent function calls (valsAreFuns = true) and actual strings (valsAreFuns = false).
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
    --print(expr) -- helps to see what string is being loaded
  end
  return vars
end

-- Accept list of global variables-as-strings and return values of variables
function queryGlobal(orig)
  local copy = deepcopy(orig)
  for i,v in ipairs(copy) do copy[i] = _G[copy[i]] end
  return copy
end

return omh
