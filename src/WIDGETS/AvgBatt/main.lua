assert(loadScript("/SCRIPTS/UTIL/util.lua"))()

local DEFAULT_TEXTCOLOR = WHITE
local DEFAULT_DISABLEDCOLOR = DARKGREY

local options = {
  { "Batt", SOURCE, 1 },
  { "Cells", VALUE,1,1,12 },
  { "TextColor", COLOR, DEFAULT_TEXTCOLOR },
  { "DisabledColor", COLOR, DEFAULT_DISABLEDCOLOR },
  { "Shadow", BOOL, 1 }
}

local function create(zone, options)
  local widget = { zone=zone, options=options, last_batt = 0, active = false}
  if (widget.options.Batt == nil) then
    local id = 1
    local b = getFieldInfo("VFAS")
    if b == nil then
      b = getFieldInfo("RxBt")
    end
    if b then
      id = b.id
    end
    widget.options.Batt = id
  end
  if (widget.options.Cells == nil) then
    widget.options.Cells = 1
  end
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

local function updateBattValue(widget)
  local value = getValue(widget.options.Batt)
  local active = (value and value>0 and value<60)
  if active then
    widget.last_batt = value
  end
  widget.active = active
end

local function background(widget)
  updateBattValue(widget)
end

function refresh(widget)
  updateBattValue(widget)
  local color = widget.options.TextColor
  local shadow = widget.options.Shadow == 1
  local cells = widget.options.Cells or 1
  local zone = getZone(widget.zone)
  local value = widget.last_batt
  if not widget.active then
    color = widget.options.DisabledColor
  end
  value = round(value / cells,2)
  value = string.format("%.2f",value)
  drawValueZone(widget.zone,"Batt",value,color,shadow)
end

return { name="AvgBatt", options=options, create=create, update=update, background=background, refresh=refresh}
