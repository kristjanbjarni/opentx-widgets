assert(loadScript("/SCRIPTS/UTIL/util.lua"))()
assert(loadScript("/SCRIPTS/UTIL/HomeArrow.lua"))()

-- Constants, change as needed
local ARMED_SWITCH = "sf" -- Switch used for arming
local ARMED_SWITCH_REVERSED = true -- Is arm switch position reversed for arming
local IMPERIAL = false -- Display in imperial units

-- Variables
local home = nil
local armed_id = nil

local function init()
  armed_id = getFieldInfo(ARMED_SWITCH).id
  home = HomeArrow.new(IMPERIAL, true)
end

local function background()
  home:updateGPS(armed_id)
end

local function run(event)
  home:updateDisplay()
  lcd.clear()
  local flags = 0
  if not home:isActive() then
    flags = flags + INVERS
  end
  local xc = LCD_W * 0.4
  local ay = LCD_H * 0.65
  local dist = home:getDistanceDisplay()
  home:drawHouse(xc,10,1)
  drawText(xc+18,2,dist,FONT.DBLSIZE,flags)
  home:drawArrow(xc,ay,3)
end

return { run=run, background=background, init=init }
