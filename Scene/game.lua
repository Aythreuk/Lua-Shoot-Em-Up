local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local bgGroup = display.newGroup()																							-- Setup display groups
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local playerSpeed =																															-- Speed variables
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

local wDown, sDown, aDown, dDown, spaceDown, fireCd															-- Keyboard variables
local fireTimer

local playerStats =																															-- Player ammo, life, status, etc.
{
	maxLife = 10,
	minLife = 0,
	currentLife = 10,
	maxAmmo = 10,
	minAmmo = 0,
	currentAmmo = 10,
	fireRate = 500,
	bulletReady = true
}

-- Load additional libraries
local physics = require("physics")
local spriteSheets = require("Images.spriteSheets")

physics.start()																																	-- Initialization
physics.setGravity( 0, 0 )
native.setProperty( "mouseCursorVisible", false )

local playerSheet = graphics.newImageSheet("Images/shipSpriteSheet1.png",
spriteSheets.playerOptions)

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event ) 																									-- create()

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Variables and stuff  that has to be in the create scope
	local ammoBarTable, lifeBarTable = {}, {}

	-- bg constructor
	local function createBg ()
		local self = {}
		self = display.newImage( sceneGroup, "Images/background1.png" )
		self.width = display.contentWidth * 2
		self.height = display.contentHeight * 2
		bgGroup:insert( self )
		return self
	end
	local bg1 = createBg ()
	local bg2 = createBg ()
	local bg3 = createBg ()
	local bg4 = createBg ()
	local bg5 = createBg ()
	local bg6 = createBg ()
	-- Initial positions for the 6 background panels
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

	--boundary
	local boundaryLeft = display.newRect ( bgGroup, 125,
	display.contentHeight - 225,
	250, 250 )
	boundaryLeft:setFillColor ( 1, 0, 0, 0 )
	local boundaryRight = display.newRect ( bgGroup, display.contentWidth - 125,
	display.contentHeight - 225,
	250, 250 )
	boundaryRight:setFillColor ( 1, 0, 0, 0 )
	physics.addBody( boundaryLeft, "static" )
	physics.addBody( boundaryRight, "static" )

	-- Player UI
	local uiBack = display.newRect( uiGroup, display.contentCenterX,
	display.contentHeight - 50, display.contentWidth, 100 )
	uiBack:setFillColor( 0.3, 0.3, 0.3 )
	uiBack.strokeWidth = 10
	uiBack:setStrokeColor ( 0, 0, 0 )
	local uiBackCenter = display.newRect ( uiGroup, display.contentCenterX,
	display.contentHeight - 50, 10, 100)
	uiBackCenter:setFillColor ( 0, 0, 0 )

	-- Health bar constructor
	local function makeLifeBar ( x )
		local self = {}
		local x = x * 85
		self = display.newRect ( sceneGroup, x, display.contentHeight - 50, 50, 50)
		uiGroup:insert( self )
		self:toFront()
		table.insert ( lifeBarTable, self )
		self:setFillColor ( 0.8, 0.2, 0.4 )
	end
	local lifeBar10 = makeLifeBar ( 10 )
	local lifeBar9 = makeLifeBar ( 9 )
	local lifeBar8 = makeLifeBar ( 8 )
	local lifeBar7 = makeLifeBar ( 7 )
	local lifeBar6 = makeLifeBar ( 6 )
	local lifeBar5 = makeLifeBar ( 5 )
	local lifeBar4 = makeLifeBar ( 4 )
	local lifeBar3 = makeLifeBar ( 3 )
	local lifeBar2 = makeLifeBar ( 2 )
	local lifeBar1 = makeLifeBar ( 1 )

	-- Ammo bar constructor
	local function makeAmmoBar ( x )
		local self = {}
		local x = display.contentWidth - ( x * 85 )
		self = display.newRect ( sceneGroup, x, display.contentHeight - 50, 50, 50)
		uiGroup:insert ( self )
		self:toFront()
		self:setFillColor ( 0.2, 0.4, 0.8 )
		table.insert ( ammoBarTable, self )
	end
	local ammoBar10 = makeAmmoBar ( 10 )
	local ammoBar9 = makeAmmoBar ( 9 )
	local ammoBar8 = makeAmmoBar ( 8 )
	local ammoBar7 = makeAmmoBar ( 7 )
	local ammoBar6 = makeAmmoBar ( 6 )
	local ammoBar5 = makeAmmoBar ( 5 )
	local ammoBar4 = makeAmmoBar ( 4 )
	local ammoBar3 = makeAmmoBar ( 3 )
	local ammoBar2 = makeAmmoBar ( 2 )
	local ammoBar1 = makeAmmoBar ( 1 )

	-- Sprites
	local playerSprite = display.newSprite( sceneGroup, playerSheet,
	spriteSheets.playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 250
	playerSprite:setSequence("aniRange")
	playerSprite:setFrame(1)
	physics.addBody(playerSprite, "dynamic")
	mainGroup:insert(playerSprite)
	playerSprite.isFixedRotation = true

	-- update health supply
	local function updateHealth ()
		for i = playerStats.maxLife, playerStats.minLife + 1, -1 do
			if (i <= playerStats.currentLife) then
				lifeBarTable[i].alpha = 1
			else
				lifeBarTable[i].alpha = 0.25
			end
		end
	end

	-- update ammo supply
	local function updateAmmo ()
		for i = playerStats.maxAmmo, playerStats.minAmmo + 1, -1 do
			if (i <= playerStats.currentAmmo) then
				ammoBarTable[i].alpha = 1
			else
				ammoBarTable[i].alpha = 0.25
			end
		end
	end


	local function fireMain() 																		-- Fire main weapons
		if playerStats.bulletReady then
			local newLaser = display.newImageRect( mainGroup, "Images/bullet1.png",
			11, 31 )
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "laser"
			newLaser.x = playerSprite.x
			newLaser.y = playerSprite.y
			newLaser:toBack()
			transition.to( newLaser, { y=-40, time=500,
			onComplete = function() display.remove( newLaser ) end} )
			playerStats.bulletReady = false
			playerStats.currentAmmo = playerStats.currentAmmo - 1
			updateAmmo()
		end
	end

	local function playerFireTimer ()
		playerStats.bulletReady = true
		fireTimer = nil
		print("Refreshed the bullet")
	end

	-- adjust global speeds
	local function bgUpdate ()
		-- Backgrounds leave the screen southbound (north bound not possible)
		-- 6 2 4
		-- 5 1 3
		if (bg1.y > display.contentHeight * 2) then -- if bg1 leaves the screen on the
			bg1.y = bg2.y - bg2.height						-- y axis, it moves up and takes it's
			bg3.y = bg4.y - bg4.height						-- comrades with it
			bg5.y = bg6.y - bg6.height
		end
		if (bg2.y > display.contentHeight * 2) then	-- same thing, next row
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
		bg1:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg2:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg3:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg4:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg5:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
		bg6:translate( -(playerSpeed.xSpeed / 10), playerSpeed.ySpeed / 5)
	end

	local function keyUpdate ()																										-- WASD function
		if (playerSpeed.xSpeed < 0 and not aDown and not dDown) then								-- Automatically slow down
			playerSpeed.xSpeed = playerSpeed.xSpeed + playerSpeed.xIncrement / 2
		elseif (playerSpeed.xSpeed > 0 and not aDown and not dDown) then
			playerSpeed.xSpeed = playerSpeed.xSpeed - playerSpeed.xIncrement / 2
		end
		if (playerSpeed.ySpeed > 0 and not wDown and not sDown) then
			playerSpeed.ySpeed = playerSpeed.ySpeed - playerSpeed.yIncrement / 4
		end
		if (wDown and playerSpeed.ySpeed < playerSpeed.yMax) then 									-- W key down
			playerSpeed.ySpeed = playerSpeed.ySpeed + playerSpeed.yIncrement
		end
		if (sDown and playerSpeed.ySpeed > playerSpeed.yMin) then 									-- S key down
			playerSpeed.ySpeed = playerSpeed.ySpeed - playerSpeed.yIncrement
		end
		if (aDown and playerSpeed.xSpeed > playerSpeed.xMin) then										-- A key down
			playerSpeed.xSpeed = playerSpeed.xSpeed - playerSpeed.xIncrement
		end
		if (dDown and playerSpeed.xSpeed < playerSpeed.xMax) then										-- D key down
			playerSpeed.xSpeed = playerSpeed.xSpeed + playerSpeed.xIncrement
		end
		if (spaceDown and playerStats.currentAmmo > 0) then
			fireMain()
			if not fireTimer then
				fireTimer = timer.performWithDelay ( playerStats.fireRate, playerFireTimer )
			end
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
		-- change boundary opacity to warn player
		local approachingLeft = playerSprite.x - boundaryLeft.x
		local approachingRight = boundaryRight.x - playerSprite.x

		-- Preventing a bug where playerSpeed went below zero
		if (playerSpeed.ySpeed < 0 ) then
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
			-- Space button
			if (event.phase == "down" and event.keyName == "space") then
				spaceDown = true
			end
			if (event.phase == "up" and event.keyName == "space") then
				spaceDown = false
			end
			return false
		end

		-- Update function called every frame
		local function frameListener( event )
			bgUpdate()
			keyUpdate()
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
