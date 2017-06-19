local omh={} -- Return as module, rather than global variable for all scripts to see

-- Some useful global variables
omh.hostname = hs.host.localizedName()
omh.logger = hs.logger.new('oh-my-hs')
omh.hs_config_dir = hs.configdir -- Need to replace all omh occurrences with hs.config.dir
--hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

-- Display a notification
function omh.notify(title, message)
   hs.notify.new({title=title, informativeText=message}):send()
end

-- From http://lua-users.org/wiki/CopyTable
-- Copy a table recursively
function omh.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[omh.deepcopy(orig_key)] = omh.deepcopy(orig_value)
        end
        setmetatable(copy, omh.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Reverse a list
function omh.reverseList(orig)
  local rev = {}
  local len = #orig+1
  for i,v in ipairs(orig) do
    local j = len-i
    rev[j] = v
  end
  return rev
end

-- Return the sorted keys of a table
function omh.sortedkeys(tab)
   local keys={}
   -- Create sorted list of keys
   for k,v in pairs(tab) do table.insert(keys, k) end
   table.sort(keys)
   return keys
end


-- Return table key based on value. !!!Note that this will only return one binding, even if multiple keys lead to the same value.!!!
function omh.find(tbl, val)
    for k, v in pairs(tbl) do
        if v == val then return k end
    end
    return nil
end

function omh.listcheatfiles(path)
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
function omh.enabled_hotkeys()
  local x = omh.deepcopy(hs.hotkey.getHotkeys())
  hs.fnutils.ieach(x, function(element)
    for k,v in pairs(element) do if k ~= "idx" then element[k] = nil end end
    print(element.idx)
  end)
  --print(hs.inspect(x))
end

-- Execute string
function omh.side_effects(expression)
  -- Since return is nil, this function is only useful for modifying state (i.e. its side effects)
  local x = load(expression)
  x()
end

-- Append number, either at at the end of a basename variable (append = true), or before the underscore in a name that consists only of letters separarted by an underscore (append = false)
function omh.insert_numbers(str, num1, num2, append)
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
  return x
end

-- Creates list of similarly named variables and assign a common value or a value with matching index in a value-table. Works for strings that represent function calls (valsAreFuns = true) and actual strings (valsAreFuns = false).
function omh.assignment(baseVar, vals, numVars, append, valsAreFuns)
  local vars = omh.insert_numbers(baseVar, 2, numVars, append)
  local val = vals
  local expr
  for i=1,numVars do
    local var = vars[i]
    if type(vals) == "table" then val = vals[i] end
    if valsAreFuns then expr = var.."="..val
    else expr = var..'='.."\""..val.."\""
    end
    omh.side_effects(expr)
    --print(expr) -- helps to see what string is being loaded
  end
  return vars
end

-- Accept list of global variables-as-strings and return values of variables
function omh.queryGlobal(orig)
  local copy = omh.deepcopy(orig)
  for i,v in ipairs(copy) do copy[i] = _G[copy[i]] end
return copy
end

function omh.insert_queryGlobal(x)
  for i,v in ipairs(x) do
    omh[v] = _G[v]
  end
end

-- Erase global variables
function omh.globeSafe(baseVar, numVars, append)
  omh.assignment(baseVar, "nil", numVars, append, true)
  -- values aren't really functions, but nil shouldn't have surrounding inner quotes
end

--https://stackoverflow.com/questions/11380379/create-lua-function-from-string

-- return function() print(2+2) end -- Need `return` for anon functions; otherwise name-type error
-- return function(x) return x end -- objects require a return statement, or they fail; can't define body of function that way; however, note that anon functions require return before the function constructor, in place of a name.


return omh
