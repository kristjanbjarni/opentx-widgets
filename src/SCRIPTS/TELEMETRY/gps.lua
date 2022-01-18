assert(loadScript("/SCRIPTS/UTIL/util.lua"))()
assert(loadScript("/SCRIPTS/UTIL/HomeArrow.lua"))()

-- Constants, change as needed
local SHOW_PLUSCODE = true

-- Variables
local last_gps = nil
local active = false

local function init()
  last_gps = nil
  active = false
end

local function background()
  local value = getValueGPS()
  active = value ~= nil
  if active then
    last_gps = value
  end  
end

local function run(event)
  lcd.clear()
  local flags = 0
  if not active then
    flags = flags + INVERS
  end
  if last_gps then
    local dh = getFontHeightSpacingBW(FONT.DBLSIZE)
    local y = 4
    drawText(-10,y,round(last_gps.lat,6),FONT.DBLSIZE,flags)
    drawText(-10,y+dh,round(last_gps.lon,6),FONT.DBLSIZE,flags)
    if SHOW_PLUSCODE then      
      local plus = getPlusCode(last_gps.lat,last_gps.lon)
      local mh = getFontHeightSpacingBW(FONT.MIDSIZE)
      local py = LCD_H - mh
      drawText(nil,py,plus,FONT.MIDSIZE,flags)
    end  
  else
    drawText(nil,nil,"No GPS",FONT.DBLSIZE)
  end
end

return { run=run, background=background, init=init }
