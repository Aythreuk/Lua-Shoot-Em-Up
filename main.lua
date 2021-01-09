-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Load libraries and modules
local widget = require("widget")
local physics = require("physics")
local math = require("math")
local timer = require("timer")
local Prototype = require( "CoronaPrototype" )

-- Initialization
math.randomseed(os.time())
physics.start()
physics.setGravity(0, 0)

-- Variables, groups etc.
ballNum, nesw, ballTable = 1, 0, {} -- Trying out some multiple assignment!
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

-- Let's get the circle moving around
local function moveCirc ()
  local a = math.random(1, 4)
  if (a == 1) then
    nesw = 1 -- To the north!
    circleHead:setLinearVelocity(0, -100)
  elseif (a == 2) then
    print("To the east!")
    nesw = 2
    circleHead:setLinearVelocity(100, 0)
  elseif (a == 3) then
    print("To the south!")
    nesw = 3
    circleHead:setLinearVelocity(0, 100)
  elseif (a == 4) then
    print("To the west!")
    nesw = 4
    circleHead:setLinearVelocity(-100, 0)
  end
  timer.performWithDelay((math.random(1, 5) * 1000), moveCirc)
end
timer.performWithDelay((math.random(1, 5) * 1000), moveCirc)

-- Let's create a circle
circleHead = display.newCircle(800, 100, 50)
circleHead:setFillColor(1, 0, 0)
physics.addBody(circleHead, "kinematic")

-- Guide circle back onto the screen
local function checkCirc ()
  if (circleHead.x < 0) then
    circleHead:setLinearVelocity(100, 0)
  elseif (circleHead.x > display.contentWidth) then
    circleHead:setLinearVelocity(-100, 0)
  elseif (circleHead.y < 0) then
    circleHead:setLinearVelocity(0, 100)
  elseif (circleHead.y > display.contentHeight) then
    circleHead:setLinearVelocity(0, -100)
  end
  timer.performWithDelay(200, checkCirc)
end
checkCirc()

-- Ball constructor
local ballClass = Prototype:newClass("ballClass")

function ballClass:initialize()
  ballNum = ballNum + 1
  local thisBall = "ball" .. ballNum
  thisBall = display.newCircle(0, 0, 50)
  thisBall:setFillColor(0, 1, 0)
  physics.addBody(thisBall, "kinematic")
  table.insert(ballTable, thisBall)
  if (nesw == 1) then
    thisBall.x = circleHead.x
    thisBall.y = circleHead.y + circleHead.height
  elseif (nesw == 2) then
    thisBall.x = circleHead.x - circleHead.width
    thisBall.y = circleHead.y
  elseif (nesw == 3) then
    thisBall.x = circleHead.x
    thisBall.y = circleHead.y - circleHead.height
  elseif (nesw == 4) then
    thisBall.x = circleHead.x + circleHead.width
    thisBall.y = circleHead.y
  end
end

-- Function to randomly spawn balls
local function spawnBall ()
  local ball = ballClass:new()
  timer.performWithDelay(math.random(1, 10) * 1000, spawnBall)
end
timer.performWithDelay(10000, spawnBall)
