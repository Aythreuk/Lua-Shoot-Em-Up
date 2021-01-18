local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local bgGroup = display.newGroup()																							-- Setup display groups
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local ammoBarTable, lifeBarTable, bgTable = {}, {}, {}													-- Tables

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

local wDown, sDown, aDown, dDown 																								-- Keyboard variables

local playerStats =																															-- Player ammo, life, status, etc.
{
	playerMaxLife = 10,
	playerMinLife = 0,
	playerCurrentLife = 10,
	playerMaxAmmo = 10,
	playerMinAmmo = 0,
	playerCurrentAmmo = 10,
	playerFireRate
}

local physics = require("physics")																							-- Load additional libraries
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

	local function makeBg ( i )																										-- Create the background
		for i = 1, 6 do																															-- Bg panels are like this:
			local bg = "bg" .. tostring(i)																						-- 6 2 4
			local bg = display.newImage( sceneGroup, "Images/background1.png" )				-- 5 1 3
			bg.width = display.contentWidth * 2																				-- Player starts on panel 1
			bg.height = bg.height * 2
			bgGroup:insert(bg)
			table.insert( bgTable, bg )
		end
	end
	makeBg()
	local bg1 = bgTable[1]
	local bg2 = bgTable[2]
	local bg3 = bgTable[3]
	local bg4 = bgTable[4]
	local bg5 = bgTable[5]
	local bg6 = bgTable[6]
	bg1.x = display.contentCenterX																								-- Position the 6 panels
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

	-- health bar constructor
	local function makeLifeBar ( lifeBar, x )
		local lifeBar = display.newRect ( sceneGroup, x, display.contentHeight - 50, 50, 50)
		uiGroup:insert(lifeBar)
		lifeBar:toFront()
		lifeBar:setFillColor( 0.8, 0.2, 0.4 )
		lifeBar.name = "lifeBar" .. tostring(i)
		lifeBar.x = x
		table.insert( lifeBarTable, lifeBar )
	end
	local lifeBar1 = lifeBarTable[1]
	local lifeBar2 = lifeBarTable[2]
	local lifeBar3 = lifeBarTable[3]
	local lifeBar4 = lifeBarTable[4]
	local lifeBar5 = lifeBarTable[5]
	local lifeBar6 = lifeBarTable[6]
	local lifeBar7 = lifeBarTable[7]
	local lifeBar8 = lifeBarTable[8]
	local lifeBar9 = lifeBarTable[9]
	local lifeBar10 = lifeBarTable[10]

	--ammo bar constructor
	local function makeAmmoBar ( ammoBar, x )
		local ammoBar = display.newRect ( sceneGroup, x, display.contentHeight - 50, 50, 50)
		uiGroup:insert( ammoBar )
		ammoBar:toFront()
		ammoBar:setFillColor( 0.2, 0.4, 0.8 )
		ammoBar.name = "ammoBar" .. tostring(i)
		ammoBar.x = x
		table.insert( ammoBarTable, ammoBar )
	end
	local ammoBar1 = ammoBarTable[1]
	local ammoBar2 = ammoBarTable[2]
	local ammoBar3 = ammoBarTable[3]
	local ammoBar4 = ammoBarTable[4]
	local ammoBar5 = ammoBarTable[5]
	local ammoBar6 = ammoBarTable[6]
	local ammoBar7 = ammoBarTable[7]
	local ammoBar8 = ammoBarTable[8]
	local ammoBar9 = ammoBarTable[9]
	local ammoBar10 = ammoBarTable[10]

	--boundary
	local boundaryLeft = display.newRect ( bgGroup, 125,
	display.contentHeight - 225,
	250, 250)
	boundaryLeft:setFillColor ( 1, 0, 0, 1)
	local boundaryRight = display.newRect ( bgGroup, display.contentWidth - 125,
	display.contentHeight - 225,
	250, 250)
	boundaryRight:setFillColor ( 1, 0, 0, 1)

	-- Player UI
	-- Back of the UI
	local uiBack = display.newRect( uiGroup, display.contentCenterX,
	display.contentHeight - 50, display.contentWidth, 100 )
	uiBack:setFillColor( 0.3, 0.3, 0.3 )
	uiBack.strokeWidth = 10
	uiBack:setStrokeColor ( 0, 0, 0 )
	local uiBackCenter = display.newRect ( uiGroup, display.contentCenterX,
	display.contentHeight - 50, 10, 100)
	uiBackCenter:setFillColor ( 0, 0, 0 )

	-- Make the life bar
	for i = 1, 10 do
		local newName = "lifeBar" .. tostring(i)
		local newX = i * 85
		makeLifeBar( newName, newX )
	end

	-- Make the ammo bar
	for i = 1, 10 do
		local newName = "ammoBar" .. tostring(i)
		local newX = display.contentWidth - (i * 85)
		makeAmmoBar( newName, newX )
	end

	-- Sprites
	local playerSprite = display.newSprite( sceneGroup, playerSheet,
 	spriteSheets.playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 250
	playerSprite:setSequence("aniRange")
	playerSprite:setFrame(1)
	physics.addBody(playerSprite, "dynamic")
	mainGroup:insert(playerSprite)

	local function fireMain() 																		-- Fire main weapons
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

	local function wasdFunc ()																										-- WASD function
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
