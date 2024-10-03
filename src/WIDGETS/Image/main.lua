-------------------------------------------------------------------------------
-- Image widget
-- Version: 1.3
-- Date: 2024-10-03
-- Author: Kristjan Bjarni Gudmundsson (kristjanbjarni@gmail.com)
-- License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html
-- https://github.com/kristjanbjarni/opentx-widgets
-------------------------------------------------------------------------------
local IMAGES_FOLDER = "/WIDGETS/Image/images"

local function firstFilename()
  local result = ""
  for fname in dir(IMAGES_FOLDER) do
    result = string.sub(fname,1,-5)
    break
  end
  return result
end

local function existsFile(filename)
  return fstat(IMAGES_FOLDER.."/"..filename) ~= nil
end

local function clearImage(widget)
  widget.image = nil
  widget.width = 0
  widget.height = 0
end

local function openImage(widget, width, height)
  if widget.options.Filename == "" then
    clearImage(widget)
  else
    local fname = widget.options.Filename
    if existsFile(fname..".png") then
      fname = fname..".png"
    elseif existsFile(fname..".jpg") then
      fname = fname..".jpg"
    elseif existsFile(fname..".bmp") then
      fname = fname..".bmp"
    end
    widget.image = Bitmap.open(IMAGES_FOLDER.."/"..fname)
    local w, h = Bitmap.getSize(widget.image)
    local widthRatio = width / w
    local heightRatio = height / h
    local ratio = math.min(widthRatio, heightRatio)
    w = math.floor(w * ratio)
    h = math.floor(h * ratio)
    widget.image = Bitmap.resize(widget.image, w, h)
    widget.x = widget.zone.x
    widget.y = widget.zone.y
    widget.width = width
    widget.height = height
  end
end

local function drawImage(widget, width, height)
  if widget.image == nil or width ~= widget.width or height ~= widget.height or widget.x ~= widget.zone.x or widget.y ~= widget.zone.y then
    openImage(widget, width, height)
  end
  if widget.image ~= nil then
    local w, h = Bitmap.getSize(widget.image)
    local x = math.floor((width - w) / 2)
    local y = math.floor((height - h) / 2)
    lcd.drawBitmap(widget.image, widget.zone.x + x, widget.zone.y + y)
  end
end

local options = {
  { "Filename", STRING, firstFilename() }
}

local function create(zone, options)
  local widget = { zone=zone, options=options, image = nil, x = 0, y = 0, width = 0, height = 0 }
  return widget
end

local function update(widget, options)
  widget.options = options
  clearImage(widget)
end

local function background(widget)
end

function refresh(widget, event, touchState)
  if event == nil and touchState == nil then
    drawImage(widget, widget.zone.w, widget.zone.h)
  else
    drawImage(widget, LCD_W, LCD_H)
  end
end

return { name="Image", options=options, create=create, update=update, background=background, refresh=refresh}
