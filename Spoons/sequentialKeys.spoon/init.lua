obj = {}
obj.modes = {}
obj.modes.hyper = hs.hotkey.modal.new()
obj.notifications = true

local function createCanvas(modeName)
  local g = hs.screen.mainScreen():frame() -- Easiest fix to broken screen
  -- is to adjust the boundaries of 'g' BAE
  local canvas = hs.canvas.new{x=g._x,y=g._y,w=g._w,h=g._h}
  local canvasFrame = canvas:frame(); canvasFrame.__luaSkinType = nil
  canvas:alpha(0.8)

  local phrase = "Entered "..modeName.." mode"
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
function obj:toggleCanvas(modeName)
  if not self.modes[modeName].active then
    canvas[modeName] = createCanvas(modeName):show()
  else canvas[modeName]:delete(); canvas[modeName] = nil -- delete the lingering userdata
  end
end -- hs.canvas.help([attribute])
hs.hotkey.bind({"cmd"},"o",function() toggleCanvas("test") end)


-- Notification types:
----Tab, tab: Enter hyper, exit hyper
----Tab,childkey,tab: Enter hyper, enter child, exit child
----Tab, childkey, childkey: Enter hyper, enter child, enter hyper
----Expected behavior for 3+-deep modal chains, such as cheaters
----If a key is mapped to a childkey, the child mode will only be exited with
----hyperkey
function obj:bindModes(arg)
  local modes = self.modes
  local hyper = modes.hyper
  local parent = arg.parent
  if type(parent) == 'string' then parent = modes[arg.parent] end
  local child -- forward declaration
  local key = arg.key
  local phrase = arg.phrase
  local altEscapeKey = arg.altEscapeKey

  if parent then
    child = hs.hotkey.modal.new(); self.modes[phrase] = child
    parent:bind({}, key, function() parent:exit(); child:enter() end)
    if altEscapeKey then key = altEscapeKey end
    child:bind({}, key, function() child:exit(); parent:enter() end)
  else
    hs.hotkey.bind({}, key, function()
      if not hyper.watch then hyper:enter(); hyper.watch = true
      else
        hyper.watch = nil; hs.fnutils.each(self.modes, function(element)
          if element.active then element:exit() end
        end)
      end
    end)
    child = hyper
  end

  -- Overwrite modal objects' enter-exit methods
  local notifications = self.notifications
  local saveYourSelf = self -- disambiguate self for inner methods
  function child:entered()
    print('Entered ' .. phrase .. ' mode', '')
    saveYourSelf:toggleCanvas(phrase)
    child.active = true
  end

  function child:exited()
    print('Exited ' .. phrase .. ' mode', '')
    saveYourSelf:toggleCanvas(phrase)
    child.active = nil
  end
end

function obj:exitSequentialMode(mode, withoutMsg)
  local hyper = self.modes.hyper
  if not withoutMsg then hyper.watch = nil end
  if type(mode) == 'string' then mode = self.modes[mode] end
  mode:exit()
  if withoutMsg then hyper.watch = nil end
end

return obj
