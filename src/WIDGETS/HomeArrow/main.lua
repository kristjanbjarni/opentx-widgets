assert(loadScript("/SCRIPTS/UTIL/util.lua"))()
assert(loadScript("/SCRIPTS/UTIL/HomeArrow.lua"))()

local DEFAULT_TEXTCOLOR = WHITE
local DEFAULT_DISABLEDCOLOR = DARKGREY
local ARROW_SIZE = {[0]=1,2,3,8,8} -- Arrow size for every zone
local HOME_SIZES = {[0]="s","s","m","l","l"} -- Size of home icon for every zone
local DISTANCE_SPACING = {[0]=1,3,3,3,4} -- Distance text spacing for every zone
local ARROW_X = {[0]=0.15,0.15,0.30,0.30,0.35} -- X position for arrow in percent for every zone
local ARROW_Y = {[0]=0.60,0.70,0.65,0.65,0.65} -- Y position for arrow in percent for every zone
local IMAGE_FOLDER = "/WIDGETS/HomeArrow/images"

local options = {
  { "TextColor", COLOR, DEFAULT_TEXTCOLOR },
  { "DisabledColor", COLOR, DEFAULT_DISABLEDCOLOR },
  { "Shadow", BOOL, 1 },
  { "Armed", SOURCE, 1 }, -- Source for armed status
  { "Imperial", BOOL, 0 } -- Imperial units
}

local function create(zone, options)
  local widget = { zone=zone, options=options, home_image = nil, home = HomeArrow.new()}
  if widget.options.TextColor == nil then
    widget.options.TextColor = DEFAULT_TEXTCOLOR
  end
  if widget.options.DisabledColor == nil then
    widget.options.DisabledColor = DEFAULT_DISABLEDCOLOR
  end
  if shadow == nil then
    widget.options.Shadow = 1
  end
  if widget.options.Armed == nil then
    widget.options.Armed = 1
  end
  if widget.options.Imperial == nil then
    widget.options.Imperial = 0    
  end
  local z = getZone(zone)
  widget.home_image = Bitmap.open(IMAGE_FOLDER.."/home_"..HOME_SIZES[z]..".png")
  return widget
end

local function update(widget, options)
  widget.options = options
  local imperial = widget.options.Imperial == 1
  widget.home:setImperial(imperial)
end

local function background(widget)
  widget.home:updateGPS(widget.options.Armed)
  return
end

local function refresh(widget)
  widget.home:updateGPS(widget.options.Armed)
  widget.home:updateDisplay()
  local textcolor = widget.options.TextColor
  local color = widget.options.DisabledColor
  local shadow = widget.options.Shadow == 1
  local z = getZone(widget.zone)
  if widget.home:isActive() then
    color = textcolor
  end
  local bw,bh = Bitmap.getSize(widget.home_image)
  local hx = widget.zone.w * ARROW_X[z]
  local hy = widget.zone.h * ARROW_Y[z]
  local bx = bw / 2
  lcd.drawBitmap(widget.home_image,widget.zone.x + hx - bx,widget.zone.y)
  local dist = string.rep(" ",DISTANCE_SPACING[z])..widget.home:getDistanceDisplay()
  drawTextZone(widget.zone,hx + bx,0,dist,color,shadow)
  local arrow_size = ARROW_SIZE[z]
  widget.home:drawArrow(widget.zone.x + hx,widget.zone.y + hy,arrow_size,textcolor)
end

return { name="HomeArrow", options=options, create=create, update=update, background=background, refresh=refresh}
