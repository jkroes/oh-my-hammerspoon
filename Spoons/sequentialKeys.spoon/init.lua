local function createCanvas(modeName)
  local g = hs.screen.mainScreen():frame() -- Easiest fix to broken screen
  -- is to adjust the boundaries of 'g' BAE
  local canvas = hs.canvas.new{x=g._x,y=g._y,w=g._w,h=g._h}
  local canvasFrame = canvas:frame(); canvasFrame.__luaSkinType = nil
  canvas:alpha(0.8)

  --local phrase = "Entered "..modeName.." mode"
  local phrase = string.upper(modeName)
  canvas:appendElements({
    type = "text",
    text = phrase, -- needs to be changeable by mode
    textColor = hs.drawing.color.lists().Apple.White,
    textSize = 50,
  })

  local minDims = canvas:minimumTextSize(1, phrase) -- sub a var for
  -- this string and value of 'text' above
  minDims._luaSkinType = nil
  local hRef = minDims.h / canvasFrame.h * 100
  local wRef = minDims.w / canvasFrame.w * 100

  canvas[1].frame.x = tostring(50 - wRef/2).."%"
  canvas[1].frame.y = tostring(50 - hRef/2).."%"
  canvas[1].frame.w = tostring(50 + wRef/2).."%"
  canvas[1].frame.h = tostring(50 + hRef/2).."%"

  minDims.h = tostring(hRef).."%"
  minDims.w = tostring(wRef).."%"
  minDims.x = canvas[1].frame.x
  minDims.y = canvas[1].frame.y

  canvas:insertElement({
    type = "rectangle",
    -- absolutePosition = false,
    -- absoluteSize = true,
    frame = minDims,
    -- strokeColor = hs.drawing.color.lists().Apple.White,
    -- strokeWidth = 1,
    fillColor = hs.drawing.color.lists().Apple.Black,
    roundedRectRadii = {xRadius = 6, yRadius = 6}
  }, 1)

  return canvas
end

local canvas = {}
function toggleCanvas(modeName, active)
  if not active then
    canvas[modeName] = createCanvas(modeName):show()
  else canvas[modeName]:delete(); canvas[modeName] = nil -- delete the lingering userdata
  end
end -- hs.canvas.help([attribute])

local rest
function restrictKeys()

  rest = hs.eventtap.new({hs.eventtap.event.types.keyDown},
  function(event)

    local keyCode = tostring(event:getKeyCode())
    -- print("keycode: ", keyCode)
    local hotkeyList = hs.hotkey.getHotkeys()
    -- print("hoykeyList: ", hs.inspect(hotkeyList))
    local hotkeyCodes = hs.fnutils.imap(hotkeyList, function(elem)
      local hk = tostring(elem._hk)
      -- print("hk: ", hk)
      local sm = string.match(hk,"keycode: (%d+)")
      -- print("sm: ", sm)
      return sm
    end)

    local isHotkey = hs.fnutils.contains(hotkeyCodes, keyCode)
    -- print("isHotkey: ", isHotkey)
    if not isHotkey then
      return true
    end

  end)

  rest:start()
end


function entered(self, phrase)
   print('Entered '..phrase..' mode')
   toggleCanvas(phrase, false)
   self.active = true
   restrictKeys()
end

function exited(self, phrase)
   print('Exited '..phrase..' mode')
   toggleCanvas(phrase, true)
   rest:stop(); rest = nil
   self.active = nil
end

-- Hyper is the top-level mode.
-- key is bound to a global hotkey such that pressing it activates hyper mode.
-- Pressing the key again exits any active modes, including hyper or
-- any child modes.
-- obj:bindHyper() should be called prior to obj:bindModes()
local obj = {}
function obj:bindHyper(key)
  self.modes = {}
  local hyper = hs.hotkey.modal.new()
  self.modes.hyper = hyper
  
  local hyperfun = function()
    local exit_active = function(mode)
      if mode.active then mode:exit() end
    end
    
    if not hyper.watch then hyper:enter(); hyper.watch = true
    else hyper.watch = nil; hs.fnutils.each(self.modes, exit_active)
    end
  end
  
  hs.hotkey.bind({}, key, hyperfun)

  function hyper:entered() entered(self, 'hyper') end
  function hyper:exited() exited(self, 'hyper') end 
end

-- Arguments: parent, key, phrase, altEscapeKey
-- Pressing key exits the parent mode and enters the child mode.
-- Pressing key again, or altEscapeKey if one was provided, exits the child mode
-- and enters the parent mode.
-- altEscapeKey is useful if the key used to enter the child mode is rebound to
-- something else within the child mode. In this case, pressing altEscapeKey exits back to
-- the parent mode (hyper), while pressing hyper still exits all modes.
-- When a mode is entered or exited, a message is printed to both the console for
-- debugging by the code maintainer, and to the screen for the user.
function obj:bindModes(arg)
   local hyper = self.modes.hyper
   -- Either the object or a string naming it can be passed
   local parent = type(arg.parent) == "string" and self.modes[arg.parent] or arg.parent
   local child = hs.hotkey.modal.new(); self.modes[arg.phrase] = child -- Stash child mode
   
   parent:bind({}, arg.key, function() parent:exit(); child:enter() end)
   child:bind({}, arg.altEscapeKey or arg.key, function() child:exit(); parent:enter() end)

   function child:entered() entered(self, arg.phrase) end
   function child:exited() exited(self, arg.phrase) end
end


-- Needed to end modes when executing a non-modal keypress.
-- You don't always want this to happen, so it needs to be called in
-- cases where you do (in init.lua).
function obj:exitSequentialMode(mode, withoutMsg)
  local hyper = self.modes.hyper
  if not withoutMsg then hyper.watch = nil end
  if type(mode) == 'string' then mode = self.modes[mode] end
  mode:exit()
  if withoutMsg then hyper.watch = nil end
end

return obj
