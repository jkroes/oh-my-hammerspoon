--- Diego Zamboni <diego@zzamboni.org>
-- Window management

local obj = {}

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
obj.thirds = {
  third_left = "j",
  third_right = "l",
  third_up = "i",
  third_down = "m"
}
obj.quarters = {
  bottom_left = "j",
  bottom_right = "k",
  top_left = "u",
  top_right = "i"
}

-- Frames
function obj:left() return {self.shift,0,(1-self.shift)/2,1} end
function obj:right() return {self.shift+(1-self.shift)/2,0,1-(self.shift+(1-self.shift)/2),1} end
function obj:top() return {self.shift,0,1,0.5} end
function obj:bottom() return {self.shift,0.5,1,0.5} end
function obj:hthird0() return {self.shift,0,(1-self.shift)/3,1} end
function obj:hthird1() return {self.shift+(1-self.shift)/3,0,(1-self.shift)/3,1} end
function obj:hthird2() return {self.shift+2*(1-self.shift)/3,0,(1-self.shift)/3,1} end
function obj:vthird0() return {self.shift,0,1,1/3} end
function obj:vthird1() return {self.shift,1/3,1,1/3} end
function obj:vthird2() return {self.shift,2/3,1,1/3} end
function obj:bottom_left() return {self.shift,1/2,(1-self.shift)/2,1/2} end
function obj:bottom_right() return {self.shift+(1-self.shift)/2,1/2,(1-self.shift)/2,1/2} end
function obj:top_left() return {self.shift,0,(1-self.shift)/2,1/2} end
function obj:top_right() return {self.shift+(1-self.shift)/2,0,(1-self.shift)/2,1/2} end
function obj:max() return {0+self.shift,0,1,1} end

-- Prevent laggy animations (doesn't need to be optionally configured)
hs.window.animationDuration = 0
----------------------------------------------------------------------
--- Base window resizing and moving functions
----------------------------------------------------------------------
-- Window cache for window maximize toggler
-- (persists between function calls)
local frameCache = {}

-- Get the horizontal third of the screen in which a window is at the moment
local function get_horizontal_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.x/screenframe.w)
   --logger.df("Screen frame: %s", screenframe)
   --logger.df("Window frame: %s, relframe %s is in horizontal third #%d", frame, relframe, third)
   return third
end

-- Get the vertical third of the screen in which a window is at the moment
local function get_vertical_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.y/screenframe.h)
   --logger.df("Screen frame: %s", screenframe)
   --logger.df("Window frame: %s, relframe %s is in vertical third #%d", frame, relframe, third)
   return third
end

local function screen_left()
  hs.window.setFrameCorrectness = true
  win:moveOneScreenWest()
  hs.window.setFrameCorrectness = false
end
local function screen_right()
  hs.window.setFrameCorrectness = true
  win:moveOneScreenEast()
  hs.window.setFrameCorrectness = false
end



-- Resize current window to different parts of the screen
function obj:resizeCurrentWindow(how)
  local win = hs.window.focusedWindow(); if not win then return end
  local screen = win:screen()
  local which_third

  -- Function is internal because it value of win needs to update each time
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

  -- Reset coordinates, optionally adjust for cracked laptop screen
  self.shift = 0; if screen:name() == "Color LCD" then self.shift = 0.075 end

  if how == "third_left" then
    local third = get_horizontal_third(win)
    which_third = "hthird" .. math.max(third-1,0)
  elseif how == "third_right" then
    local third = get_horizontal_third(win)
    which_third = "hthird" .. math.min(third+1,2)
  elseif how == "third_up" then
    local third = get_vertical_third(win)
    which_third = "vthird" .. math.max(third-1,0)
  elseif how == "third_down" then
    local third = get_vertical_third(win)
    which_third = "vthird" .. math.min(third+1,2)
  end
  if which_third then how = which_third end

  result = hs.fnutils.partial(self[how], self)
  result = result()
  -- store value of call for functions (e.g. self.maximize) that change state
  -- with each call
  if (result) then win:move(result) end
end

return obj
