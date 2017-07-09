obj = {}
obj.modes = {}
obj.modes.hyper = hs.hotkey.modal.new()
obj.notifications = true

local function createCanvas(modeName)
  local g = hs.screen.mainScreen():frame()
  local width = g._w
  local height = g._h
  local f = hs.window.focusedWindow():frame()
  -- print(f) -- though f is global, and though it prints fine, calling it from
  --the console always results in nil
  local x1 = f._x; x2 = f._x+f._w; if x2 > width then x2 = width end
  local y1 = f._y; y2 = f._y+f._h; if y2 > height then y2 = height end

  local squares = {}
  table.insert(squares,{x=0,y=0,w=x1,h=y1})
  table.insert(squares,{x=x1,y=0,w=x2-x1,h=y1})
  table.insert(squares,{x=x2,y=0,w=width-x2,h=y1})
  table.insert(squares,{x=x2,y=y1,w=width-x2,h=y2-y1})
  table.insert(squares,{x=x2,y=y2,w=width-x2,h=height-y2})
  table.insert(squares,{x=x1,y=y2,w=x2-x1,h=height-y2})
  table.insert(squares,{x=0,y=y2,w=x1,h=height-y2})
  table.insert(squares,{x=0,y=y1,w=x1,h=y2-y1})

  local areas = {}
  for i = 1,#squares do
    local temp = squares[i]
    temp.area = temp.w*temp.h
    table.insert(areas, temp.area)
  end

  local maxArea = math.max(table.unpack(areas))
  local maxSquare = hs.fnutils.find(squares, function(element)
    return element.area == maxArea
  end)
  maxSquare.area = nil

  local canv = hs.canvas.new(maxSquare)
  local canvFrame = canv:frame(); canvFrame.__luaSkinType = nil
  canv:alpha(0.8)

  local phrase = "Entered "..modeName.." mode"
  canv:appendElements({
    type = "text",
    text = phrase, -- needs to be changeable by mode
    --hs.inspect(hs.canvas.defaultTextStyle())
    -- textAlignment = "center",
    textColor = hs.drawing.color.lists().Apple.White,
    textSize = 50,
  })

  local minDims = canv:minimumTextSize(1, phrase) -- sub a var for
  -- this string and value of 'text' above
  minDims._luaSkinType = nil
  local hRef = minDims.h / canvFrame.h * 100
  local wRef = minDims.w / canvFrame.w * 100

  canv[1].frame.x = tostring(50 - wRef/2).."%"
  canv[1].frame.y = tostring(50 - hRef/2).."%"
  canv[1].frame.w = tostring(50 + wRef/2).."%"
  canv[1].frame.h = tostring(50 + hRef/2).."%"

  minDims.h = tostring(hRef).."%"
  minDims.w = tostring(wRef).."%"
  minDims.x = canv[1].frame.x
  minDims.y = canv[1].frame.y

  canv:insertElement({
    type = "rectangle",
    -- absolutePosition = false,
    -- absoluteSize = true,
    frame = minDims,
    -- strokeColor = hs.drawing.color.lists().Apple.White,
    -- strokeWidth = 1,
    fillColor = hs.drawing.color.lists().Apple.Black,
    roundedRectRadii = {xRadius = 6, yRadius = 6}
  }, 1)

  return canv
end

canv = {}
function obj:toggleCanvas(modeName)
  if not self.modes[modeName].active then
    canv[modeName] = createCanvas(modeName):show()
  else canv[modeName]:delete(); canv[modeName] = nil -- delete the lingering userdata
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
