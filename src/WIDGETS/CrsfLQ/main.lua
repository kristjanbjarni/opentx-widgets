assert(loadScript("/SCRIPTS/UTIL/util.lua"))()

local DEFAULT_TEXTCOLOR = WHITE
local DEFAULT_DISABLEDCOLOR = DARKGREY

local options = {
  { "TextColor", COLOR, DEFAULT_TEXTCOLOR },
  { "DisabledColor", COLOR, DEFAULT_DISABLEDCOLOR },
  { "Shadow", BOOL, 1 }
}

local function create(zone, options)
  local widget = { zone=zone, options=options}
  if (widget.options.TextColor == nil) then
    widget.options.TextColor = DEFAULT_TEXTCOLOR
  end
if (widget.options.DisabledColor == nil) then
    widget.options.DisabledColor = DEFAULT_DISABLEDCOLOR
  end
  if (widget.options.Shadow == nil) then
    widget.options.Shadow = 1
  end
  return widget
end

local function update(widget, options)
  widget.options = options
end

local function background(widget)
end

local function refresh(widget)
  local color = widget.options.TextColor
  local shadow = widget.options.Shadow == 1
  local rfmd = getValue("RFMD") or 0
  local rqly = getValue("RQly") or 0
  if (rfmd == 0 and rqly == 0) then
    color = widget.options.DisabledColor
  end
  local value = rfmd.." : "..rqly
  drawValueZone(widget.zone,"LQ",value,color,shadow)
end

return { name="CrsfLQ", options=options, create=create, update=update, background=background, refresh=refresh}
