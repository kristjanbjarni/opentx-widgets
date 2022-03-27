-- Global Constants
ZONE_FONT = {[0]=0,2,3,3,4}
FONT = {["SMLSIZE"] = 0,["NORMAL"] = 1,["MIDSIZE"] = 2,["DBLSIZE"] = 3,["XXLSIZE"] = 4}

local FONT_FLAGS = {[0]=SMLSIZE,0,MIDSIZE,DBLSIZE,XXLSIZE}
local FONT_WIDTHS = {[0]=9,11,15,18,40}
local FONT_HEIGHTS = {[0]=9,12,17,23,47}
local FONT_X_MARGIN = {[0]=0,2,2,2,2}
local FONT_Y_SPACING = {[0]=4,4,4,4,4}
local FONT_WIDTHS_BW = {[0]=4,5,8,10}
local FONT_HEIGHTS_BW = {[0]=6,7,10,14}
local PLUS_CODES = {[0]="2","3","4","5","6","7","8","9","C","F","G","H","J","M","P","Q","R","V","W","X"}
local gps_id = nil
local DRAW_RIGHT_ALIGN = -2147483648
local NAME_SIZES = {[0]=0,1,3,3,3}
local VALUE_SIZES = {[0]=2,2,4,4,4}

local ZONE_SIZES = {
  [0]={z=0,w=70,h=39},
  {z=1,w=160,h=32},
  {z=2,w=180,h=70},
  {z=3,w=192,h=152},
  {z=0,w=196,h=42},
  {z=1,w=196,h=56},
  {z=2,w=196,h=85},
  {z=3,w=196,h=170},
  {z=2,w=225,h=98},
  {z=3,w=225,h=207},
  {z=1,w=240,h=56},
  {z=1,w=240,h=75},
  {z=2,w=240,h=113},
  {z=3,w=240,h=227},
  {z=1,w=392,h=42},
  {z=1,w=392,h=56},
  {z=3,w=392,h=85},
  {z=4,w=392,h=170},
  {z=1,w=426,h=47},
  {z=4,w=460,h=207},
  {z=4,w=460,h=252},
  {z=1,w=480,h=75},
  {z=3,w=480,h=113}
  --{z=4,w=480,h=227},
  --{z=4,w=480,h=272}
}

-- Return new point from x,y
function point(x,y)
  return {["x"]=x,["y"]=y}
end

-- Return true if running in the simulator
function inSimulator()
  local ver, radio = getVersion()
  return string.sub(radio,-5,-1)=='-simu'
end

-- Round number to d precision
function round(v,d)
  local m = 10^(d or 0)
  return math.floor(v*m + 0.5) / m
end

-- Returns distance between two GPS coordinates (Meters)
function getGPSDistance(p1,p2)
  local R = 6371000 -- Radius of the earth in meters
  local Phi1 = math.rad(p1.lat)
  local Phi2 = math.rad(p2.lat)
  local dPhi = math.rad(p2.lat-p1.lat)
  local dLambda = math.rad(p2.lon-p1.lon)
  local a = math.sin(dPhi/2)^2 + math.cos(Phi1) * math.cos(Phi2) * math.sin(dLambda/2)^2
  local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
  return R * c
end

-- Returns the angle/bearing in degrees between two GPS positions
function getGPSBearing(p1,p2)
  if (p1.lat == p2.lat and p1.lon == p2.lon) then
    return 0
  end
  local lat1, lon1, lat2, lon2 = math.rad(p1.lat), math.rad(p1.lon), math.rad(p2.lat), math.rad(p2.lon)
  local lat2c = math.cos(lat2)
  local e = math.sin(lon2 - lon1) * lat2c
  local n = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * lat2c * math.cos(lon2 - lon1)
  local brg = math.deg(math.atan2(e, n))
  return (brg + 360) % 360
end

-- Returns which zone size the widget zone is in
-- Input: zone, The zone widget
-- Output: Integer, 0..4 (Top bar (0), 1/8 box (1), 1/4 box (2), 1/2 box (3), Full screen (4))
function getZone(zone)
  for i=0,#ZONE_SIZES do
    if zone.w<=ZONE_SIZES[i].w and zone.h<=ZONE_SIZES[i].h then
      return ZONE_SIZES[i].z
    end
  end
  return 4
end

-- Return font height for font size
function getFontHeightSpacing(size)
  return FONT_HEIGHTS[size]+FONT_Y_SPACING[size]
end

function getFontHeightSpacingBW(font)
  return FONT_HEIGHTS_BW[font]+4
end

function getFontWidthBW(font)
  return FONT_WIDTHS_BW[font]
end

-- Draw text in widget zone
-- Input:
-- zone: The zone
-- x: The x position, 
--    x>=0 starts at specific x value
--    x<0 centers text with text size or abs(x), whichever is maximum
-- y: The y position
--    y>=0 The y position
--    y<0 Draws at text line abs(y)
--    y==nil Draws at center
-- color: The color to use or standard color if nil
-- shadow: Boolean use shadow or not, default is false
-- font: Integer, the font index (0..4) (Small,Normal,Large,XLarge,XXLarge)
--       if nil the default font for this zone is used
--       if font<0 then use one less default font
function drawTextZone(zone,x,y,text,color,shadow,font)
  local z = getZone(zone)
  if font == nil then
    font = ZONE_FONT[z]
  elseif font<0 then
    font = math.max(ZONE_FONT[z] + font,0)
  end
  local flags = FONT_FLAGS[font]
  if shadow then
    flags = flags + SHADOWED
  end
  if color ~= nil then
    flags = flags + CUSTOM_COLOR
    lcd.setColor(CUSTOM_COLOR,color)
  end
  if x==0 then
    x = x + FONT_X_MARGIN[z]
  elseif x<0 then
    local c  = math.max(string.len(text),-x)
    x = (zone.w - c*FONT_WIDTHS[font]) / 2
    if x<=4 then
      x=0
    end
  end
  if y == nil then
    y = (zone.h - FONT_HEIGHTS[font]) / 2
  elseif y<0 then
    y = (-y - 1)*(FONT_HEIGHTS[font] + FONT_Y_SPACING[font])
  end  
  lcd.drawText(zone.x+x,zone.y+y,text,flags)
end

function drawValueZone(zone,name,value,color,shadow)
  local z = getZone(zone)
  local name_size = NAME_SIZES[z]
  local value_size = VALUE_SIZES[z]
  drawTextZone(zone,0,0,name,color,shadow,name_size)
  local y = getFontHeightSpacing(name_size)
  drawTextZone(zone,0,y,value,color,shadow,value_size)
end  

function drawText(x,y,text,font,flags)
  if not flags then
    flags = 0
  end
  if font == nil then
    font = FONT.NORMAL
  end
  flags = flags + FONT_FLAGS[font]  
  if x == nil then
    x = -1
  end
  if x<0 then
    local c  = math.max(string.len(text),-x)
    x = LCD_W / 2 - c*FONT_WIDTHS_BW[font] / 2
  end
  if y == nil then
    y = LCD_H / 2 - FONT_HEIGHTS_BW[font] / 2
  elseif y<0 then
    y = (-y - 1)*(FONT_HEIGHTS_BW[font] + 4)
  end  
  lcd.drawText(x,y,text,flags)
end

-- Rotate polygon p around an angle and return the new polygon
-- Input: p polygon is made of points
function rotatePolygon(p,angle)
  angle = math.rad(angle)
  local s = math.sin(angle)
  local c = math.cos(angle)
  local a = {}  
  for i=0,#p,1 do
    local x = p[i].x * c - p[i].y * s;
    local y = p[i].x * s + p[i].y * c;
    a[i]=point(x,y)
  end
  return a
end

-- Resize polygon p, resize=1 unchanged, resize>1 multiply size
function resizePolygon(p,resize)
  local r = {}
  for i=0,#p,1 do
    r[i]=point(p[i].x * resize, p[i].y * resize)
  end
  return r
end

-- Draw polygon p at x,y resizing and color
function drawPolygon(p, x, y, resize, color)
  local flags = 0
  if color then
    lcd.setColor(CUSTOM_COLOR,color)
    flags = CUSTOM_COLOR
  end  
  local l = #p + 1
  for i=0,l - 1,1 do
    local p1 = p[i]
    local p2 = p[(i+1) % l]    
    lcd.drawLine(x + p1.x*resize,y + p1.y*resize,x + p2.x*resize,y + p2.y*resize,SOLID,flags)
  end
end

local function getcode(lat,lon)
  local i = math.floor(lat)
  local codepair = PLUS_CODES[i]
  lat = 20 * (lat - i)
  i = math.floor(lon)
  codepair = codepair .. PLUS_CODES[i]
  lon = 20 * (lon - i)
  return lat,lon,codepair
end

function getPlusCode(lat,lon)
  lat = (lat + 90) / 20
  lon = (lon + 180) / 20
  local pluscode = ""
  for i = 1, 4 do
    lat, lon, codepair = getcode(lat, lon)
    pluscode = pluscode .. codepair
  end
  pluscode = pluscode .. "+"
  lat, lon, codepair = getcode(lat, lon)
  pluscode = pluscode .. codepair
  pluscode = pluscode .. PLUS_CODES[4 * math.floor(lat / 5) + math.floor(lon / 4)]
  return pluscode
end

function getValueGPS()
  local result = nil
  if not gps_id then
    local gps_info = getFieldInfo("GPS")
    if gps_info then
      gps_id = gps_info.id
    end
  end
  if gps_id then
    local v = getValue(gps_id)
    if type(v) == "table" then
      result = v
    end
  end
  return result
end
