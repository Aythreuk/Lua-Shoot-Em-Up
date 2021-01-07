-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load libraries and modules
local widget = require("widget")

-- Display groups etc.
local displayGroup1 = display.newGroup()

-- Music and audio
musicTrack1 = audio.loadStream("testmusic/Stella.mp3")
audio.reserveChannels(1)
audio.setVolume( 0.0, {channel = 1} )

-- Image sheet
local sheetOptions =
{
  frames = {
    {
      -- ani1
      x=1,
      y=1,
      width=300,
      height=300,

    },
    {
      -- ani2
      x=1,
      y=303,
      width=300,
      height=300,

    },
    {
      -- ani3
      x=1,
      y=605,
      width=300,
      height=300,

    },
    {
      -- ani4
      x=303,
      y=1,
      width=300,
      height=300,

    },
    {
      -- ani5
      x=605,
      y=1,
      width=300,
      height=300,

    },
    {
      -- ani6
      x=303,
      y=303,
      width=300,
      height=300,

    },
    {
      -- ani7
      x=303,
      y=605,
      width=300,
      height=300,

    },
    {
      -- ani8
      x=605,
      y=303,
      width=300,
      height=300,

    },
  },
}
local imageSheet = graphics.newImageSheet( "sheet1.png", sheetOptions )

-- Animation sequence table
local clockSequence = {
  {
    name = "clockFwd",
    start =  1,
    count = 8,
    time = 800,
    loopCount = 0,
    loopDirection = "forward"
  },
  {
    name = "clockBkwd",
    start =  1,
    count = 8,
    time = 800,
    loopCount = 0,
    loopDirection = "backward"
  },
}

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

--Let's create a rectangle or something
local shape1 = display.newRect (100, 150, 100, 100)
shape1:setFillColor(0.8, 0.4, 0.4, 1.0)

-- clock function
local function clockDirecChange ( event )
  local thisSprite = event.target
  if (thisSprite.sequence == "clockFwd") then
    print(thisSprite.sequence)
    thisSprite:setSequence("clockBkwd")
    thisSprite:play()
  else
    print(thisSprite.sequence)
    thisSprite:setSequence("clockFwd")
    thisSprite:play()
  end
end

-- Create clock sprite
local sprite = display.newSprite( imageSheet, clockSequence)
sprite.x = 125
sprite.y = 350
sprite.xScale = 0.50
sprite.yScale = 0.50
sprite:setSequence("clockFwd")
sprite:play()
sprite:addEventListener("touch", clockDirecChange)
