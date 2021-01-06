-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load libraries and modules
local widget = require("widget")

-- Music and audio
musicTrack1 = audio.loadStream("testmusic/Stella.mp3")
audio.reserveChannels(1)
audio.setVolume( 0.0, {channel = 1} )

-- Start music function
local function startMusic ( event )
  if (event.phase == "ended") then
    audio.play(musicTrack1, {channel = 1} )
    audio.fade({channel = 1, time = 2000, volume = 1.0})
  end
end

-- Create start music button
local button1 = widget.newButton (
{
  left = 0,
  top = 0,
  id = "button1",
  label = "Start music",
  onEvent = startMusic
}
)

-- Stop music function
local function stopMusic ( event )
  if (event.phase == "ended") then
    audio.fadeOut({channel = 1, time = 2000})
  end
end

-- Create stop music button
local button2 = widget.newButton (
{
  left = 0,
  top = 50,
  id = "button2",
  label = "Stop music",
  onEvent = stopMusic
}
)

--[[ Let's create a rectangle or something
local shape1 = display.newRect (100, 150, 100, 100)
shape1:setFillColor(0.8, 0.4, 0.4, 1.0)

-- Picker pickerTable
local pickerTable = {
"Red",
"Green",
"Blue"
}

-- Let's try use the PickerWheelWidget
local picker1 = widget.newPickerWheel ({
top = 200,
left = 0,
columns = pickerTable,
})
--]]
