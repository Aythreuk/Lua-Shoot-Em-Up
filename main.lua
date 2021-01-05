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

-- Start music function
local function startMusic ( event )
  if (event.phase == "began") then
    audio.play(musicTrack1, {channel = 1} )
  end
end

-- Create start music button
local button1 = widget.newButton (
{
  left = 50,
  top = 50,
  id = "button1",
  label = "Start music",
  onEvent = startMusic
}
)

-- Stop music function
local function stopMusic ( event )
  print(audio.isChannelActive(1))
  if (event.phase == "ended") then
    audio.stop( 1 )
    audio.dispose(musicTrack1)
  end
end

-- Create stop music button
local button2 = widget.newButton (
{
  left = 50,
  top = 150,
  id = "button2",
  label = "Stop music",
  onEvent = stopMusic
}
)
