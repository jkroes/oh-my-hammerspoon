--- Diego Zamboni <diego@zzamboni.org>
-- Window management

local obj = {}
obj.shift = {}
obj.shift.x = 0
obj.shift.y = 0

obj.maximize = "m"
obj.screens = {
  screen_right = "l",
  screen_left = "j"
}
obj.halves = {
  left = "j",
  right = "l",
  top = "i",
  bottom = "m"
}
obj.quarters = {
  bottom_left = "j",
  bottom_right = "k",
  top_left = "u",
  top_right = "i"
}

-- Frames
function obj:left() return {self.shift.x,self.shift.y,(1-self.shift.x)/2,1-self.shift.y} end
function obj:right() return {(self.shift.x+1)/2,self.shift.y,(1-self.shift.x)/2,1-self.shift.y} end
function obj:top() return {self.shift.x,self.shift.y,1-self.shift.x,(1-self.shift.y)/2} end
function obj:bottom() return {self.shift.x,(self.shift.y+1)/2,1-self.shift.x,(1-self.shift.y)/2} end
function obj:bottom_left() return {self.shift.x,(1+self.shift.y)/2,(1-self.shift.x)/2,(1-self.shift.y)/2} end
function obj:bottom_right() return {(1+self.shift.x)/2,(1+self.shift.y)/2,(1-self.shift.x)/2,(1-self.shift.y)/2} end
function obj:top_left() return {self.shift.x,self.shift.y,(1-self.shift.x)/2,(1-self.shift.y)/2} end
function obj:top_right() return {(1+self.shift.x)/2,self.shift.y,(1-self.shift.x)/2,(1-self.shift.y)/2} end
function obj:max() return {self.shift.x,self.shift.y,1-self.shift.x,1-self.shift.y} end

-- Prevent laggy animations (doesn't need to be optionally configured)
hs.window.animationDuration = 0
----------------------------------------------------------------------
--- Base window resizing and moving functions
----------------------------------------------------------------------
-- Window cache for window maximize toggler
-- (persists between function calls)
local frameCache = {}

local function screen_left(win)
  hs.window.setFrameCorrectness = true
  win:moveOneScreenWest()
  hs.window.setFrameCorrectness = false
end
local function screen_right(win)
  hs.window.setFrameCorrectness = true
  win:moveOneScreenEast()
  hs.window.setFrameCorrectness = false
end

-- Resize current window to different parts of the screen
function obj:resizeCurrentWindow(how)
  local win = hs.window.focusedWindow(); if not win then return end
  local screen = win:screen()
  local name = screen:name()
  local temp = {}
  temp.x = self.shift.x; temp.y = self.shift.y

  if name ~= "Color LCD" then
      self.shift.x = 0; self.shift.y = 0
  end


  -- Function is internal because value of win needs to update each time
  -- resize is called
  function self:maximize()
    local subhow
    if win:id() == nil then return
    elseif frameCache[win:id()] then
      subhow = frameCache[win:id()]
      frameCache[win:id()] = nil
    else
      frameCache[win:id()] = win:frame()
      subhow = self:max()
    end
    return subhow
  end

  if how == "screen_left" then screen_left(win)
  elseif how == "screen_right" then screen_right(win)
  else result = hs.fnutils.partial(self[how], self); result = result()
    if (result) then win:move(result) end
  end

  -- Restore margin size to previous values
  self.shift.x = temp.x; self.shift.y = temp.y
end

return obj
