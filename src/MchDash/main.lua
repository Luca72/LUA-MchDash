---- ############################ CONFIGURATION ##############################

-- WIDGET NAME
local widgetName = "MchDash"

-- CONFIGURATION
local MODE_SWITCH_PRES = true
local CENT_LOCK_PRES = true
local REAR_LOCK_PRES = true
local FRONT_LOCK_PRES = true

-- SWITCHES
local SW_MODE = 'se'       -- -100% = main_A pic | 0% = main_B pic | 100% = main_C pic
local SW_CENT_LOCK = 'sd'  -- -100% = no lock | >= 0% = lock
local SW_AXLES_LOCK = 'sa' -- -100% = no lock | 0% = rear lock | 100% = front lock

-- CHANNELS
local OUT_PUMP = 'ch3'     -- pump output channel

---- #########################################################################


-- Widget options
local defaultOptions = {
  { "CellCount", VALUE, 3 }, -- number of cells
  { "Color", COLOR, WHITE },
  { "BackColor", COLOR, 0x3186 },
}

-- Data gathered from commercial lipo sensors
local _lipoPercentListSplit = {
  { { 3, 0 }, { 3.093, 1 }, { 3.196, 2 }, { 3.301, 3 }, { 3.401, 4 }, { 3.477, 5 }, { 3.544, 6 }, { 3.601, 7 }, { 3.637, 8 }, { 3.664, 9 }, { 3.679, 10 }, { 3.683, 11 }, { 3.689, 12 }, { 3.692, 13 } },
  { { 3.705, 14 }, { 3.71, 15 }, { 3.713, 16 }, { 3.715, 17 }, { 3.72, 18 }, { 3.731, 19 }, { 3.735, 20 }, { 3.744, 21 }, { 3.753, 22 }, { 3.756, 23 }, { 3.758, 24 }, { 3.762, 25 }, { 3.767, 26 } },
  { { 3.774, 27 }, { 3.78, 28 }, { 3.783, 29 }, { 3.786, 30 }, { 3.789, 31 }, { 3.794, 32 }, { 3.797, 33 }, { 3.8, 34 }, { 3.802, 35 }, { 3.805, 36 }, { 3.808, 37 }, { 3.811, 38 }, { 3.815, 39 } },
  { { 3.818, 40 }, { 3.822, 41 }, { 3.825, 42 }, { 3.829, 43 }, { 3.833, 44 }, { 3.836, 45 }, { 3.84, 46 }, { 3.843, 47 }, { 3.847, 48 }, { 3.85, 49 }, { 3.854, 50 }, { 3.857, 51 }, { 3.86, 52 } },
  { { 3.863, 53 }, { 3.866, 54 }, { 3.87, 55 }, { 3.874, 56 }, { 3.879, 57 }, { 3.888, 58 }, { 3.893, 59 }, { 3.897, 60 }, { 3.902, 61 }, { 3.906, 62 }, { 3.911, 63 }, { 3.918, 64 } },
  { { 3.923, 65 }, { 3.928, 66 }, { 3.939, 67 }, { 3.943, 68 }, { 3.949, 69 }, { 3.955, 70 }, { 3.961, 71 }, { 3.968, 72 }, { 3.974, 73 }, { 3.981, 74 }, { 3.987, 75 }, { 3.994, 76 } },
  { { 4.001, 77 }, { 4.007, 78 }, { 4.014, 79 }, { 4.021, 80 }, { 4.029, 81 }, { 4.036, 82 }, { 4.044, 83 }, { 4.052, 84 }, { 4.062, 85 }, { 4.074, 86 }, { 4.085, 87 }, { 4.095, 88 } },
  { { 4.105, 89 }, { 4.111, 90 }, { 4.116, 91 }, { 4.12, 92 }, { 4.125, 93 }, { 4.129, 94 }, { 4.135, 95 }, { 4.145, 96 }, { 4.176, 97 }, { 4.179, 98 }, { 4.193, 99 }, { 4.2, 100 } },
}

-- channels values
local max_channel = 1024
local min_channel = -1024
local SW_STATE_LOW = -1000
local SW_STATE_HIGH = 1000
local SW_STATE_CENT_MIN = -10
local SW_STATE_CENT_MAX = 10


local function createWidget(zone, options)
 local bitmaps = {
    mainA = Bitmap.open("/WIDGETS/".. widgetName .. "/img/main_A.png"),
    mainB = Bitmap.open("/WIDGETS/".. widgetName .. "/img/main_B.png"),
    mainC = Bitmap.open("/WIDGETS/".. widgetName .. "/img/main_C.png"),
    fuelGauge = Bitmap.open("/WIDGETS/".. widgetName .. "/img/fuel_gauge.png"),
    fuelGaugeOFF = Bitmap.open("/WIDGETS/".. widgetName .. "/img/fuel_gauge_off.png"),
    oilGauge = Bitmap.open("/WIDGETS/".. widgetName .. "/img/oil_gauge.png"),
    fuelLampON = Bitmap.open("/WIDGETS/".. widgetName .. "/img/fuel_lamp_on.png"),
    fuelLampOFF = Bitmap.open("/WIDGETS/".. widgetName .. "/img/fuel_lamp_off.png"),
    centLockLampON = Bitmap.open("/WIDGETS/".. widgetName .. "/img/cent_lock_lamp_on.png"),
    centLockLampOFF = Bitmap.open("/WIDGETS/".. widgetName .. "/img/cent_lock_lamp_off.png"),
    rearLockLampON = Bitmap.open("/WIDGETS/".. widgetName .. "/img/rear_lock_lamp_on.png"),
    rearLockLampOFF = Bitmap.open("/WIDGETS/".. widgetName .. "/img/rear_lock_lamp_off.png"),            
    frontLockLampON = Bitmap.open("/WIDGETS/".. widgetName .. "/img/front_lock_lamp_on.png"),
    frontLockLampOFF = Bitmap.open("/WIDGETS/".. widgetName .. "/img/front_lock_lamp_off.png"),                                
  }  

 local widget = {
    zone = zone,
    options = options,

    isDataAvailable = false,
    cellPercent = 0,
    cellSum = 0,
    modelBitmap = bitmaps,
  }  
  
  collectgarbage()
  collectgarbage()
    
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
  lcd.setColor( CUSTOM_COLOR, widget.options.Color )
  
  return widget
end

local function updateWidget(widget, newOptions)
  if (widget == nil) then
    return
  end
  widget.options = newOptions
  lcd.setColor( CUSTOM_COLOR, widget.options.Color )
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
end

local function backgroundProcessWidget(widgetToProcessInBackground)
  return
end

--- This function return the percentage remaining in a single Lipo cel
--- since running on long array found to be very intensive to hrous cpu, we are splitting the list to small lists
local function getCellPercent(cellValue)
  local result = 0;

  for i1, v1 in ipairs(_lipoPercentListSplit) do
    --is the cellVal < last-value-on-sub-list? (first-val:v1[1], last-val:v1[#v1])
    if (cellValue <= v1[#v1][1]) then
      -- cellVal is in this sub-list, find the exact value
      for i2, v2 in ipairs(v1) do
        if v2[1] >= cellValue then
          result = v2[2]
          return result
        end
      end
    end
  end
  -- in case somehow voltage is too high (>4.2), don't return nil
  return 100
end


--- This function calculates the battery charge
local function calculateBatteryData(widget)
  widget.cellSum = getValue("RxBt")
  if widget.cellSum == 0 then
    widget.isDataAvailable = false
    return
  end
  --- average of all cells
  widget.cellAvg = widget.cellSum / widget.options.CellCount
  -- mainValue
  widget.isDataAvailable = true
  widget.cellPercent = getCellPercent(widget.cellAvg) -- use batt percentage by average cell voltage
end

--- Fuel gauge drawing function
local function drawFuelGauge(widget, position)
  height = 57
  width = 100
  posx = widget.zone.x + position.x
  posy = widget.zone.y + position.y
  
  -- no telemetry: draw disabled fuel gauge
  if widget.isDataAvailable == false then
    lcd.drawBitmap(widget.modelBitmap.fuelGaugeOFF, widget.zone.x + position.x, widget.zone.y + position.y)
    return
  end
  -- draw the gauge fixed bitmap  
  lcd.drawBitmap(widget.modelBitmap.fuelGauge, widget.zone.x + position.x, widget.zone.y + position.y)

  -- calculent needle parameters
  degrees = 4.4 - (widget.cellPercent / (100 / 2.50));

  xt = math.floor(posx + (width/2) + (math.sin(degrees) * (height/1.3)))
  yt = math.floor(posy + (height/1.1) + (math.cos(degrees) * (height/1.3)))

  x0 = math.floor(posx + (width/2))
  y0 = math.floor(posy + (height/1.1))
  x1 = math.floor(posx + (width/2) + (math.sin(degrees - 0.35) * (height/18)))
  y1 = math.floor(posy + (height/1.1) + (math.cos(degrees - 0.35) * (height/18)))
  x2 = math.floor(posx + (width/2) + (math.sin(degrees + 0.35) * (height/18)))
  y2 = math.floor(posy + (height/1.1) + (math.cos(degrees + 0.35) * (height/18)))
  x3 = math.floor(posx + (width/2) + (math.sin(degrees - 0.27) * (height/20)))
  y3 = math.floor(posy + (height/1.1) + (math.cos(degrees - 0.27) * (height/20)))
  x4 = math.floor(posx + (width/2) + (math.sin(degrees + 0.27) * (height/20)))
  y4 = math.floor(posy + (height/1.1) + (math.cos(degrees + 0.27) * (height/20)))
	
  -- draw needle
  lcd.drawLine(x0, y0, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x0, y1, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x2, y2, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x3, y3, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x4, y4, xt, yt, SOLID, CUSTOM_COLOR)  
end

--- Oil pump gauge drawing function
local function drawPumpGauge(widget, position)
  height = 120
  width = 120
  posx = widget.zone.x + position.x
  posy = widget.zone.y + position.y
  
  pumpValue = getValue(OUT_PUMP)
  if(pumpValue == nil) then
	return
  end

  -- draw the gauge fixed bitmap  
  lcd.drawBitmap(widget.modelBitmap.oilGauge, posx, posy)
  
  --Value from source in percentage
  pumpPercValue = pumpValue - min_channel;
  pumpPercValue = (pumpPercValue / (max_channel - min_channel)) * 100
  if pumpPercValue > 100 then
	pumpPercValue = 100
  elseif pumpPercValue < 0 then 
	pumpPercValue = 0
  end  

  -- calculent needle parameters
  --min = 5.51
  --max = 0.8
  degrees = 5.51 - (pumpPercValue / (100 / 4.74));

  xt = math.floor(posx + (width/2) + (math.sin(degrees) * (height/2.3)))
  yt = math.floor(posy + (height/2) + (math.cos(degrees) * (height/2.3)))

  x0 = math.floor(posx + (width/2))
  y0 = math.floor(posy + (height/2))
  x1 = math.floor(posx + (width/2) + (math.sin(degrees - 0.35) * (height/18)))
  y1 = math.floor(posy + (height/2) + (math.cos(degrees - 0.35) * (height/18)))
  x2 = math.floor(posx + (width/2) + (math.sin(degrees + 0.35) * (height/18)))
  y2 = math.floor(posy + (height/2) + (math.cos(degrees + 0.35) * (height/18)))
  x3 = math.floor(posx + (width/2) + (math.sin(degrees - 0.27) * (height/20)))
  y3 = math.floor(posy + (height/2) + (math.cos(degrees - 0.27) * (height/20)))
  x4 = math.floor(posx + (width/2) + (math.sin(degrees + 0.27) * (height/20)))
  y4 = math.floor(posy + (height/2) + (math.cos(degrees + 0.27) * (height/20)))
	
  -- draw needle
  lcd.drawLine(x0, y0, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x0, y1, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x2, y2, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x3, y3, xt, yt, SOLID, CUSTOM_COLOR)
  lcd.drawLine(x4, y4, xt, yt, SOLID, CUSTOM_COLOR)  
end

--- Main bitmap drawing function
local function drawMainBitmap(widget, position)
  if MODE_SWITCH_PRES then
    local working_mode = getValue(SW_MODE)
    if working_mode < SW_STATE_LOW then
      lcd.drawBitmap(widget.modelBitmap.mainA, widget.zone.x + position.x, widget.zone.y + position.y)
    elseif (SW_STATE_CENT_MIN < working_mode and working_mode < SW_STATE_CENT_MAX) then 
  	  lcd.drawBitmap(widget.modelBitmap.mainB, widget.zone.x + position.x, widget.zone.y + position.y)
    elseif working_mode > SW_STATE_HIGH then
	  lcd.drawBitmap(widget.modelBitmap.mainC, widget.zone.x + position.x, widget.zone.y + position.y)
    end
  else
    lcd.drawBitmap(widget.modelBitmap.mainA, widget.zone.x + position.x, widget.zone.y + position.y)
  end
end


--- Fuel lamp drawing function
local function drawFuelLamp(widget, position)
  if widget.cellPercent < 10 then
    if widget.isDataAvailable then
      lcd.drawBitmap(widget.modelBitmap.fuelLampON, widget.zone.x + position.x, widget.zone.y + position.y)
    else
      lcd.drawBitmap(widget.modelBitmap.fuelLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
    end
  else
    lcd.drawBitmap(widget.modelBitmap.fuelLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
  end
end

--- Central lock lamp drawing function
local function drawCentLockLamp(widget, position)
  local cent_lock = getValue(SW_CENT_LOCK)
  if cent_lock < SW_STATE_LOW then 
    lcd.drawBitmap(widget.modelBitmap.centLockLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
  else
    lcd.drawBitmap(widget.modelBitmap.centLockLampON, widget.zone.x + position.x, widget.zone.y + position.y)
  end
end

--- rear lock lamp drawing function
local function drawRearLockLamp(widget, position)
  local cent_lock = getValue(SW_CENT_LOCK)
  local axle_lock = getValue(SW_AXLES_LOCK)
  if (cent_lock > SW_STATE_LOW) or (CENT_LOCK_PRES == false) then 
    if axle_lock < SW_STATE_LOW then 
      lcd.drawBitmap(widget.modelBitmap.rearLockLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
    else
      lcd.drawBitmap(widget.modelBitmap.rearLockLampON, widget.zone.x + position.x, widget.zone.y + position.y)
    end   
  else
     lcd.drawBitmap(widget.modelBitmap.rearLockLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
  end
end

--- front lock lamp drawing function
local function drawFrontLockLamp(widget, position)
  local cent_lock = getValue(SW_CENT_LOCK)
  local axle_lock = getValue(SW_AXLES_LOCK)
  if (cent_lock > SW_STATE_LOW) or (CENT_LOCK_PRES == false) then 
    if axle_lock > SW_STATE_HIGH then 
      lcd.drawBitmap(widget.modelBitmap.frontLockLampON, widget.zone.x + position.x, widget.zone.y + position.y)
    else
      lcd.drawBitmap(widget.modelBitmap.frontLockLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
    end   
  else
     lcd.drawBitmap(widget.modelBitmap.frontLockLampOFF, widget.zone.x + position.x, widget.zone.y + position.y)
  end
end

local credits = "Dashboard V0.1 by Luca72"

--- Zone size: 70x39 1/8th top bar
local function refreshZoneTiny(widget)
  lcd.drawText (widget.zone.x, widget.zone.y, "CatM318: N/A", SMLSIZE)
end

--- Zone size: 160x32 1/8th
local function refreshZoneSmall(widget)
  lcd.drawText (widget.zone.x, widget.zone.y, "CatM318: N/A", SMLSIZE)
end

--- Zone size: 180x70 1/4th  (with sliders/trim) or Zone size: 225x98 1/4th  (no sliders/trim)
local function refreshZoneMedium(widget)
  lcd.drawText (widget.zone.x, widget.zone.y, "CatM318: N/A", SMLSIZE)
end

--- Zone size: 192x152 1/2
local function refreshZoneLarge(widget)
  lcd.drawText (widget.zone.x, widget.zone.y, "CatM318: N/A", SMLSIZE)
end

--- Zone size: 390x172 1/1 or Zone size: 460x252 1/1 (no sliders/trim/topbar)
local function refreshZoneXLarge(widget)
  local mainBitmapPos = { x = 0, y = 20 }
  local fuelGaugePos = { x = 350, y = 5 }
  local oilGaugePos = { x = 340, y = 90 }
  local fuelLampPos = { x = 310, y = 0 }
  local centLockLampPos = { x = 190, y = 0 }    
  local rearLockLampPos = { x = 220, y = 0 }    
  local frontLockLampPos = { x = 250, y = 0 }        
  
  -- draw dark grey background
  lcd.setColor( CUSTOM_COLOR, widget.options.BackColor)  -- set dark grey
  lcd.drawFilledRectangle(widget.zone.x - 10, widget.zone.y - 10, widget.zone.w + 20, widget.zone.h + 20, CUSTOM_COLOR)
  
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
  lcd.setColor( CUSTOM_COLOR, widget.options.Color )

  -- draw main bitmap
  drawMainBitmap(widget, mainBitmapPos)
  
  -- draw gauges
  drawFuelGauge(widget, fuelGaugePos)
  drawPumpGauge(widget, oilGaugePos)
  
  -- draw fuel lamp
  drawFuelLamp(widget, fuelLampPos)
  
  -- draw lockers lamp
  if CENT_LOCK_PRES then
    drawCentLockLamp(widget, centLockLampPos)
  end
  if REAR_LOCK_PRES then
    drawRearLockLamp(widget, rearLockLampPos)
  end
  if FRONT_LOCK_PRES then
    drawFrontLockLamp(widget, frontLockLampPos)
  end
  
  -- draw credits
  lcd.setColor( CUSTOM_COLOR, lcd.RGB(160,125,15))
  lcd.drawText(widget.zone.x + 290, widget.zone.y + widget.zone.h - 8, credits, LEFT + SMLSIZE + CUSTOM_COLOR)
  
  collectgarbage()
  collectgarbage()  
end


local function refreshWidget(widget)
  if (widget == nil) then
    return
  end
    
  calculateBatteryData(widget)
    
  if widget.zone.w > 380 and widget.zone.h > 165 then
    refreshZoneXLarge(widget)
  elseif widget.zone.w > 180 and widget.zone.h > 145 then
    refreshZoneLarge(widget)
  elseif widget.zone.w > 170 and widget.zone.h > 65 then
    refreshZoneMedium(widget)
  elseif widget.zone.w > 150 and widget.zone.h > 28 then
    refreshZoneSmall(widget)
  elseif widget.zone.w > 65 and widget.zone.h > 35 then
    refreshZoneTiny(widget)
  end
end

return { name=widgetName, options=defaultOptions, create=createWidget, update=updateWidget, refresh=refreshWidget, background=backgroundProcessWidget }
