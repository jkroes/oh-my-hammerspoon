--- Diego Zamboni <diego@zzamboni.org>
-- Window management

local obj = {
  shift = {x = 0, y = 0},
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
-- function obj:max() return {self.shift.x,self.shift.y,1-self.shift.x,1-self.shift.y} end
function obj:maximize() return {self.shift.x,self.shift.y,1-self.shift.x,1-self.shift.y} end

-- Prevent laggy animations (doesn't need to be optionally configured)
hs.window.animationDuration = 0
----------------------------------------------------------------------
--- Base window resizing and moving functions
----------------------------------------------------------------------
-- Window cache for window maximize toggler
-- (persists between function calls)
--local frameCache = {}

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
  local win = hs.window.focusedWindow()
  if not win then
    local xq = hs.application.get('XQuartz')
    if xq and xq:isFrontmost() then
      self:resizeX11Window(how)
    end
    return
  end
  -- local screen = win:screen()
  -- local name = screen:name()
  -- local temp = {}
  -- temp.x = self.shift.x; temp.y = self.shift.y

  -- if name ~= "Color LCD" then
  --     self.shift.x = 0; self.shift.y = 0
  -- end

  -- Function is internal because value of win needs to update each time
  -- resize is called
  -- function self:maximize()
  --   local subhow
  --   if win:id() == nil then return
  --   elseif frameCache[win:id()] then
  --     subhow = frameCache[win:id()]
  --     frameCache[win:id()] = nil
  --   else
  --     frameCache[win:id()] = win:frame()
  --     subhow = self:max()
  --   end
  --   return subhow
  -- end

  if how == "screen_left" then screen_left(win)
  elseif how == "screen_right" then screen_right(win)
  else result = self[how](self)
    if (result) then win:move(result) end
  end

  -- -- Restore margin size to previous values
  -- self.shift.x = temp.x; self.shift.y = temp.y
end

-- Requires you to uncheck System Preferences>Mission Control>Displays Have Separate Spaces
local xscreen = hs.screen.primaryScreen() -- Initial value
local ur = {0,0,0.5,0.5} -- Initial value
function obj:resizeX11Window(how)
  if how == "screen_left" then
    xscreen = xscreen:toWest() or xscreen:toEast() or xscreen
  elseif how == "screen_right" then
    xscreen = xscreen:toEast() or xscreen:toWest() or xscreen
  else
    ur = self[how](self)
  end
  r = xscreen:fromUnitRect(ur)
  -- Equivalent to:
  -- x = ur[1] * frame._w + frame._x
  -- y = ur[2] * frame._h + frame._y
  -- w = ur[3] * frame._w
  -- h = ur[4] * frame._h
  
  local cmd = "wmctrl -i -r $(wmctrl -l | grep %s | cut -d' ' -f1) -e 0,%d,%d,%d,%d"
  local shell = hs.execute("echo $SHELL")
  if shell == "/usr/local/bin/fish\n" then
    cmd = string.gsub(cmd, "(.*)$(.*)", "%1%2") -- "$" can't be pattern b/c it is treated as the regex end-anchor
  end
  hs.execute(string.format(cmd, self.x11app, r._x, r._y, r._w, r._h), 1)
  return
end

return obj
