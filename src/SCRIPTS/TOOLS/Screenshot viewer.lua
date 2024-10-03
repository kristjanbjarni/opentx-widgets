-------------------------------------------------------------------------------
-- Screenshot viewer
-- Version: 1.3
-- Date: 2024-10-03
-- Author: Kristjan Bjarni Gudmundsson (kristjanbjarni@gmail.com)
-- License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html
-- https://github.com/kristjanbjarni/opentx-widgets
-------------------------------------------------------------------------------
local toolName = "TNS|Screenshot viewer|TNE"

local SCREENSHOT_FOLDER = "/SCREENSHOTS"
local CHAR_WIDTH = 0
local CHAR_HEIGHT = 0
local MAX_LINES = 0

local files = {}
local current_screen = 0
local current_index = 0
local top_index = 1
local image = nil
local preview_image = nil

local function endswith(str,ending)
  return string.sub(str,-#ending) == ending
end

local function updateIndex(index)
  current_index = index
  image = Bitmap.open(SCREENSHOT_FOLDER.."/"..files[current_index])
  preview_image = Bitmap.resize(image, LCD_W / 2, LCD_H)
  if top_index > 1 and current_index <= top_index then
    top_index = top_index - 1
  elseif current_index < #files and current_index >= (top_index + MAX_LINES - 1) then
    top_index = 1 + (current_index - (MAX_LINES - 1))
  end
end

local function mapToIndex(x,y)
  if x < (LCD_W / 2) then
    if y < (MAX_LINES*CHAR_HEIGHT) then
      local r = math.floor(y / CHAR_HEIGHT) + top_index
      if r <= #files then
        return r
      end  
    end
  end
  return 0
end

local function init_func()
  CHAR_WIDTH, CHAR_HEIGHT = lcd.sizeText('W')
  MAX_LINES = math.floor(LCD_H / CHAR_HEIGHT)
  local i = 1
  for fname in dir(SCREENSHOT_FOLDER) do
    if endswith(fname,'.bmp') then
      files[i] = fname
      i = i + 1
    end
  end
  if #files > 0 then
    updateIndex(1)
  end
end

local function drawMenu(x,y,index,is_dots)
  local flags = 0
  if current_index == index then
      flags = INVERS
  end
  if is_dots then
    lcd.drawText(x,y,'...')
  else
    lcd.drawText(x,y,files[index],flags)
  end
end

-- select screen
local function draw_select_screen()
  lcd.clear()
  
  -- Draw filename menu
  local count = #files
  if count==0 then
    local f = MIDSIZE
    local m = 'No screenshots found!'
    local w,h = lcd.sizeText(m,f)
    local x = (LCD_W - w ) / 2
    local y = (LCD_H - h) / 2
    lcd.drawText(x,y,m,f)
    return
  end
  local x = CHAR_WIDTH / 2
  local y = 0
  local line = 0
  for i=top_index,count do
    line = line + 1
    local is_dots = ( (line == 1) and (top_index > 1) ) or ( (line == MAX_LINES) and (count > top_index + (MAX_LINES - 1) ) )
    drawMenu(x,y,i,is_dots)
    y = y + CHAR_HEIGHT
    if (line >= MAX_LINES) then
      break
    end
  end

  -- Draw middle line
  x = LCD_W / 2
  lcd.drawLine(x-1,0,x-1,LCD_H-1,SOLID,FORCE)
  
  -- Draw preview image
  if preview_image ~= nil then
    local w,h = Bitmap.getSize(preview_image)
    x = LCD_W - w
    y = (LCD_H - h ) / 2
    lcd.drawBitmap(preview_image,x,y)
  end
end

-- view screen
local function draw_view_screen()
  if image ~= nil then
    lcd.drawBitmap(image,0,0)
  end
end

local function handle_keypress(event, touchState)
  if event == EVT_VIRTUAL_EXIT or
       event == EVT_VIRTUAL_MENU or
       event == EVT_VIRTUAL_MENU_LONG then
    return true
  end
  if current_index > 0 then
    if event == EVT_VIRTUAL_PREV_PAGE or
         event == EVT_VIRTUAL_NEXT_PAGE or
         event == EVT_VIRTUAL_ENTER then
      current_screen = 1 - current_screen
    elseif event == EVT_TOUCH_TAP then
      if current_screen == 0 and touchState.x < (LCD_W / 2) then
        local new_index = mapToIndex(touchState.x,touchState.y)
        if new_index > 0 then
          updateIndex(new_index)
          if touchState.tapCount >= 2 then
            current_screen = 1
          end
        end
      else
        current_screen = 1 - current_screen
      end
    elseif event == EVT_TOUCH_SLIDE then
      if touchState.swipeLeft or touchState.swipeRight then
        current_screen = 1 - current_screen
      elseif touchState.swipeUp then
        if current_index > 1 then
          updateIndex(current_index - 1)
        end
      elseif touchState.swipeDown then
        if current_index < #files then
          updateIndex(current_index + 1)
        end
      end
    elseif event == EVT_VIRTUAL_DEC then
      if current_index > 1 then
        updateIndex(current_index - 1)
      end
    elseif event == EVT_VIRTUAL_INC then
      if current_index < #files then
        updateIndex(current_index + 1)
      end
    end
  end
  return false
end

local function run_func(event, touchState)
  if handle_keypress(event, touchState) then
    return 2
  end
  if current_screen == 0 then
      draw_select_screen()
  elseif current_screen == 1 then
      draw_view_screen()
  end
  return 0
end

return { init=init_func, run=run_func }
