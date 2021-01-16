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

-- Declare variables
local playerSpeed, playerMaxSpeed, speedIncrement, playerMinSpeed, playerXSpeed = 0, 120, 2, 0, 0 -- Speed variables
local playerMaxXSpeed, playerMinXSpeed, playerXIncrement, playerMinSpeed = 500, -500, 20, 0 -- More speed variables
local wDown, sDown, aDown, dDown -- Keyboard variables

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
	local bg1 = display.newImage( sceneGroup, "Images/background1.png",
	display.contentCenterX, display.contentCenterY)
	local bg2 = display.newImage( sceneGroup, "Images/background1.png",
	display.contentCenterX, bg1.y - bg1.height * 2)
	local bg3 = display.newImage( sceneGroup, "Images/background1.png",
	bg1.x - bg1.width, display.contentCenterY)
	local bg4 = display.newImage( sceneGroup, "Images/background1.png",
	bg2.x + bg2.width, display.contentCenterY)
	local bg5 = display.newImage( sceneGroup, "Images/background1.png",
	bg2.x - bg2.width, display.contentCenterY)
	local bg6 = display.newImage( sceneGroup, "Images/background1.png",
	bg2.x - bg2.width, display.contentCenterY)
	bg1.width = display.contentWidth * 2
	bg2.width = display.contentWidth * 2
	bg3.width = display.contentWidth * 2
	bg4.width = display.contentWidth * 2
	bg1.height = bg1.height * 2
	bg2.height = bg2.height * 2
	bg3.height = bg3.height * 2
	bg4.height = bg4.height * 2
	bgGroup:insert(bg1)
	bgGroup:insert(bg2)
	bgGroup:insert(bg3)
	bgGroup:insert(bg4)

	-- health bar constructor
	local function makeLifeBar (args)
		local lifeBar = display.newRect ( sceneGroup, x, y, 50, 50)
		lifebar:setFillColor( 0.8, 0.2, 0.4 )
	end

	--ammo bar constructor


	-- Player UI
	local uiBack = display.newRect( uiGroup, display.contentCenterX,
	display.contentHeight - 50, display.contentWidth, 100 )
	uiBack:setFillColor( 0.3, 0.3, 0.3 )
	uiBack.strokeWidth = 5
	uiBack:setStrokeColor ( 0, 0, 0 )

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
		bg1:translate( -(playerXSpeed / 10), playerSpeed / 5)
		bg2:translate( -(playerXSpeed / 10), playerSpeed / 5)
		bg3:translate( -(playerXSpeed / 10), playerSpeed / 5)
		bg4:translate( -(playerXSpeed / 10), playerSpeed / 5)
		-- Backgrounds leave the screen +y
		if ((bg1.y - bg1.height * 0.5) > (display.contentHeight)) then
			bg1.y = bg2.y - bg1.height
		end
		if ((bg2.y - bg2.height * 0.5) > display.contentHeight) then
			bg2.y = bg1.y - bg2.height
		end
		if ((bg3.y - bg3.height * 0.5) > (display.contentHeight)) then
			bg3.y = bg1.y - bg1.height
		end
		if ((bg4.y - bg4.height * 0.5) > display.contentHeight) then
			bg4.y = bg2.y - bg2.height
		end

		-- backgrounds leave the screen +x
		if ((bg1.x - bg1.width * 0.5) > (display.contentWidth)) then
			bg1.x = bg3.x - bg1.width
		end
		if ((bg2.x - bg2.width * 0.5) > (display.contentWidth)) then
			bg2.x = bg1.x - bg1.width
		end
		if ((bg1.x - bg1.width * 0.5) > (display.contentWidth)) then
			bg1.x = bg3.x - bg1.width
		end
		if ((bg2.x - bg2.width * 0.5) > (display.contentWidth)) then
			bg2.x = bg1.x - bg1.width
		end

		-- backgrounds leave the screen -x
		if ((bg1.x - bg1.width * 0.5) < 0 ) then
			bg1.x = bg3.x - bg1.width
		end
		if ((bg2.x - bg2.width * 0.5) < 0 ) then
			bg2.x = bg1.x - bg1.width
		end
		if ((bg1.x - bg1.width * 0.5) < 0 ) then
			bg1.x = bg3.x - bg1.width
		end
		if ((bg2.x - bg2.width * 0.5) < 0 ) then
			bg2.x = bg1.x - bg1.width
		end
	end

	-- WASD function
	local function wasdFunc ()
		-- auto slow down because it feels good
		if (playerXSpeed < 0 and not aDown and not dDown) then
			playerXSpeed = playerXSpeed + playerXIncrement / 2
			playerSprite:setLinearVelocity(playerXSpeed, 0)
		elseif (playerXSpeed > 0 and not aDown and not dDown) then
			playerXSpeed = playerXSpeed - playerXIncrement / 2
			playerSprite:setLinearVelocity(playerXSpeed, 0)
		end
		if (playerSpeed > 0 and not wDown and not sDown) then
			playerSpeed = playerSpeed - speedIncrement / 4
		end
		-- wasd keys
		if (wDown and playerSpeed < playerMaxSpeed) then 							-- W key down
			playerSpeed = playerSpeed + speedIncrement
		end
		if (sDown and playerSpeed > playerMinSpeed) then 							-- S key down
			playerSpeed = playerSpeed - speedIncrement
		end
		if (aDown and playerXSpeed > playerMinXSpeed) then						-- A key down
			playerXSpeed = playerXSpeed - playerXIncrement
		end
		if (dDown and playerXSpeed < playerMaxXSpeed) then						-- D key down
			playerXSpeed = playerXSpeed + playerXIncrement
		end
		-- play animations
		if (playerXSpeed == 0) then
			playerSprite:setFrame(1)
		elseif (playerXSpeed < 0 and playerXSpeed > (playerMinXSpeed / 2)) then
			playerSprite:setFrame(2)
		elseif (playerXSpeed < (playerMinXSpeed / 2)) then
			playerSprite:setFrame(3)
		elseif (playerXSpeed > 0 and playerXSpeed < (playerMaxXSpeed / 2)) then
			playerSprite:setFrame(4)
		elseif (playerXSpeed > (playerMaxXSpeed / 2)) then
			playerSprite:setFrame(5)
		end
		if (playerSpeed < 0 ) then -- Preventing a bug where playerSpeed went below zero
			playerSpeed = 0
		end
		playerSprite:setLinearVelocity(playerXSpeed, 0)
		print(playerSpeed)
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
