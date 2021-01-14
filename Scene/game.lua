local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Load additional libraries
local physics = require("physics")

-- Initialization
physics.start()

-- Declare variables
local playerSpeed, playerMaxSpeed, speedIncrement, playerMinSpeed = 0, 100, 5, 0 -- Speed variables
local wDown, sDown, aDown, dDown -- Keyboard variables

-- Image sheet frames
local options =
{
	frames = {
			{
					-- ship1
					x=1,
					y=1,
					width=94,
					height=100,

			},
			{
					-- ship2
					x=97,
					y=1,
					width=86,
					height=99,

			},
			{
					-- ship3
					x=273,
					y=1,
					width=76,
					height=99,

			},
			{
					-- ship4
					x=185,
					y=1,
					width=86,
					height=99,

			},
			{
					-- ship5
					x=351,
					y=1,
					width=76,
					height=99,

			},
	}
}

-- Sequence data
local playerSequence =
{
	{
			name="idle",
		 frames= { 1 }, -- frame indexes of animation, in image sheet
		 time = 240,
		 loopCount = 0
	},
{
		name="leftTurn",
	 frames= { 2, 3 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 1,
		loopDirection = "forward"
},
{
		name="rightTurn",
	 frames= { 4, 5 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 1
},
{
		name="leftReturn",
	 frames= { 3, 2, 1 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 1
},
{
		name="rightReturn",
	 frames= { 5, 4, 1 }, -- frame indexes of animation, in image sheet
	 time = 240,
	 loopCount = 1
}
}
local playerSheet = graphics.newImageSheet("shipSpriteSheet1.png", options)

-- adjust global speeds
local function speedUpdate ()
	bg1:setLinearVelocity( 0, playerSpeed * 10)
	bg2:setLinearVelocity( 0, playerSpeed * 10)
	--print(bg1, bg2, playerSpeed)
end

-- increase player speed function
local function increaseSpeed ()
	if (wDown == true and playerSpeed < playerMaxSpeed) then
		playerSpeed = playerSpeed + speedIncrement
		speedUpdate()
		timer.performWithDelay(100, increaseSpeed)
		print(tostring(playerSpeed))
	end
end

-- decrease player speed function
local function decreaseSpeed ()
	if (sDown == true and playerSpeed > playerMinSpeed) then
		playerSpeed = playerSpeed - speedIncrement
		speedUpdate()
		timer.performWithDelay(100, decreaseSpeed)
		print(tostring(playerSpeed))
	end
end

local function turnRight () -- Turn right function

end

local function turnLeft () -- Turn left function

end

-- Keyboard events
local function onKeyEvent ( event )
-- Escape button (mostly for testing)
if (event.phase == "down" and event.keyName == "escape") then
	print("Escape function was called")
	native.requestExit()
end
-- W button
if (event.phase == "down" and event.keyName == "w") then
	wDown = true
	timer.performWithDelay(100, increaseSpeed)
end
if (event.phase == "up" and event.keyName == "w") then
	wDown = false
end
-- S button
if (event.phase == "down" and event.keyName == "s") then
	sDown = true
	timer.performWithDelay(100, decreaseSpeed)
end
if (event.phase == "up" and event.keyName == "s") then
	sDown = false
end
-- A button
if (event.phase == "down" and event.keyName == "a") then
	playerSprite:setSequence("leftTurn")
	playerSprite:play()
	aDown = true
	turnLeft()
end
if (event.phase == "up" and event.keyName == "a") then
	aDown = false
	playerSprite:setSequence("leftReturn")
	playerSprite:play()
end
-- D button
if (event.phase == "down" and event.keyName == "d") then
	playerSprite:setSequence("rightTurn")
	playerSprite:play()
	dDown = true
	turnRight()
end
if (event.phase == "up" and event.keyName == "d") then
	playerSprite:setSequence("rightReturn")
	playerSprite:play()
	dDown = false
end
	return false
end

local function frameListener( event ) -- Function that is called every frame
    if ((bg1.y - bg1.height * 0.5) > (display.contentHeight)) then
			bg1.y = bg2.y - bg1.height
			print(bg1.y)
		end
		if ((bg2.y - bg2.height * 0.5) > display.contentHeight) then
			bg2.y = bg1.y - bg2.height
			print(bg2.y)
		end
end

-- Listeners
Runtime:addEventListener( "key", onKeyEvent )
Runtime:addEventListener( "enterFrame", frameListener )

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Background
	  bg1 = display.newImage(sceneGroup, "Images/background1.png",
display.contentCenterX, display.contentCenterY)
	  bg2 = display.newImage(sceneGroup, "Images/background1.png",
display.contentCenterX, bg1.y - bg1.height)
	bg1.width = display.contentWidth
	bg2.width = display.contentWidth
	physics.addBody(bg1, "kinematic")
	physics.addBody(bg2, "kinematic")

	-- Sprites
	playerSprite = display.newSprite(sceneGroup, playerSheet, playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 400
	playerSprite:setFrame(5)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
