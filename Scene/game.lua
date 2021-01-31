local composer = require( "composer" )
local Destroyer = require('Enemies.Destroyer')
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local bgGroup = display.newGroup()																							-- Setup display groups
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()


local wDown, sDown, aDown, dDown, spaceDown, fireCd															-- Keyboard variables
local fireTimer, recoveryTimer


-- Load additional libraries
local math = require("math")
local physics = require("physics")
local bulletModule = require("SpriteSheets.Bullets")
local shipModule = require("SpriteSheets.Ships")
local printTable = require("Scripts.printTable")
local effectsModule = require("SpriteSheets.Effects")

table.print = printTable


-- Image sheets
local playerSheet = graphics.newImageSheet("Images/shipSpriteSheet1.png",
shipModule.playerOptions)
local bullet1Sheet = graphics.newImageSheet("Images/bullet1_sheet.png",
bulletModule.bullet1Options)
local bullet2Sheet = graphics.newImageSheet("Images/bullet2_sheet.png",
bulletModule.bullet2Options)
local missile1Sheet = graphics.newImageSheet("Images/missile1_sheet.png",
bulletModule.missile1Options)
local enemy1Sheet = graphics.newImageSheet("Images/enemy1_sheet.png",
shipModule.enemy1Options)
local enemy4Sheet = graphics.newImageSheet("Images/enemy4_sheet.png",
shipModule.enemy4Options)
local laser1Sheet = graphics.newImageSheet("Images/laser1_sheet.png",
bulletModule.laser1Options)
local explosion1sheet = graphics.newImageSheet("Images/explosion1_sheet.png",
effectsModule.explosion1Options)
local enemy5Sheet = graphics.newImageSheet("Images/enemy5_sheet.png",
shipModule.enemy5Options)

-- Initialization
physics.start()
physics.setGravity( 0, 0 )
native.setProperty( "mouseCursorVisible", false )
-- Produces a different sequence each time (assuming enough time between invocations)
math.randomseed( os.time() )

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event ) 																									-- create()

	local sceneGroup = self.view
	sceneGroup:insert(bgGroup)
	sceneGroup:insert(mainGroup)
	sceneGroup:insert(uiGroup)
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Variables and stuff  that has to be in the create scope
	local ammoBarTable, lifeBarTable = {}, {}

	-- bg constructor
	local function createBg ()
		local self = {}
		self = display.newImage( sceneGroup, "Images/background4.png" )
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

	--boundary constructor
	local function makeBoundaries ( x )
		local self = {}
		self = display.newRect ( bgGroup, x, display.contentHeight - 225,
		80, 300 )
		self:setFillColor ( 1, 0, 0, 0.25 )
		physics.addBody( self, "static" )
		self.myName = "boundary"
		self.fill.effect = "generator.linearGradient"
		if ( x == 40 ) then
			self.fill.effect.color1 = { 0, 0, 0, 0 }
			self.fill.effect.color2 = { 1, 0, 0, 0.5 }
		else
			self.fill.effect.color1 = { 1, 0, 0, 0.5 }
			self.fill.effect.color2 = { 0, 0, 0, 0 }
		end
		self.fill.effect.position1  = { 0, 0 }
		self.fill.effect.position2  = { 1, 0 }
		return self
	end
	local boundaryLeft = makeBoundaries( 40 )
	local boundaryRight = makeBoundaries( display.contentWidth - 40 )

	-- Player UI
	-- health and ammo back
	local uiBack = display.newRect( uiGroup, display.contentCenterX,
	display.contentHeight - 50, display.contentWidth, 100 )
	uiBack:setFillColor( 0.3, 0.3, 0.3 )
	uiBack.strokeWidth = 10
	uiBack:setStrokeColor ( 0, 0, 0 )
	-- score back
	local uiback2Vertices = { 200, -25, 150, 25, -150, 25, -200, -25 }
	local uiBack2 = display.newPolygon( uiGroup, display.contentCenterX, 25,
	uiback2Vertices )
	uiBack2:setFillColor( 0.3, 0.3, 0.3 )
	uiBack2.strokeWidth = 5
	uiBack2:setStrokeColor ( 0, 0, 0 )
	-- seperator between ammo and health
	local uiBackCenter = display.newRect ( uiGroup, display.contentCenterX,
	display.contentHeight - 50, 10, 100)
	uiBackCenter:setFillColor ( 0, 0, 0 )
	-- score text
	local uiScoreText = display.newText( uiGroup, "0000000", display.contentCenterX,
	25, "Fonts/Black_Ops_One/BlackOpsOne-Regular.ttf", 36 )
	uiScoreText:setFillColor( 0, 0, 0 )

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
	shipModule.playerSequence)
	playerSprite.x = display.contentCenterX
	playerSprite.y = display.contentHeight - 250
	playerSprite.myName = "player"
	playerSprite:setSequence("aniRange")
	playerSprite:setFrame(1)
	physics.addBody(playerSprite, "dynamic")
	mainGroup:insert(playerSprite)
	playerSprite.isFixedRotation = true

	local function stopExplosion ( explosion )
		display.remove( explosion )
	end

	local function explosionEffect ( x, y )
		local explosion = display.newSprite( sceneGroup, explosion1sheet,
		effectsModule.explosion1Sequence )
		explosion.alpha = 0
		explosion.alpha = 1
		explosion.x = x
		explosion.y = y
		explosion:setSequence("normal")
		explosion:play()
		local myClosure = function () return stopExplosion( explosion ) end
		timer.performWithDelay( 1000, myClosure, 1)
	end


	local function playerIsDefeated ()
		explosionEffect( playerSprite.x, playerSprite.y )
		display.remove( playerSprite )
	end

	-- update health supply
	local function updateHealth ()
		for i = PlayerStats.maxLife, PlayerStats.minLife + 1, -1 do
			if (i <= PlayerStats.currentLife) then
				lifeBarTable[i].alpha = 1
			else
				lifeBarTable[i].alpha = 0.25
			end
		end
	end

	-- player recovered
	local function playerRecovered ()
		playerSprite.alpha = 1
		PlayerStats.recovering = false
	end

	-- player got hit
	local function playerHit ()
		PlayerStats.currentLife = PlayerStats.currentLife - 1
		if PlayerStats.currentLife >= 1 then
			updateHealth()
			playerSprite.alpha = 0.5
			PlayerStats.recovering = true
			timer.performWithDelay( 2000, playerRecovered )
		elseif PlayerStats.currentLife <= 0 then
			updateHealth()
			playerIsDefeated()
		end
	end

	-- sorting through raycast data
	function WasPlayerHit(hits)
		if not hits or nil == '' then return false end
		for i,v in ipairs(hits) do
			print(v.object.myName)
			if v.object.myName == "player" then return true end
		end
		return false
	end

	-- create enemy 1
	local EnemyClass = {}
	EnemyClass.__index = EnemyClass

	setmetatable(EnemyClass, {
		__call = function (cls, ...)
			return cls.newBomber(...)
		end,
	})

	----------------------------------------------------------------------- BOMBER
	function EnemyClass.newBomber()
		local self = setmetatable({}, EnemyClass)
		self = display.newSprite ( sceneGroup, enemy1Sheet, shipModule.enemy1Sequence )
		mainGroup:insert( self )
		self:setSequence("normal")
		self:play()
		physics.addBody( self, "dynamic" )
		self.isFixedRotation = true
		self.myName = "enemy"
		self.stats = {} -- Had to declare these out here for scoping
		self.stats.maxFireRate = 40
		self.stats.maxParticleSpeed = 40
		self.stats.maxHealth = 40
		self.stats.health = 0
		self.stats.fireRate = 0
		self.stats.particleSpeed = 0
		-- Let's spawn on a random side
		local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
		if (randomSide == 1) then
			self.x = -50
			self.y = math.random( -50, display.contentHeight / 2 )
		elseif (randomSide == 2) then
			self.x = math.random( -50, display.contentWidth )
			self.y = -50
		else
			self.x = display.contentWidth + 50
			self.y = math.random( -50, display.contentHeight / 2 )
		end
		-- Assign random stats to enemy
		local statTotal = 0
		repeat
			-- Make sure there is at least one point in everything
			local rand = math.random( 1, 3 )
			statTotal = statTotal + rand
			if self.stats.health == 0 then
				self.stats.health = rand
			elseif self.stats.fireRate == 0 then
				self.stats.fireRate = rand
			elseif self.stats.particleSpeed == 0 then
				self.stats.particleSpeed = rand
			else
				-- Randomly dish out remaining points
				local rand2 = 0
				local rand2 = math.random( 1, 3 )
				if (rand2 == 1 and self.stats.health < self.stats.maxHealth - 3) then
					self.stats.health = self.stats.health + rand
				elseif (rand2 == 2 and self.stats.fireRate < self.stats.maxFireRate - 3) then
					self.stats.fireRate = self.stats.fireRate + rand
				elseif (rand2 == 3 and
				self.stats.particleSpeed < self.stats.maxParticleSpeed - 3) then
					self.stats.particleSpeed = self.stats.particleSpeed + rand
				else
					print("There has been an error")
				end
			end
		until (statTotal > PlayerStats.score)
		print("Health: ", self.stats.health, "\nFire rate is: ", self.stats.fireRate,
		"\nParticle speed is: ", self.stats.particleSpeed)
		-- Move function
		local function moveEnemy( enemy )
			local randX, randY = math.random( -100, 100 ), math.random( -100, 100 )
			enemy:setLinearVelocity( randX, randY )
		end
		-- Smooth out movement and keep on screen
		local function enemyUpdate ( enemy )
			local xVel, yVel = enemy:getLinearVelocity()
			-- shepherd back onto the screen
			if (enemy.x < 100 and xVel <= 0) then
				xVel = math.random( 25, 100 )
			end
			if (enemy.x > display.contentWidth - 100 and xVel >= 0) then
				xVel = -(math.random( 25, 100 ))
			end
			if (enemy.y < 100 and yVel <= 0) then
				yVel = math.random( 25, 100 )
			end
			if (enemy.y > display.contentHeight / 2 and yVel >= 0) then
				yVel = -(math.random( 25, 100 ))
			end
			-- Slow down and look natural
			if xVel > 0 then xVel = xVel - 1 end
			if xVel < 0 then xVel = xVel + 1 end
			if yVel > 0 then yVel = yVel - 1 end
			if yVel < 0 then yVel = yVel + 1 end
			enemy:setLinearVelocity( xVel, yVel )
		end
		-- Attack function
		local function enemyFire ( enemy, newParticleTime )
			local newLaser = display.newSprite( sceneGroup, bullet1Sheet,
			bulletModule.bullet1Sequence )
			-- Add sprite listener
			newLaser:setSequence("normal")
			newLaser:play()
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "enemyBullet"
			newLaser.x = enemy.x
			newLaser.y = enemy.y
			mainGroup:insert(newLaser)
			newLaser:toBack()
			local randX = ((math.random( 0, 100 )) / 100) * display.contentWidth
			print(newParticleTime)
			transition.to( newLaser, { y= display.contentHeight + 50,
			x = randX, time=newParticleTime,
			onComplete = function() display.remove( newLaser ) end} )
			newLaser.isFixedRotation = true
			local adjVar = display.contentHeight - enemy.y
			local oppVar = randX - enemy.x
			newLaser.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
		end
		-- Call enemy behaviours
		local newFireTime = 5000 - self.stats.fireRate * 100
		local newParticleTime = 5000 - self.stats.particleSpeed * 50
		print(newParticleTime)
		local myClosure1 = function() return moveEnemy ( self ) end
		self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
		local myClosure2 = function() return enemyFire ( self, newParticleTime ) end
		self.tm2 = timer.performWithDelay( newFireTime, myClosure2, 0 )
		local myClosure3 = function() return enemyUpdate ( self ) end
		self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
		local statTotal = 0
		return self
	end

	-- -------------------------------------------------------------------- DESTROYER
	function EnemyClass.newDestroyer()
		local self = setmetatable({}, EnemyClass)
		self = display.newImage ( sceneGroup, "Images/enemy2.png" )
		mainGroup:insert( self )
		physics.addBody( self, "dynamic" )
		self.isFixedRotation = true
		self.myName = "enemy"
		self.stats = {} -- Had to declare these out here for scoping
		self.stats.maxFireRate = 40
		self.stats.maxParticleSpeed = 40
		self.stats.maxHealth = 40
		self.stats.health = 0
		self.stats.fireRate = 0
		self.stats.particleSpeed = 0
		self.tm1 = false
		self.tm2 = false
		self.tm3 = false
		self.tm4 = false
		self.tm5 = false
		self.tm6 = false
		self.tm7 = false
		-- Let's spawn on a random side
		local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
		if (randomSide == 1) then
			self.x = -50
			self.y = math.random( -50, display.contentHeight / 2 )
		elseif (randomSide == 2) then
			self.x = math.random( -50, display.contentWidth )
			self.y = -50
		else
			self.x = display.contentWidth + 50
			self.y = math.random( -50, display.contentHeight / 2 )
		end
		-- Assign random stats to enemy
		local statTotal = 0
		repeat
			-- Make sure there is at least one point in everything
			local rand = math.random( 1, 3 )
			statTotal = statTotal + rand
			if self.stats.health == 0 then
				self.stats.health = rand
			elseif self.stats.fireRate == 0 then
				self.stats.fireRate = rand
			elseif self.stats.particleSpeed == 0 then
				self.stats.particleSpeed = rand
			else
				-- Randomly dish out remaining points
				local rand2 = 0
				local rand2 = math.random( 1, 3 )
				if (rand2 == 1 and self.stats.health < self.stats.maxHealth - 3) then
					self.stats.health = self.stats.health + rand
				elseif (rand2 == 2 and self.stats.fireRate < self.stats.maxFireRate - 3) then
					self.stats.fireRate = self.stats.fireRate + rand
				elseif (rand2 == 3 and
				self.stats.particleSpeed < self.stats.maxParticleSpeed - 3) then
					self.stats.particleSpeed = self.stats.particleSpeed + rand
				else
					print("There has been an error")
				end
			end
		until (statTotal > PlayerStats.score)
		print("Health: ", self.stats.health, "\nFire rate is: ", self.stats.fireRate,
		"\nParticle speed is: ", self.stats.particleSpeed)
		-- create "beam"
		self._BEAM = nil
		local x1, y1, x2, y2, x3, y3, beamRight
		local function newBeam()
			local obj = nil
			local function getBeamEnd ( startX )
				return math.random(startX - 1000, startX + 1000), display.contentHeight + 1000
			end
			x1, y1 = self.x, self.y + self.height / 2
			x2, y2 = getBeamEnd(self.x)
			if x1 > x2 then
				beamRight = false
			else
				beamRight = true
			end
			x3, y3 = math.abs( x1 - x2 ), math.abs( y1 - y2 )
			obj = display.newLine( sceneGroup, x1, y1, x2, y2 )
			obj:setStrokeColor( 1, 0, 0, 0 )
			obj.strokeWidth = 4
			mainGroup:insert(obj)
			obj:toBack()
			physics.addBody( obj, "dynamic", { isSensor=true } )
			obj.isBullet = true
			obj.beamActive = false
			obj.myName = "enemyLaser"
			return obj
		end
		self._BEAM = newBeam()
		-- Move function
		local function moveEnemy( enemy )
			local randX, randY = math.random( -100, 100 ), math.random( -100, 100 )
			self:setLinearVelocity( randX, randY )
		end
		-- Smooth out movement and keep on screen
		local function enemyUpdate ( enemy )
			local xVel, yVel = enemy:getLinearVelocity()
			-- shepherd back onto the screen
			if (enemy.x < 100 and xVel <= 0) then
				xVel = math.random( 25, 100 )
			end
			if (enemy.x > display.contentWidth - 100 and xVel >= 0) then
				xVel = -(math.random( 25, 100 ))
			end
			if (enemy.y < 100 and yVel <= 0) then
				yVel = math.random( 25, 100 )
			end
			if (enemy.y > display.contentHeight / 2 and yVel >= 0) then
				yVel = -(math.random( 25, 100 ))
			end
			-- Slow down and look natural
			if xVel > 0 then xVel = xVel - 1 end
			if xVel < 0 then xVel = xVel + 1 end
			if yVel > 0 then yVel = yVel - 1 end
			if yVel < 0 then yVel = yVel + 1 end
			enemy:setLinearVelocity( xVel, yVel )
		end
		-- cease fire
		local function stopFiring ()
			self._BEAM.beamActive = false
			self._BEAM.strokeWidth = 4
			self._BEAM:setStrokeColor( 1, 0, 0, 0 )
			self._BEAM = newBeam()
		end
		-- Attack function
		local function enemyFire ()
			self._BEAM.beamActive = true
			self._BEAM.strokeWidth = 10
			self._BEAM:setStrokeColor( 1, 0, 0, 1 )
			self.tm6 = timer.performWithDelay( 1500, stopFiring )
		end
		-- warn player
		local function warnPlayer ()
			self._BEAM:setStrokeColor( 1, 0, 0, 0.5 )
			self.tm5 = timer.performWithDelay( 1500, enemyFire )
		end
		-- update beam position
		local function beamUpdate ()
			if self._BEAM then
				self._BEAM.x = self.x
				self._BEAM.y = self.y + self.height / 2
			end
		end
		-- ray cast periodically
		local function repeatedRayCast ()
			if ( self._BEAM and self._BEAM.beamActive and not PlayerStats.recovering ) then
				x1, y1 = self.x, self.y + self.height / 2
				if beamRight then
					x2 = x1 + x3
				else
					x2 = x1 - x3
				end
				y2 = y1 + y3
				local castResults = physics.rayCast( x1, y1, x2, y2, "unsorted" )
				local a = WasPlayerHit(castResults)
				if a == true then
					playerHit()
				end
			end
		end
		-- Call enemy behaviours
		local newFireTime = 10000 - self.stats.fireRate * 100
		print("Laser will begin every: ", newFireTime)
		local newParticleTime = 5000 - self.stats.particleSpeed * 50
		local myClosure1 = function() return moveEnemy () end
		self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
		local myClosure2 = function() return warnPlayer () end
		self.tm2 = timer.performWithDelay( newFireTime, myClosure2, 0 )
		local myClosure3 = function() return enemyUpdate ( self ) end
		self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
		local myClosure4 = function() return beamUpdate () end
		self.tm4 = timer.performWithDelay( 25, myClosure4, 0 )
		self.tm7 = timer.performWithDelay( 200, repeatedRayCast, 0 )
		local statTotal = 0
		return self
	end

	---------------------------------------------------------------------- FRIGATE
	function EnemyClass.newFrigate()
		local self = setmetatable({}, EnemyClass)
		self = display.newImage ( sceneGroup, "Images/enemy3.png" )
		mainGroup:insert( self )
		physics.addBody( self, "dynamic" )
		self.isFixedRotation = true
		self.myName = "enemy"
		self.stats = {} -- Had to declare these out here for scoping
		self.stats.maxFireRate = 40
		self.stats.maxBeamDuration = 40
		self.stats.maxHealth = 40
		self.stats.health = 0
		self.stats.fireRate = 0
		self.stats.beamDuration = 0
		self.stats.particleSpeed = 0
		self.stats.maxParticleSpeed = 40
		self.tm1 = false
		self.tm2 = false
		self.tm3 = false
		self.tm4 = false
		self.tm5 = false
		self.tm6 = false
		-- Let's spawn on a random side
		local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
		if (randomSide == 1) then
			self.x = -50
			self.y = math.random( -50, display.contentHeight / 2 )
		elseif (randomSide == 2) then
			self.x = math.random( -50, display.contentWidth )
			self.y = -50
		else
			self.x = display.contentWidth + 50
			self.y = math.random( -50, display.contentHeight / 2 )
		end
		-- Assign random stats to enemy
		local statTotal = 0
		repeat
			-- Make sure there is at least one point in everything
			local rand = math.random( 1, 4 )
			statTotal = statTotal + rand
			if self.stats.health == 0 then
				self.stats.health = rand
			elseif self.stats.fireRate == 0 then
				self.stats.fireRate = rand
			elseif self.stats.beamDuration == 0 then
				self.stats.beamDuration = rand
			elseif self.stats.particleSpeed == 0 then
				self.stats.particleSpeed = rand
			else
				-- Randomly dish out remaining points
				local rand2 = 0
				local rand2 = math.random( 1, 3 )
				if (rand2 == 1 and self.stats.health < self.stats.maxHealth - 3) then
					self.stats.health = self.stats.health + rand
				elseif (rand2 == 2 and self.stats.fireRate < self.stats.maxFireRate - 3) then
					self.stats.fireRate = self.stats.fireRate + rand
				elseif (rand2 == 3 and
				self.stats.beamDuration < self.stats.maxBeamDuration - 3) then
					self.stats.beamDuration = self.stats.beamDuration + rand
				elseif (rand2 == 4 and
				self.stats.particleSpeed < self.stats.maxParticleSpeed - 3) then
					self.stats.particleSpeed = self.stats.particleSpeed + rand
				else
					print("There has been an error")
				end
			end
		until (statTotal > PlayerStats.score)
		self.stats.beamDuration = self.stats.beamDuration * 50 + 1000
		print("Health: ", self.stats.health, "\nFire rate is: ", self.stats.fireRate,
		"\nParticle speed is: ", self.stats.beamDuration)
		-- create "beam"
		self._BEAM = nil
		local function newBeam()
			local obj = nil
			local x1, y1 = self.x, self.y + self.height / 4

			local function getBeamEnd ( startX )
				return math.random(startX - 1000, startX + 1000), display.contentHeight + 1000
			end

			local x2, y2 = getBeamEnd(self.x)
			obj = display.newLine( sceneGroup, x1, y1, x2, y2 )
			obj:setStrokeColor( 1, 0, 0, 0 )
			obj.strokeWidth = 4
			mainGroup:insert(obj)
			obj:toBack()
			physics.addBody( obj, "dynamic", { isSensor=true } )
			obj.isBullet = true
			obj.beamActive = false
			obj.myName = "enemyLaser"
			return obj
		end
		self._BEAM = newBeam()
		-- Move function
		local function moveEnemy( enemy )
			local randX, randY = math.random( -100, 100 ), math.random( -100, 100 )
			self:setLinearVelocity( randX, randY )
		end
		-- Smooth out movement and keep on screen
		local function enemyUpdate ( enemy )
			local xVel, yVel = enemy:getLinearVelocity()
			-- shepherd back onto the screen
			if (enemy.x < 100 and xVel <= 0) then
				xVel = math.random( 25, 100 )
			end
			if (enemy.x > display.contentWidth - 100 and xVel >= 0) then
				xVel = -(math.random( 25, 100 ))
			end
			if (enemy.y < 100 and yVel <= 0) then
				yVel = math.random( 25, 100 )
			end
			if (enemy.y > display.contentHeight / 2 and yVel >= 0) then
				yVel = -(math.random( 25, 100 ))
			end
			-- Slow down and look natural
			if xVel > 0 then xVel = xVel - 1 end
			if xVel < 0 then xVel = xVel + 1 end
			if yVel > 0 then yVel = yVel - 1 end
			if yVel < 0 then yVel = yVel + 1 end
			enemy:setLinearVelocity( xVel, yVel )
		end
		-- cease fire
		local function stopFiring ()
			self._BEAM.beamActive = false
			self._BEAM.strokeWidth = 4
			self._BEAM:setStrokeColor( 1, 0, 0, 0 )
			self._BEAM = newBeam()
		end
		-- Attack function
		local function enemyFire ()
			self._BEAM.beamActive = true_BEAM
			self._BEAM.strokeWidth = 10
			self._BEAM:setStrokeColor( 1, 0, 0, 1 )
			self.tm6 = timer.performWithDelay( self.stats.beamDuration, stopFiring )
		end
		-- warn player
		local function warnPlayer ()
			self._BEAM:setStrokeColor( 1, 0, 0, 0.5 )
			self.tm5 = timer.performWithDelay( 1500, enemyFire )
		end
		-- update beam position
		local function beamUpdate ()
			if self._BEAM then
				self._BEAM.x = self.x
				self._BEAM.y = self.y + self.height / 4
			end
		end

		-- Attack function
		local function enemyFire ( enemy, newParticleTime )
			local newLaser = display.newSprite( sceneGroup, bullet1Sheet,
			bulletModule.bullet1Sequence )
			-- Add sprite listener
			newLaser:setSequence("normal")
			newLaser:play()
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "enemyLaser"
			newLaser.x = enemy.x
			newLaser.y = enemy.y
			mainGroup:insert(newLaser)
			newLaser:toBack()
			local randX = ((math.random( 0, 100 )) / 100) * display.contentWidth
			print(newParticleTime)
			transition.to( newLaser, { y= display.contentHeight + 50,
			x = randX, time=newParticleTime,
			onComplete = function() display.remove( newLaser ) end} )
			newLaser.isFixedRotation = true
			local adjVar = display.contentHeight - enemy.y
			local oppVar = randX - enemy.x
			newLaser.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
		end

		-- Call enemy behaviours
		local newFireTime = 10000 - self.stats.fireRate * 100
		local newFireTime2 = 5000 - self.stats.fireRate * 100
		local newParticleTime = 5000 - self.stats.particleSpeed * 50
		print("Laser will begin every: ", newFireTime)
		local myClosure1 = function() return moveEnemy () end
		self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
		local myClosure2 = function() return warnPlayer () end
		self.tm2 = timer.performWithDelay( newFireTime, myClosure2, 0 )
		local myClosure3 = function() return enemyUpdate ( self ) end
		self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
		local myClosure4 = function() return beamUpdate () end
		self.tm4 = timer.performWithDelay( 25, myClosure4, 0 )
		local myClosure5 = function() return enemyFire ( self, newParticleTime ) end
		self.tm5 = timer.performWithDelay( newFireTime2, myClosure5, 0 )
		local statTotal = 0
		return self
	end

	--------------------------------------------------------------------- LAUNCHER
	function EnemyClass.newLauncher()
		local self = setmetatable({}, EnemyClass)
		self = display.newSprite ( sceneGroup, enemy5Sheet, shipModule.enemy5Sequence )
		mainGroup:insert( self )
		self:setSequence("normal")
		self:play()
		physics.addBody( self, "dynamic" )
		self.isFixedRotation = true
		self.myName = "enemy"
		self.stats = {} -- Had to declare these out here for scoping
		self.stats.maxFireRate = 40
		self.stats.maxParticleSpeed = 40
		self.stats.maxHealth = 40
		self.stats.health = 0
		self.stats.fireRate = 0
		self.stats.particleSpeed = 0
		self.stats.curveStrength = math.random( 1, 3 )
		self.stats.tm4 = false
		-- Let's spawn on a random side
		local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
		if (randomSide == 1) then
			self.x = -50
			self.y = math.random( -50, display.contentHeight / 2 )
		elseif (randomSide == 2) then
			self.x = math.random( -50, display.contentWidth )
			self.y = -50
		else
			self.x = display.contentWidth + 50
			self.y = math.random( -50, display.contentHeight / 2 )
		end
		-- Assign random stats to enemy
		local statTotal = 0
		repeat
			-- Make sure there is at least one point in everything
			local rand = math.random( 1, 3 )
			statTotal = statTotal + rand
			if self.stats.health == 0 then
				self.stats.health = rand
			elseif self.stats.fireRate == 0 then
				self.stats.fireRate = rand
			elseif self.stats.particleSpeed == 0 then
				self.stats.particleSpeed = rand
			else
				-- Randomly dish out remaining points
				local rand2 = 0
				local rand2 = math.random( 1, 3 )
				if (rand2 == 1 and self.stats.health < self.stats.maxHealth - 3) then
					self.stats.health = self.stats.health + rand
				elseif (rand2 == 2 and self.stats.fireRate < self.stats.maxFireRate - 3) then
					self.stats.fireRate = self.stats.fireRate + rand
				elseif (rand2 == 3 and
				self.stats.particleSpeed < self.stats.maxParticleSpeed - 3) then
					self.stats.particleSpeed = self.stats.particleSpeed + rand
				else
					print("There has been an error")
				end
			end
		until (statTotal > PlayerStats.score)
		print("Health: ", self.stats.health, "\nFire rate is: ", self.stats.fireRate,
		"\nParticle speed is: ", self.stats.particleSpeed)
		-- Move function
		local function moveEnemy( enemy )
			local randX, randY = math.random( -100, 100 ), math.random( -100, 100 )
			enemy:setLinearVelocity( randX, randY )
		end
		-- Smooth out movement and keep on screen
		local function enemyUpdate ( enemy )
			local xVel, yVel = enemy:getLinearVelocity()
			-- shepherd back onto the screen
			if (enemy.x < 100 and xVel <= 0) then
				xVel = math.random( 25, 100 )
			end
			if (enemy.x > display.contentWidth - 100 and xVel >= 0) then
				xVel = -(math.random( 25, 100 ))
			end
			if (enemy.y < 100 and yVel <= 0) then
				yVel = math.random( 25, 100 )
			end
			if (enemy.y > display.contentHeight / 2 and yVel >= 0) then
				yVel = -(math.random( 25, 100 ))
			end
			-- Slow down and look natural
			if xVel > 0 then xVel = xVel - 1 end
			if xVel < 0 then xVel = xVel + 1 end
			if yVel > 0 then yVel = yVel - 1 end
			if yVel < 0 then yVel = yVel + 1 end
			enemy:setLinearVelocity( xVel, yVel )
		end
		-- Attack function
		local function enemyFire ( enemy, newParticleTime )
			local newLaser = display.newSprite( sceneGroup, missile1Sheet,
			bulletModule.missile1Sequence )
			-- Add sprite listener
			newLaser:setSequence("normal")
			newLaser:play()
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "enemyBullet"
			newLaser.x = enemy.x
			newLaser.y = enemy.y
			mainGroup:insert(newLaser)
			newLaser:toBack()
			local xVel, yVel = math.random( -100, 100 ), math.random( 50, 100 )
			print( xVel, yVel )
			newLaser:setLinearVelocity( xVel, yVel )
			-- curve function
			local function curveMissile ( missile )
				local x, y = missile:getLinearVelocity()
				if x > 0 then x = x - self.stats.curveStrength end
				if x < 0 then x = x + self.stats.curveStrength end
				missile:setLinearVelocity( x, y )
			end
		end

		-- Call enemy behaviours
		local newFireTime = 5000 - self.stats.fireRate * 100
		local newParticleTime = 5000 - self.stats.particleSpeed * 50
		print(newParticleTime)
		local myClosure1 = function() return moveEnemy ( self ) end
		self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
		local myClosure2 = function() return enemyFire ( self, newParticleTime ) end
		self.tm2 = timer.performWithDelay( newFireTime, myClosure2, 0 )
		local myClosure3 = function() return enemyUpdate ( self ) end
		self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )

		local statTotal = 0
		return self
	end

	----------------------------------------------------------------------- RUNNER
	function EnemyClass.newRunner()
		local self = setmetatable({}, EnemyClass)
		self = display.newSprite ( sceneGroup, enemy4Sheet, shipModule.enemy4Sequence )
		mainGroup:insert( self )
		self:setSequence("normal")
		self:play()
		physics.addBody( self, "dynamic" )
		self.isFixedRotation = true
		self.myName = "enemy"
		self.stats = {} -- Had to declare these out here for scoping
		self.stats.particleSpeed = 0
		self.stats.maxParticleSpeed = 40
		self.stats.maxBullets = 10
		self.stats.bullets = 0
		self.stats.speed = 0
		self.stats.maxSpeed = 40
		self.stats.health = 1
		-- Let's spawn on a random side
		local randomSide = math.random( 1, 2 ) -- 1 is west, 2 is east
		if (randomSide == 1) then
			self.x = -50
			self.y = math.random( -50, display.contentHeight / 2 )
		elseif (randomSide == 2) then
			self.x = display.contentWidth + 50
			self.y = math.random( -50, display.contentHeight / 2 )
		end
		-- Assign random stats to enemy
		local statTotal = 0
		repeat
			-- Make sure there is at least one point in everything
			local rand = math.random( 1, 3 )
			statTotal = statTotal + rand
			if self.stats.particleSpeed == 0 then
				self.stats.particleSpeed = rand
			elseif self.stats.bullets == 0 then
				self.stats.bullets = rand
			elseif self.stats.speed == 0 then
				self.stats.speed = rand
			else
				-- Randomly dish out remaining points
				local rand2 = 0
				local rand2 = math.random( 1, 2 )
				if (rand2 == 1 and self.stats.bullets < self.stats.maxBullets) then
					self.stats.bullets = self.stats.bullets + 1
				elseif (rand2 == 2 and
				self.stats.particleSpeed < self.stats.maxParticleSpeed - 3) then
					self.stats.particleSpeed = self.stats.particleSpeed + rand
				elseif (rand2 == 3 and
				self.stats.speed < self.stats.maxSpeed - 3) then
					self.stats.speed = self.stats.speed + rand
				else
					print("There has been an error")
				end
			end
		until (statTotal > PlayerStats.score)
		print("Health: ", self.stats.health, "\nBullet amount is: ", self.stats.bullets,
		"\nParticle speed is: ", self.stats.particleSpeed)
		-- Move function
		self.stats.speed = 5000 - self.stats.speed * 50
		local function moveEnemy()
			local moveToX
			if randomSide == 1 then
				moveToX = math.random( display.contentWidth / 2, display.contentWidth )
			elseif randomSide == 2 then
				moveToX = -(math.random( display.contentWidth / 2, display.contentWidth ))
			end
			self.isFixedRotation = true
			local oppVar = moveToX
			local adjVar = -50 - self.y
			self.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
			transition.to( self, { y= -50, x = moveToX, time=self.stats.speed,
			onComplete = function() display.remove( self ) end} )
		end
		-- Attack function
		local randX = false
		local newParticleTime = 5000 - self.stats.particleSpeed * 50
		local function enemyFire ()
			local newLaser = display.newSprite( sceneGroup, bullet1Sheet,
			bulletModule.bullet1Sequence )
			-- Add sprite listener
			newLaser:setSequence("normal")
			newLaser:play()
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "enemyBullet"
			newLaser.x = self.x
			newLaser.y = self.y
			mainGroup:insert(newLaser)
			newLaser:toBack()
			if (randX and randomSide == 1) then
				randX = randX + 300
			elseif (randX and randomSide == 2) then
				randX = randX - 300
			end
			if randX == false then
				if randomSide == 1 then randX = self.x + math.random( 500, 1000 ) end
				if randomSide == 2 then randX = self.x + -(math.random( 500, 1000 )) end
			end
			transition.to( newLaser, { y= display.contentHeight + 50,
			x = randX, time=newParticleTime,
			onComplete = function() display.remove( newLaser ) end} )
			newLaser.isFixedRotation = true
			local adjVar = display.contentHeight - self.y
			local oppVar = randX - self.x
			newLaser.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
		end
		-- Call enemy behaviours
		moveEnemy()
		timer.performWithDelay( 1000, enemyFire, 3)
		local statTotal = 0
		return self
	end

	local instance1 = EnemyClass.newLauncher()
	local instance2 = EnemyClass.newLauncher()

	-- update ammo supply
	local function updateAmmo ()
		for i = PlayerStats.maxAmmo, PlayerStats.minAmmo + 1, -1 do
			if (i <= PlayerStats.currentAmmo) then
				ammoBarTable[i].alpha = 1
			else
				ammoBarTable[i].alpha = 0.25
			end
		end
	end

	local function fireMain() 																		-- Fire main weapons
		if PlayerStats.bulletReady then
			local newLaser = display.newSprite( sceneGroup, bullet2Sheet,
			bulletModule.bullet2Sequence )
			-- Add sprite listener
			newLaser:setSequence("normal")
			newLaser:play()
			physics.addBody( newLaser, "dynamic", { isSensor=true } )
			newLaser.isBullet = true
			newLaser.myName = "allyBullet"
			newLaser.x = playerSprite.x
			newLaser.y = playerSprite.y
			mainGroup:insert(newLaser)
			newLaser:toBack()
			transition.to( newLaser, { y=-40, time=500,
			onComplete = function() display.remove( newLaser ) end} )
			PlayerStats.bulletReady = false
			PlayerStats.currentAmmo = PlayerStats.currentAmmo - 1
			updateAmmo()
		end
	end

	local function rechargeAmmo ()
		if (PlayerStats.currentAmmo < PlayerStats.maxAmmo) then
			PlayerStats.currentAmmo = PlayerStats.currentAmmo + 1
		end
		updateAmmo()
	end
	timer.performWithDelay( PlayerStats.rechargeRate, rechargeAmmo, 0 )

	local function playerFireTimer ()
		PlayerStats.bulletReady = true
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

		if (bg1.x < -(display.contentWidth * 2)) then
			bg1.x = bg3.x + bg3.width
			bg2.x = bg4.x + bg4.width
		end
		if (bg3.x < -(display.contentWidth * 2)) then
			bg3.x = bg5.x + bg5.width
			bg4.x = bg6.x + bg6.width
		end
		if (bg5.x < -(display.contentWidth * 2)) then
			bg5.x = bg1.x + bg1.width
			bg6.x = bg2.x + bg2.width
		end
		bg1:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		bg2:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		bg3:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		bg4:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		bg5:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		bg6:translate( -(PlayerSpeed.xSpeed / 20), PlayerSpeed.ySpeed / 5)
		-- auto slow down moved to here so it slows down when you die and no longer
		-- have controls
		if (PlayerSpeed.xSpeed < 0 and not aDown and not dDown) then
			PlayerSpeed.xSpeed = PlayerSpeed.xSpeed + PlayerSpeed.xIncrement / 2
		elseif (PlayerSpeed.xSpeed > 0 and not aDown and not dDown) then
			PlayerSpeed.xSpeed = PlayerSpeed.xSpeed - PlayerSpeed.xIncrement / 2
		end
		if (PlayerSpeed.ySpeed > 0 and not wDown and not sDown) then
			PlayerSpeed.ySpeed = PlayerSpeed.ySpeed - PlayerSpeed.yIncrement / 4
		end
		-- trigger boundaries
		if ( playerSprite.x ) then
			if (playerSprite.x < 250) then
				boundaryLeft.alpha = 0.75
			elseif (playerSprite.x > display.contentWidth - 250) then
				boundaryRight.alpha = 0.75
			else
				boundaryLeft.alpha = 0
				boundaryRight.alpha = 0
			end
		end
	end

	local function keyUpdate ()																										-- WASD function
		if playerSprite.x then
			if (wDown and PlayerSpeed.ySpeed < PlayerSpeed.yMax) then 									-- W key down
				PlayerSpeed.ySpeed = PlayerSpeed.ySpeed + PlayerSpeed.yIncrement
			end
			if (sDown and PlayerSpeed.ySpeed > PlayerSpeed.yMin) then 									-- S key down
				PlayerSpeed.ySpeed = PlayerSpeed.ySpeed - PlayerSpeed.yIncrement
			end
			if (aDown and PlayerSpeed.xSpeed > PlayerSpeed.xMin) then										-- A key down
				PlayerSpeed.xSpeed = PlayerSpeed.xSpeed - PlayerSpeed.xIncrement
			end
			if (dDown and PlayerSpeed.xSpeed < PlayerSpeed.xMax) then										-- D key down
				PlayerSpeed.xSpeed = PlayerSpeed.xSpeed + PlayerSpeed.xIncrement
			end
			if (spaceDown and PlayerStats.currentAmmo > 0) then
				fireMain()
				if not fireTimer then
					fireTimer = timer.performWithDelay ( PlayerStats.fireRate, playerFireTimer )
				end
			end
			-- play animations
			if (PlayerSpeed.xSpeed == 0) then
				playerSprite:setFrame(1)
			elseif (PlayerSpeed.xSpeed < 0 and PlayerSpeed.xSpeed > (PlayerSpeed.xMin / 2)) then
				playerSprite:setFrame(2)
			elseif (PlayerSpeed.xSpeed < (PlayerSpeed.xMin / 2)) then
				playerSprite:setFrame(3)
			elseif (PlayerSpeed.xSpeed > 0 and PlayerSpeed.xSpeed < (PlayerSpeed.xMax / 2)) then
				playerSprite:setFrame(4)
			elseif (PlayerSpeed.xSpeed > (PlayerSpeed.xMax / 2)) then
				playerSprite:setFrame(5)
			end
			-- Preventing a bug where PlayerSpeed went below zero
			if (PlayerSpeed.ySpeed < 0 ) then
				PlayerSpeed.ySpeed = 0
			end
			playerSprite:setLinearVelocity(PlayerSpeed.xSpeed, 0)
		end
	end

	-- collision event
	local function onCollision( event )
		if ( event.phase == "began" ) then

			local obj1 = event.object1
			local obj2 = event.object2

			-- collisions with enemy lasers
			if ( obj1.myName == "enemyLaser" and obj2.myName == "player" ) then
				if (PlayerStats.recovering == false and obj1.beamActive == true ) then
					playerHit()
				end
			elseif ( obj1.myName == "player" and obj2.myName == "enemyLaser" ) then
				if (PlayerStats.recovering == false and obj2.beamActive == true) then
					playerHit()
				end
			end

			-- colliding with regular bullets
			if ( obj1.myName == "enemyBullet" and obj2.myName == "player" ) then
				if PlayerStats.recovering == false then
					display.remove( obj1 )
					playerHit()
				end
			elseif ( obj1.myName == "player" and obj2.myName == "enemyBullet" ) then
				if PlayerStats.recovering == false then
					display.remove( obj2 )
					playerHit()
				end
			end

			-- player bullets hitting enemies
			if ( obj1.myName == "allyBullet" and obj2.myName == "enemy" ) then
				display.remove( obj1 )
				obj2.stats.health = obj2.stats.health - 1
				if ( obj2.stats.health <= 0 ) then

					if obj2.tm1 then timer.cancel(obj2.tm1) end
					if obj2.tm2 then timer.cancel(obj2.tm2) end
					if obj2.tm3 then timer.cancel(obj2.tm3) end
					if obj2.tm4 then timer.cancel(obj2.tm4) end
					if obj2.tm5 then timer.cancel(obj2.tm5) end
					if obj2.tm6 then timer.cancel(obj2.tm6) end
					if obj2.tm7 then timer.cancel(obj2.tm7) end
					explosionEffect( obj2.x, obj2.y )
					display.remove(obj2._BEAM)
					obj2:removeSelf()
					obj2 = nil
				end
			elseif ( obj1.myName == "enemy" and obj2.myName == "allyBullet" ) then
				display.remove( obj2 )
				obj1.stats.health = obj1.stats.health - 1
				if ( obj1.stats.health <= 0 ) then
					if obj1.tm1 then timer.cancel(obj1.tm1) end
					if obj1.tm2 then timer.cancel(obj1.tm2) end
					if obj1.tm3 then timer.cancel(obj1.tm3) end
					if obj1.tm4 then timer.cancel(obj1.tm4) end
					if obj1.tm5 then timer.cancel(obj1.tm5) end
					if obj1.tm6 then timer.cancel(obj1.tm6) end
					if obj1.tm7 then timer.cancel(obj1.tm7) end
					explosionEffect( obj1.x, obj1.y )
					display.remove(obj1._BEAM)
					obj1:removeSelf()
					obj1 = nil
				end
			end

		end
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
		Runtime:addEventListener( "collision", onCollision )

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
