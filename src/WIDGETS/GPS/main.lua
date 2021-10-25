assert(loadScript("/SCRIPTS/UTIL/util.lua"))()

local DEFAULT_TEXTCOLOR = WHITE
local DEFAULT_DISABLEDCOLOR = DARKGREY

local options = {
  { "TextColor", COLOR, DEFAULT_TEXTCOLOR },
  { "DisabledColor", COLOR, DEFAULT_DISABLEDCOLOR },
  { "TextSize", VALUE, 0,0,5},
  { "Shadow", BOOL, 1 },
  { "PlusCode", BOOL, 0 }
}

local function create(zone, options)
  local widget = { zone=zone, options=options, last_gps = nil, active = false}
  if (widget.options.TextColor == nil) then
    widget.options.TextColor = DEFAULT_TEXTCOLOR
  end
if (widget.options.DisabledColor == nil) then
    widget.options.DisabledColor = DEFAULT_DISABLEDCOLOR
  end  
  if (widget.options.TextSize < 0 or widget.options.TextSize > 5) then
    widget.options.TextSize=0
  end
  if (widget.options.Shadow == nil) then
    widget.options.Shadow = 1
  end
  if (widget.options.PlusCode == nil) then
    widget.options.PlusCode = 0
  end
  return widget
end

local function update(widget, options)
  widget.options = options
end

local function updateGPS(widget)
  local gpsLatLon = getValue("GPS")
  local active = (type(gpsLatLon) == "table")
  if active then
    widget.last_gps = gpsLatLon
  end
  widget.active = active
end

local function background(widget)
  updateGPS(widget)
end

local function refresh(widget)
  updateGPS(widget)
  local textcolor = widget.options.TextColor
  local shadow = widget.options.Shadow == 1
  local color = widget.options.DisabledColor
  local font = widget.options.TextSize - 1
  local last_gps = widget.last_gps  
  if font<0 then
    font = nil
  end
  if widget.active then
    color = textcolor
  end
  if (last_gps ~= nil) then
    if widget.options.PlusCode==1 then
      local pluscode = getPlusCode(last_gps.lat, last_gps.lon)
      drawTextZone(widget.zone,0,0,pluscode,color,shadow,font or -1)
    else
      drawTextZone(widget.zone,0,-1,round(last_gps.lat,6),color,shadow,font)
      drawTextZone(widget.zone,0,-2,round(last_gps.lon,6),color,shadow,font)
    end
  else
    drawTextZone(widget.zone,0,0,"No GPS",textcolor,shadow,font)
  end
end

return { name="GPS", options=options, create=create, update=update, background=background, refresh=refresh}
