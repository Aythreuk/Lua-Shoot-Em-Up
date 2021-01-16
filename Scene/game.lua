local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--Groups
local bgGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

-------------------------------------------------------------- DECLARE VARIABLES

-- Speed variables
local playerSpeed =
{
	ySpeed = 0,
	yMax = 100,
	yMin = 0,
	yIncrement = 5,
	xSpeed = 0,
	xMax = 400,
	xMin = -400,
	xIncrement = 20
}

local wDown, sDown, aDown, dDown -- Keyboard variables

-- Life variables
local playerLife =
{
playerMaxLife = 10,
playerMinLife = 0,
playerCurrentLife = 10
}
--------------------------------------------------------------- END OF VARIABLES

-- Load additional libraries
local physics = require("physics")

-- Initialization
physics.start()
physics.setGravity( 0, 0 )

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
		time = 1000,
		loopCount = 1
	},
	{
		name="rightTurn",
		frames= { 4, 5 }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="leftReturn",
		frames= { 3, 2, 1,  }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="rightReturn",
		frames= { 5, 4, 1 }, -- frame indexes of animation, in image sheet
		time = 1000,
		loopCount = 1
	},
	{
		name="aniRange",
		frames = {1, 2, 3 ,4 ,5}
	}
}
local playerSheet = graphics.newImageSheet("shipSpriteSheet1.png", options)

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Background
	-- Background default lay out is as below (Player begins on bg1)
	-- 6 2 4
	-- 5 1 3
	local bg1 = display.newImage( sceneGroup, "Images/background1.png" )
	local bg2 = display.newImage( sceneGroup, "Images/background1.png" )
	local bg3 = display.newImage( sceneGroup, "Images/background1.png" )
	local bg4 = display.newImage( sceneGroup, "Images/background1.png" )
	local bg5 = display.newImage( sceneGroup, "Images/background1.png" )
	local bg6 = display.newImage( sceneGroup, "Images/background1.png" )
	bg1.width = display.contentWidth * 2
	bg2.width = display.contentWidth * 2
	bg3.width = display.contentWidth * 2
	bg4.width = display.contentWidth * 2
	bg5.width = display.contentWidth * 2
	bg6.width = display.contentWidth * 2
	bg1.height = bg1.height * 2
	bg2.height = bg2.height * 2
	bg3.height = bg3.height * 2
	bg4.height = bg4.height * 2
	bg5.height = bg5.height * 2
	bg6.height = bg6.height * 2
	bg1.x = display.contentCenterX
	bg1.y = display.contentCenterY
	bg2.x = display.contentCenterX
	bg2.y = bg1.y - bg1.height
	bg3.x = bg1.x + bg1.width
	bg3.y = bg1.y
	bg4.x = bg2.x + bg2.width
	bg4.y = bg2.y
	bg5.x = bg1.x - bg1.width
	bg5.y = bg1.y
	bg6.x = bg2.x - bg2.width
	bg6.y = bg2.y
	bgGroup:insert(bg1)
	bgGroup:insert(bg2)
	bgGroup:insert(bg3)
	bgGroup:insert(bg4)
	bgGroup:insert(bg5)
	bgGroup:insert(bg6)

	-- health bar constructor
	local function makeLifeBar ( lifeBar, x )
		print( lifeBar, x )
		local lifeBar = display.newRect ( sceneGroup, x, display.contentHeight - 50, 50, 50)
		uiGroup:insert(lifeBar)
		lifeBar:toFront()
		lifeBar:setFillColor( 0.8, 0.2, 0.4 )
		lifeBar.name = "lifeBar" .. tostring(i)
		lifeBar.x = x

	end

	--ammo bar constructor


	-- Player UI
	-- Back of the UI
	local uiBack = display.newRect( uiGroup, display.contentCenterX,
	display.contentHeight - 50, display.contentWidth, 100 )
	uiBack:setFillColor( 0.3, 0.3, 0.3 )
	uiBack.strokeWidth = 5
	uiBack:setStrokeColor ( 0, 0, 0 )
	-- Make the life bar
	for i = 1, 10 do
		local newName = "lifeBar" .. tostring(i)
		local newX = i * 80
		makeLifeBar( newName, newX )
	end
--[[
	local bert = display.newRect ( sceneGroup, 100, 500, 50, 50)
	bert:setFillColor( 1, 0, 0 )
uiGroup:insert(bert)
bert:toFront()
print(bert)]]--

	-- Sprites
	local playerSprite = display.newSprite(sceneGroup, playerSheet, playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 400
	playerSprite:setSequence("aniRange")
	playerSprite:setFrame(1)
	physics.addBody(playerSprite, "dynamic")
	mainGroup:insert(playerSprite)

	local function fireMain() 																		-- Fire main weapons
		local newLaser = display.newImageRect( mainGroup, "Images/bullet1.png", 11, 31 )
		physics.addBody( newLaser, "dynamic", { isSensor=true } )
		newLaser.isBullet = true
		newLaser.myName = "laser"
		newLaser.x = playerSprite.x
		newLaser.y = playerSprite.y
		newLaser:toBack()
		transition.to( newLaser, { y=-40, time=500,
		onComplete = function() display.remove( newLaser ) end} )
	end

	-- adjust global speeds
	local function bgUpdate ()
		bg1:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg2:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg3:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg4:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg5:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg6:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		-- Backgrounds leave the screen southbound (north bound not possible)
		-- 6 2 4
		-- 5 1 3
		if (bg1.y > display.contentHeight * 1.5) then -- if bg1 leaves the screen on the
			bg1.y = bg2.y - bg2.height						-- y axis, it moves up and takes it's
			bg3.y = bg4.y - bg4.height						-- comrades with it
			bg5.y = bg6.y - bg6.height
		end
		if (bg2.y > display.contentHeight * 1.5) then	-- same thing, next row
			bg2.y = bg1.y - bg1.height
			bg4.y = bg3.y - bg3.height
			bg6.y = bg5.y - bg5.height
		end

		-- yikes, this part is more complicated. Here we go boys.
		if (bg1.x > display.contentWidth * 2) then
			bg1.x = bg3.x - bg3.width
			bg2.x = bg4.x - bg4.width
		end
		if (bg3.x > display.contentWidth * 2) then
			bg3.x = bg5.x - bg5.width
			bg4.x = bg6.x - bg6.width
		end
		if (bg5.x > display.contentWidth * 2) then
			bg5.x = bg1.x - bg1.width
			bg6.x = bg2.x - bg2.width
		end

		if (bg1.x < -(display.contentWidth)) then
			bg1.x = bg3.x + bg3.width
			bg2.x = bg4.x + bg4.width
		end
		if (bg3.x < -(display.contentWidth)) then
			bg3.x = bg5.x + bg5.width
			bg4.x = bg6.x + bg6.width
		end
		if (bg5.x < -(display.contentWidth)) then
			bg5.x = bg1.x + bg1.width
			bg6.x = bg2.x + bg2.width
		end

	end

	-- WASD function
	local function wasdFunc ()
		-- auto slow down because it feels good
		if (playerSpeed.xSpeed < 0 and not aDown and not dDown) then
			playerSpeed.xSpeed = playerSpeed.xSpeed + playerSpeed.xIncrement / 2
			playerSprite:setLinearVelocity(playerSpeed.xSpeed, 0)
		elseif (playerSpeed.xSpeed > 0 and not aDown and not dDown) then
			playerSpeed.xSpeed = playerSpeed.xSpeed - playerSpeed.xIncrement / 2
			playerSprite:setLinearVelocity(playerSpeed.xSpeed, 0)
		end
		if (playerSpeed.ySpeed > 0 and not wDown and not sDown) then
			playerSpeed.ySpeed = playerSpeed.ySpeed - playerSpeed.yIncrement / 4
		end
		-- wasd keys
		if (wDown and playerSpeed.ySpeed < playerSpeed.yMax) then 							-- W key down
			playerSpeed.ySpeed = playerSpeed.ySpeed + playerSpeed.yIncrement
		end
		if (sDown and playerSpeed.ySpeed > playerSpeed.yMin) then 							-- S key down
			playerSpeed.ySpeed = playerSpeed.ySpeed - playerSpeed.yIncrement
		end
		if (aDown and playerSpeed.xSpeed > playerSpeed.xMin) then						-- A key down
			playerSpeed.xSpeed = playerSpeed.xSpeed - playerSpeed.xIncrement
		end
		if (dDown and playerSpeed.xSpeed < playerSpeed.xMax) then						-- D key down
			playerSpeed.xSpeed = playerSpeed.xSpeed + playerSpeed.xIncrement
		end
		-- play animations
		if (playerSpeed.xSpeed == 0) then
			playerSprite:setFrame(1)
		elseif (playerSpeed.xSpeed < 0 and playerSpeed.xSpeed > (playerSpeed.xMin / 2)) then
			playerSprite:setFrame(2)
		elseif (playerSpeed.xSpeed < (playerSpeed.xMin / 2)) then
			playerSprite:setFrame(3)
		elseif (playerSpeed.xSpeed > 0 and playerSpeed.xSpeed < (playerSpeed.xMax / 2)) then
			playerSprite:setFrame(4)
		elseif (playerSpeed.xSpeed > (playerSpeed.xMax / 2)) then
			playerSprite:setFrame(5)
		end
		if (playerSpeed.ySpeed < 0 ) then -- Preventing a bug where playerSpeed went below zero
			playerSpeed.ySpeed = 0
		end
		playerSprite:setLinearVelocity(playerSpeed.xSpeed, 0)
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
			end
			if (event.phase == "up" and event.keyName == "w") then
				wDown = false
			end
			-- S button
			if (event.phase == "down" and event.keyName == "s") then
				sDown = true
			end
			if (event.phase == "up" and event.keyName == "s") then
				sDown = false
			end
			-- A button
			if (event.phase == "down" and event.keyName == "a") then
				aDown = true
			end
			if (event.phase == "up" and event.keyName == "a") then
				aDown = false
			end
			-- D button
			if (event.phase == "down" and event.keyName == "d") then
				dDown = true
			end
			if (event.phase == "up" and event.keyName == "d") then
				dDown = false
			end
			-- K button
			if (event.phase == "down" and event.keyName == "k") then
				fireMain()
				print(lifeBar4)
			end
			return false
		end



		-- Update function called every frame
		local function frameListener( event )
			bgUpdate()
			wasdFunc()
		end

		-- Listeners
		Runtime:addEventListener( "key", onKeyEvent )
		Runtime:addEventListener( "enterFrame", frameListener )

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
