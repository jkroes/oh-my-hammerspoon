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

function enabled_hotkeys()
  x = deepcopy(hs.hotkey.getHotkeys())
  hs.fnutils.ieach(x, function(element)
    for k,v in pairs(element) do if k ~= "idx" then element[k] = nil end end
    print(element.idx)
  end)
end
--enabled_hotkeys()

function hyper_bind2toggle(parent, child, key, phrase, cheats)

  function child:entered()
    hs.notify.show('Hammerspoon',
    'Entered ' .. phrase .. ' mode',
    '')
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
-----------------------------------------
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

-------------------------

return omh
