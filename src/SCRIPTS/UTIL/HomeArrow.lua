-------------------------------------------------------------------------------
-- Home Arrow
-- Version: 1.3
-- Date: 2024-10-03
-- Author: Kristjan Bjarni Gudmundsson (kristjanbjarni@gmail.com)
-- License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html
-- https://github.com/kristjanbjarni/opentx-widgets
-------------------------------------------------------------------------------
local FEET_IN_METERS = 3.2808399
local MILES_IN_KM = 0.621371192
local MILE_IN_FEETS = 5280
-- Use 2 seconds delay for calculating craft direction. Store last 4 GPS coord every 500 ms
local MAX_GPS = 4
local UPDATE_GPS_MS = 500
local ARROW = {[0]=point(0,-7),point(4,-3),point(1,-3),point(1,7),point(-1,7),point(-1,-3),point(-4,-3)} -- Arrow polygon
local HOUSE = {[0]=point(0,-8),point(8,0),point(5,0),point(5,7),point(1,7),point(1,2),point(-1,2),point(-1,7),point(-5,7),point(-5,0),point(-8,0)} -- House polygon

-- Get index for the very first GPS saved in sliding window
local function getFirstGPS(self)
  local g = self.gps_window
  local i = self.gps_index + 1
  if i > #g then
    i = 0
  end
  return g[i]
end

-- Add GPS to sliding window
local function addGPS(self,gps)
  self.last_gps = gps  
  local current_time  = getTime() * 10
  local diff = current_time - self.last_time_ms
  if diff >= UPDATE_GPS_MS then
    self.last_time_ms = current_time
    if self.gps_window then
      local i = self.gps_index
      i = (i + 1) % MAX_GPS
      self.gps_window[i] = gps
      self.gps_index = i
    else
      self.gps_window = {[0]=gps}
      self.gps_index = 0
    end
  end
end

-- Update GPS in background
local function updateGPS(self,armed_switch)
  local gps = getValueGPS()
  local valid = gps ~= nil
  if valid then
    valid = gps.lat ~= 0 and gps.lon ~= 0
  end
  if valid then
    local arm_value = getValue(armed_switch)
    if self.arming_reversed then
      arm_value = -arm_value
    end
    local armed =  arm_value > 0
    if armed then
      if not self.last_armed then
        self.home_gps = nil
        self.last_gps = nil
        self.gps_window = nil
        self.gps_index = -1
      end
      if not self.home_gps then
        self.home_gps = gps
      end
      addGPS(self,gps)
    else
      valid = false
    end
    self.last_armed = armed
  end
  self.active = valid
end

-- Update distance and arrow for display
local function updateDisplay(self)
  local dist = 0
  local angle = 0
  if self.home_gps then
    local g2 = self.last_gps
    local g1 = getFirstGPS(self)
    dist = getGPSDistance(self.home_gps,g2)
    local craft_direction = getGPSBearing(g1,g2)
    local home_direction = getGPSBearing(g2,self.home_gps)
    angle = (home_direction - craft_direction + 360) % 360
  end  
  self.distance = dist
  self.angle = angle
end

-- Return distance with correct units for display
local function getDistanceDisplay(self)
  local v = self.distance
  local imperial = getGeneralSettings().imperial ~= 0;
  if imperial then
    v = v * FEET_IN_METERS
    if v > MILE_IN_FEETS then
      v = v / MILE_IN_FEETS
      v = round(v,2) .. "mi"
    else 
      v = math.floor(v) .. "ft"
    end
  else 
    if v >= 1000 then
      v = v / 1000
      v = round(v,2) .. "km"
    else 
      v = math.floor(v) .. "m";
    end
  end
  return v
end

local function isActive(self)
  return self.active
end

local function hasHomePosition(self)
  return self.home_gps ~= nil
end

local function setArmedReversed(self,reversed)
  self.arming_reversed = reversed
end

local function getLastGPS(self)
  return self.last_gps
end

local function drawArrow(self,x,y,size,color)
  local a = rotatePolygon(ARROW,self.angle)
  drawPolygon(a,x,y,size,color)
end

local function drawHouse(self,x,y,size,color)
  drawPolygon(HOUSE,x,y,size,color)
end

local function new(arm_switch_reversed)
  return 
  {
    -- Variables
    home_gps = nil,
    last_gps = nil,
    gps_window = nil,
    gps_index = -1,
    active = false,
    last_time_ms = 0,
    last_armed = false,
    angle = 0,
    distance = 0,
    arming_reversed = arm_switch_reversed or false,
    -- Functions
    updateGPS = updateGPS,
    updateDisplay = updateDisplay,
    getDistanceDisplay = getDistanceDisplay,
    isActive = isActive,
    setArmedReversed = setArmedReversed,
    hasHomePosition = hasHomePosition,
    drawArrow = drawArrow,
    drawHouse = drawHouse,
    getLastGPS = getLastGPS
  }
end

HomeArrow = { new = new }
