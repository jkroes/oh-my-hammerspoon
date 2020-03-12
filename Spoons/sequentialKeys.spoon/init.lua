-- Garbage collection affects all local variables and non-variables once their scope ends. However, global functions that reference external local variables/upvalues will still work, since closures effectively capture the local variable. The same applies to upvalues referenced by anonymous functions within a global watcher or cyclical function (e.g., hs.timer.doEvery). My guess is that this behavior is recursive. E.g., all modes have an enter() method that calls a user-defined callback entered(), which in this case used to call another function, toggleCanvas, which relied on the upvalue canvas. It worked just fine.
-- See https://github.com/Hammerspoon/hammerspoon/issues/1103, asmagill's example. Note that if s is local, we can't stop the timer simply by setting s=true, as the timer callback has already capture the original value of s prior to its collection.

local obj = {modes = {}}

-- Hyper should be bound prior to other modes
local createCanvas
function obj:bindMode(arg) -- Arguments: parent, name, key, altEscapeKey
  local mode = hs.hotkey.modal.new()
  mode.top = self
  mode.name = arg.name
  self.modes[arg.name] = mode
  
  if arg.name == 'hyper' then -- Hyper key activates hyper mode or disables any active mode
    hs.hotkey.bind({}, arg.key,
      function()
        if mode.top.active then
          mode.top.active:exit()
        else
          mode:enter()
        end
      end)
  else -- Other modal keys exit parent mode and enter mode. Second press (or altEscapeKey) does the reverse.
    local parent = type(arg.parent) == "string" and self.modes[arg.parent] or arg.parent
    parent:bind({}, arg.key, function() parent:exit(); mode:enter() end)
    mode:bind({}, arg.altEscapeKey or arg.key, function() mode:exit(); parent:enter() end)
  end
  
  local canvas
  function mode:entered()
    print('Entered '..mode.name..' mode')
    mode.top.keyRestriction:start()
    mode.top.active = mode
    canvas = createCanvas(mode.name):show()
  end

  function mode:exited()
    print('Exited '..mode.name..' mode')
    mode.top.keyRestriction:stop()
    mode.top.active = nil
    canvas:delete()
  end

  return mode
end

-- Restricts keys to those bound to a mode. Exposed to allow bound keys to send their
-- own keypresses. 
obj.keyRestriction = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = tostring(event:getKeyCode())
    local hotkeyCodes = hs.fnutils.imap(
      hs.hotkey.getHotkeys(), -- List of keys bound to active mode
      function(elem) return string.match(tostring(elem._hk), "keycode: (%d+)") end
    )
    
    local isHotkey = hs.fnutils.contains(hotkeyCodes, keyCode)
    if not isHotkey then return true end
end)

function createCanvas(modeName)
  local g = hs.screen.mainScreen():frame()
  local canvas = hs.canvas.new{x=g._x,y=g._y,w=g._w,h=g._h}
  local name = string.upper(modeName)
  
  canvas:appendElements({ -- see hs.canvas attributes
      type = "text",
      text = name,
      textColor = hs.drawing.color.lists().Apple.White,
      textSize = 55, -- Arbitrary size that looks good
  })

  -- Minimum centered frame that encapsulates (white) text
  local minDims = canvas:minimumTextSize(1, name) -- Presumably uses the textSize but not text of canvas[1]
  local hRef = minDims.h / g._h * 100
  local wRef = minDims.w / g._w * 100
  local frame = {
    x = tostring(50 - wRef/2).."%",
    y = tostring(50 - hRef/2).."%",
    w = tostring(wRef).."%",
    h = tostring(hRef).."%"
  }

  canvas[1].frame = frame

  -- Black background as second element seems to hide text
  -- Later eleemnts layered on top of previous elements?
  canvas:insertElement(
    {
      type = "rectangle",
      frame = frame,
      fillColor = hs.drawing.color.lists().Apple.Black,
      roundedRectRadii = {xRadius = 6, yRadius = 6}
    },
    1
  )

  canvas:alpha(0.8)

  return canvas
end

-- Flexible binding of modes together and keys to modes. Features:
-- 1. If you call bindMode in your init.lua, you can omit arg.key and arg.parent in calling bindModalKeys,
--    but you need to ensure that arg.name matches the name passed to bindMode. This allows shorter repeat
--    calls to bindModalKeys.
-- 2. Modes should all specify a parent, except for hyper. Note that you could have multiple hyper keys,
--    however. The parent need not be hyper, so modes can be nested.
-- 3. arg.dict can be structured in several ways:
-- 3a. A table, whose elements are a table containing a modifier, key, and a function with mode as its only
--     argument. This is intended for when a mode's keys each call a different function, though the functions
--     need not be different.
-- 3b. A table whose elements are tables containing a modifier, key, and an unspecified number of unnamed
--     Lua objets. These objects are paseed in the order given to arg.fn. arg.fn's last argument must be
--     mode. This is intended for when the same function with different arguments is mapped to a mode's keys.
-- 4. The requirement for mode in either arg.fn or elem.fn is because this spoon does not auto-exit modes
--    after key presses. Functions must call mode:exit() themselves if they want to exit the mode.
--    Note that the hyper key serves as a way to exit any mode at any time.
function obj:bindModalKeys(arg)
  local mode = self.modes[arg.name] or
    self:bindMode{name=arg.name, key=arg.key, parent=arg.parent}
  hs.fnutils.each(
    arg.dict,
    function(elem)
      local mod = elem.mod
      local key = elem.key
      elem.mod = nil
      elem.key = nil
      if elem.fn then
        fun = hs.fnutils.partial(elem.fn, mode)
      else
        fun = hs.fnutils.partial(arg.fn, table.unpack(elem), mode)
      end
      mode:bind(mod, key, fun)
    end
  )
end

return obj
