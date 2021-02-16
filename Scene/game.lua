local composer = require( "composer" )
local Destroyer = require('Enemies.Destroyer')
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local bgGroup = display.newGroup()																							-- Setup display groups
local coverGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()


local wDown, sDown, aDown, dDown, spaceDown, fireCd															-- Keyboard variables
local fireTimer, recoveryTimer
local maxDifficulty, gameStage = 5000, 1


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
local explosion1sheet = graphics.newImageSheet("Images/explosion1_sheet.png",
effectsModule.explosion1Options)
local enemy5Sheet = graphics.newImageSheet("Images/enemy5_sheet.png",
shipModule.enemy5Options)

-- music
audio.reserveChannels( 1 ) -- channel 1 reserved for music tracks
audio.setVolume( 0.5, { channel = 1 } )
local backgroundMusic = audio.loadStream( "Audio/Track1_Relaxing_Planet.mp3" )
local backgroundMusicChannel = audio.play( backgroundMusic,
{ channel=1, loops=-1, fadein=3000 } )
print(audio.isChannelActive( 1 ))

-- sfx
local soundTable = {
  explosion1_sound = audio.loadSound( "Audio/explosion1_sound.wav" ),
  explosion2_sound = audio.loadSound( "Audio/explosion2_sound.wav" ),
  hit1 = audio.loadSound( "Audio/hit1.wav" ),
  hit2 = audio.loadSound( "Audio/hit2.wav" ),
  shoot1 = audio.loadSound( "Audio/shoot1.wav" ),
  button_002 = audio.loadSound( "Audio/button_002.wav" ),
  incoming = audio.loadSound( "Audio/incoming.wav" ),
}

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
  sceneGroup:insert(coverGroup)
  sceneGroup:insert(mainGroup)
  sceneGroup:insert(uiGroup)
  -- Code here runs when the scene is first created but has not yet appeared on screen

  -- Variables and stuff  that has to be in the create scope
  local ammoBarTable, lifeBarTable, enemyCount, enemyTable = {}, {}, 0, {}
  local currentBg = 1

  -- collection of background images for swapping
  local bgImageCache = {
    "Images/background1.png",
    "Images/background2.png",
    "Images/background3.png",
    "Images/background4.png",
  }

  --custom fade in and out because I don't trust transition.fadeIn/Out anymore
  local function customFade ( obj, direction )
    -- direction 1 is fading out and 2 is fading in
    if direction == 1 then
      obj.alpha = obj.alpha - 0.1
    elseif direction == 2 then
      obj.alpha = obj.alpha + 0.1
    else
      print("Some kind of error has occured")
    end
  end

  -- fancy screen text function
  local function textFlash ( textBox )
    audio.play( soundTable["incoming"])
    if textBox.isVisible == true then
      textBox.isVisible = false
    elseif textBox.isVisible == false then
      textBox.isVisible = true
    end
  end

  -- bg constructor
  local function createBg ( bgNum, x, y )
    local self = {}
    self = display.newImage( bgGroup, bgImageCache[bgNum] )
    self.width = display.contentWidth * 2
    self.height = display.contentHeight * 2
    self.x = x
    self.y = y
    bgGroup:insert( self )
    bgGroup:toBack()
    return self
  end
  local bg1 = createBg ( 1, display.contentCenterX, display.contentCenterY )
  local bg2 = createBg ( 1, display.contentCenterX, bg1.y - bg1.height )
  local bg3 = createBg ( 1, bg1.x + bg1.width, bg1.y )
  local bg4 = createBg ( 1, bg2.x + bg2.width, bg2.y )
  local bg5 = createBg ( 1, bg1.x - bg1.width, bg1.y )
  local bg6 = createBg ( 1, bg2.x - bg2.width, bg2.y )
  --background cover
  local bgCover = display.newRect( coverGroup, display.contentCenterX,
  display.contentCenterY, display.contentWidth, display.contentHeight )
  bgCover:toFront()
  bgCover:setFillColor( 0, 0, 0, 1 )
  local fadeOutClosure = function () customFade( bgCover, 1 ) end
  local fadeInClosure = function () customFade( bgCover, 2 ) end
  timer.performWithDelay( 100, fadeOutClosure, 10 )


  --boundary constructor
  local function makeBoundaries ( x )
    local self = {}
    self = display.newRect ( uiGroup, x, display.contentHeight - 225,
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
  -- screen text
  local uiScreenText = display.newText( uiGroup, "Entering new area!", display.contentCenterX,
  display.contentCenterY, "Fonts/Black_Ops_One/BlackOpsOne-Regular.ttf", 48 )
  uiScreenText:setFillColor( 1, 0, 0 )
  uiScreenText.isVisible = false
  local textFlashClosure = function () return textFlash ( uiScreenText ) end
  -- arrow for aiming
  local uiArrow = display.newImage( uiGroup, "Images/arrow.png",
  display.contentCenterX, display.contentHeight - 350 )
  uiArrow.alpha = 0.5
  -- Entering new area...
  timer.performWithDelay( 1000, textFlashClosure, 4 )

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
    local randomExplosion = math.random( 1, 2 )
    if randomExplosion == 1 then audio.play( soundTable["explosion1_sound"])
    elseif randomExplosion == 2 then audio.play( soundTable["explosion2_sound"]) end
    composer.setVariable( "finalScore", PlayerStats.score )
    composer.gotoScene( "Scene.scores", { time=800, effect="crossFade" } )
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
  updateHealth()

  -- player recovered
  local function playerRecovered ()
    playerSprite.alpha = 1
    PlayerStats.recovering = false
  end

  -- player got hit
  local function playerHit ()
    PlayerStats.currentLife = PlayerStats.currentLife - 1
    updateHealth()
    if PlayerStats.currentLife >= 1 then
      local randomHit = math.random( 1, 2 )
      if randomHit == 1 then
        audio.play( soundTable["hit1"] )
      elseif
      randomHit == 2 then audio.play( soundTable["hit2"] )
      end
      playerSprite.alpha = 0.5
      PlayerStats.recovering = true
      timer.performWithDelay( 2000, playerRecovered )
    elseif PlayerStats.currentLife <= 0 then
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

  -- update scoreboard
  local function updateScore ()
    uiScoreText.text = PlayerStats.score
  end

  -- create enemy 1
  local EnemyClass = {}
  EnemyClass.__index = EnemyClass

  setmetatable(EnemyClass, {
    __call = function (cls, ...)
      return cls.newBomber(...)
    end,
  })

  function EnemyClass.safeDestroy ( enemy )
    enemyCount = enemyCount + 1
    enemy:removeSelf()
  end

  -- Bullet attack function
  function EnemyClass.enemyFire ( enemy, newParticleTime, x, y )
    local newLaser = display.newSprite( sceneGroup, bullet1Sheet,
    bulletModule.bullet1Sequence )
    newLaser:setSequence("normal")
    newLaser:play()
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "enemyBullet"
    newLaser.x = x
    newLaser.y = y
    mainGroup:insert(newLaser)
    newLaser:toBack()
    local randX = ((math.random( 0, 100 )) / 100) * display.contentWidth
    transition.to( newLaser, { y= display.contentHeight + 50,
    x = randX, time=newParticleTime,
    onComplete = function() display.remove( newLaser ) end} )
    newLaser.isFixedRotation = true
    local adjVar = display.contentHeight - y
    local oppVar = randX - x
    newLaser.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
  end

  -- equalize stats with max
  function EnemyClass.equalize ( a, b ) -- I swear it's not as mysterious as it sounds
    if a >= b then a = b end
    return a
  end

  -- Move function
  function EnemyClass.moveEnemy( enemy )
    local randX = math.random( -enemy.stats.speed, enemy.stats.speed )
    local randY = math.random( -enemy.stats.speed, enemy.stats.speed )
    enemy:setLinearVelocity( randX, randY )
  end

  -- Smooth out movement and keep on screen
  function EnemyClass.enemyUpdate ( enemy )
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

  -- spawn randomly
  function EnemyClass.spawnRandom ( randomSide, enemy )
    if (randomSide == 1) then
      enemy.x = -50
      enemy.y = math.random( -50, display.contentHeight / 2 )
    elseif (randomSide == 2) then
      enemy.x = math.random( -50, display.contentWidth )
      enemy.y = -50
    else
      enemy.x = display.contentWidth + 50
      enemy.y = math.random( -50, display.contentHeight / 2 )
    end
  end

  -- Runner attack function
  function EnemyClass.runnerFire ( enemy, newParticleTime, x, y, randX, randomSide )
    print( particleTime )
    local newLaser = display.newSprite( sceneGroup, bullet1Sheet,
    bulletModule.bullet1Sequence )
    newLaser.x = x
    newLaser.y = y
    newLaser:setSequence("normal")
    newLaser:play()
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
    newLaser.myName = "enemyBullet"
    mainGroup:insert(newLaser)
    newLaser:toBack()
    if (randX and randomSide == 1) then
      randX = randX + 300
    elseif (randX and randomSide == 2) then
      randX = randX - 300
    end
    if randX == false then
      if randomSide == 1 then randX = x + math.random( 500, 1000 ) end
      if randomSide == 2 then randX = x + -(math.random( 500, 1000 )) end
    end
    transition.to( newLaser, { y= display.contentHeight + 50,
    x = randX, time=newParticleTime,
    onComplete = function() display.remove( newLaser ) end} )
    newLaser.isFixedRotation = true
    local adjVar = display.contentHeight - y
    local oppVar = randX - x
    newLaser.rotation = -((math.atan( oppVar / adjVar )) * 180 / math.pi)
  end

  ----------------------------------------------------------------------- BOMBER
  function EnemyClass.newBomber()
    local self = setmetatable({}, EnemyClass)
    enemyCount = enemyCount + 1
    self = display.newSprite ( sceneGroup, enemy1Sheet, shipModule.enemy1Sequence )
    mainGroup:insert( self )
    self:setSequence("normal")
    self:play()
    physics.addBody( self, "dynamic" )
    self.isFixedRotation = true
    self.myName = "enemy"
    self.stats = {} -- Had to declare these out here for scoping
    self.stats.maxSpeed = 400
    self.stats.speed = 100 + gameStage * 50
    self.stats.maxFireRate = 4000
    self.stats.fireRate = gameStage * 1000 -- max should be 4000
    self.stats.maxParticleSpeed = 2000
    self.stats.particleSpeed = gameStage * 500 -- max should be 2000
    self.stats.maxHealth = 4
    self.stats.health = 1 + gameStage
    self.worth = 10 + gameStage * 10
    -- max sure stats don't exceed maximum limits
    self.stats.speed = EnemyClass.equalize( self.stats.speed, self.stats.maxSpeed )
    self.stats.fireRate = EnemyClass.equalize( self.stats.fireRate, self.stats.maxFireRate )
    self.stats.particleSpeed = EnemyClass.equalize( self.stats.particleSpeed, self.stats.maxParticleSpeed )
    self.stats.health = EnemyClass.equalize( self.stats.health, self.stats.maxHealth )
    if self.stats.fireRate > 4000 then self.stats.fireRate = 4000 end
    if self.stats.particleSpeed > 2000 then self.stats.particleSpeed = 2000 end
    self.stats.fireRate = 5000 - self.stats.fireRate -- max atk speed should be 1per second
    self.stats.particleSpeed = 5000 - self.stats.particleSpeed -- max speed should be 3000
    print( "Speed: ", self.stats.speed, "\nFire rate: ", self.stats.fireRate,
    "\nParticle speed: ", self.stats.particleSpeed, "\nHealth: ", self.stats.health )
    -- Let's spawn on a random side
    local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
    EnemyClass.spawnRandom( randomSide, self )
    -- Call enemy behaviours
    local myClosure1 = function() return EnemyClass.moveEnemy ( self ) end
    self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
    local myClosure2 = function() return EnemyClass.enemyFire ( self, self.stats.particleSpeed,
      self.x, self.y ) end
      self.tm2 = timer.performWithDelay( self.stats.fireRate, myClosure2, 0 )
      local myClosure3 = function() return EnemyClass.enemyUpdate ( self ) end
      self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
      local statTotal = 0
      return self
    end

    -- -------------------------------------------------------------------- DESTROYER
    function EnemyClass.newDestroyer()
      local self = setmetatable({}, EnemyClass)
      enemyCount = enemyCount + 1
      self = display.newImage ( sceneGroup, "Images/enemy2.png" )
      mainGroup:insert( self )
      physics.addBody( self, "dynamic" )
      self.isFixedRotation = true
      self.myName = "enemy"
      self.stats = {} -- Had to declare these out here for scoping
      self.stats.maxSpeed = 400
      self.stats.speed = 100 + gameStage * 50
      self.stats.maxFireRate = 6000
      self.stats.fireRate = gameStage * 1500 -- max should be 6000 (considering the possible game stages)
      self.stats.maxHealth = 4
      self.stats.health = 1 + gameStage
      self.worth = 20 + gameStage * 10
      -- max sure stats don't exceed maximum limits
      self.stats.speed = EnemyClass.equalize( self.stats.speed, self.stats.maxSpeed )
      self.stats.fireRate = EnemyClass.equalize( self.stats.fireRate, self.stats.maxFireRate )
      self.stats.health = EnemyClass.equalize( self.stats.health, self.stats.maxHealth )
      if self.stats.fireRate > 6000 then self.stats.fireRate = 6000 end
      self.stats.fireRate = 10000 - self.stats.fireRate -- max atk speed should be 1per second
      self.tm1 = false
      self.tm2 = false
      self.tm3 = false
      self.tm4 = false
      self.tm5 = false
      self.tm6 = false
      self.tm7 = false
      print( "Speed: ", self.stats.speed, "\nFire rate: ", self.stats.fireRate,
      "\nParticle speed: ", self.stats.particleSpeed, "\nHealth: ", self.stats.health )
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
      print("Laser will begin every: ", newFireTime)
      local myClosure1 = function() return moveEnemy () end
      self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
      local myClosure2 = function() return warnPlayer () end
      self.tm2 = timer.performWithDelay( self.stats.fireRate, myClosure2, 0 )
      local myClosure3 = function() return enemyUpdate ( self ) end
      self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
      local myClosure4 = function() return beamUpdate () end
      self.tm4 = timer.performWithDelay( 25, myClosure4, 0 )
      self.tm7 = timer.performWithDelay( 200, repeatedRayCast, 0 )
      local statTotal = 0
      return self
    end

    ---------------------------------------------------------------------- FRIGATE

    -- deleted

    ----------------------------------------------------------------------- RUNNER
    function EnemyClass.newRunner()
      local self = setmetatable({}, EnemyClass)
      enemyCount = enemyCount + 1
      self = display.newSprite ( sceneGroup, enemy4Sheet, shipModule.enemy4Sequence )
      mainGroup:insert( self )
      self:setSequence("normal")
      self:play()
      physics.addBody( self, "dynamic", { isSensor=true } )
      self.isFixedRotation = true
      self.myName = "enemy"
      self.stats = {} -- Had to declare these out here for scoping
      self.stats.maxSpeed = 2000
      self.stats.speed = 100 + gameStage * 50
      self.stats.maxBullets = 6
      self.stats.bullets = 2 + gameStage
      self.stats.maxParticleSpeed = 2000
      self.stats.particleSpeed = gameStage * 500 -- max should be 2000
      self.stats.health = 1
      self.tm1 = false
      self.worth = 10 + gameStage * 10
      -- max sure stats don't exceed maximum limits
      self.stats.particleSpeed = EnemyClass.equalize( self.stats.particleSpeed, self.stats.maxParticleSpeed )
      if self.stats.speed > 2000 then self.stats.speed = self.stats.maxSpeed end
      if self.stats.particleSpeed > 2000 then self.stats.particleSpeed = 2000 end
      self.stats.particleSpeed = 5000 - self.stats.particleSpeed -- max speed should be 3000
      self.stats.speed = 6000 - self.stats.speed
      print( "Speed: ", self.stats.speed, "\nBullets: ", self.stats.bullets,
      "\nParticle speed: ", self.stats.particleSpeed, "\nHealth: ", self.stats.health )
      -- Let's spawn on a random side
      local randomSide = math.random( 1, 2 ) -- 1 is west, 2 is east
      if (randomSide == 1) then
        self.x = -50
        self.y = math.random( -50, display.contentHeight / 2 )
      elseif (randomSide == 2) then
        self.x = display.contentWidth + 50
        self.y = math.random( -50, display.contentHeight / 2 )
      end
      -- Move function
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
        onComplete = function()
          enemyCount = enemyCount - 1
          self:removeSelf()
        end} )
      end
      -- Call enemy behaviours
      moveEnemy()
      local myClosure = function() return EnemyClass.runnerFire ( self, self.stats.particleSpeed,
        self.x, self.y, false, randomSide ) end
        self.tm5 = timer.performWithDelay( 1000, myClosure, 3 )
        return self
      end

      EnemyClass.newRunner()
      EnemyClass.newRunner()
      EnemyClass.newRunner()

      -- new bg fade in
      local function fadeInBg ( bgNum )
        audio.stop( 1 )
        if gameStage == 2 then
          backgroundMusic = audio.loadStream( "Audio/Track_2_Bold_Pads.mp3" )
        elseif gameStage == 3 then
          backgroundMusic = audio.loadStream( "Audio/Track_3_Unknown_Signals.mp3" )
        elseif gameStage == 4 then
          backgroundMusic = audio.loadStream( "Audio/Track_4_Hyper.mp3" )
        else
          print("An error occured with the music")
        end
        backgroundMusicChannel = audio.play( backgroundMusic,
        { channel=1, loops=-1} )
        audio.fade( { channel=1, time=2000, volume=0.5 } )
        lastX = bg1.x
        lastY = bg1.y
        bg1 = createBg( bgNum, lastX, lastY )
        lastX = bg2.x
        lastY = bg2.y
        bg2 = createBg( bgNum, lastX, lastY )
        lastX = bg3.x
        lastY = bg3.y
        bg3 = createBg( bgNum, lastX, lastY )
        lastX = bg4.x
        lastY = bg4.y
        bg4 = createBg( bgNum, lastX, lastY )
        lastX = bg5.x
        lastY = bg5.y
        bg5 = createBg( bgNum, lastX, lastY )
        lastX = bg6.x
        lastY = bg6.y
        bg6 = createBg( bgNum, lastX, lastY )
        bgCover.alpha = 1
        local fadeOutClosure = function () customFade( bgCover, 1 ) end
        timer.performWithDelay( 200, fadeOutClosure, 10 )
      end

      -- old background fade out and pass value
      local function fadeOutBg ( bgNum ) -- Cover fades in
        if (bgNum ~= currentBg) then
          -- Entering new area...
          timer.performWithDelay( 1000, textFlashClosure, 4 )
          audio.play( soundTable["incoming"])
          currentBg = bgNum
          bgCover.alpha = 0
          audio.fadeOut( { channel=1, time=2000 } )
          local fadeInClosure = function () customFade( bgCover, 2 ) end
          timer.performWithDelay( 200, fadeInClosure, 10 )
          local myClosure = function () fadeInBg( bgNum ) end
          timer.performWithDelay( 2000, myClosure )
        end
      end

      local function spawnEnemies ( randShip, amountofEnemies )
        for i = 1, amountofEnemies do
          local rngNum = math.random( 1, randShip )
          if rngNum == 1 then
            EnemyClass.newBomber()
          elseif rngNum == 2 then
            EnemyClass.newRunner()
          elseif rngNum == 3 then
            EnemyClass.newDestroyer()
          elseif rngNum == 4 then
            EnemyClass.newDestroyer()
          else
            print("An error has occured")
          end
        end
      end

      local function gameLoop ()

        if enemyCount <= 0 then
          if PlayerStats.score <= 30 then
            EnemyClass.newBomber() -- no need to even call the function
            elseif PlayerStats.score > 30 and PlayerStats.score <= 100 then
              gameStage = 2
              fadeOutBg( 2 )
              local closure1 = function () return spawnEnemies( 2, 2 ) end
              timer.performWithDelay( 6000, closure1 )
            elseif PlayerStats.score > 100 and PlayerStats.score <= 200 then
              gameStage = 3
              fadeOutBg( 3 )
              local closure2 = function () return spawnEnemies( 2, 3 ) end
              timer.performWithDelay( 6000, closure2 )
            elseif PlayerStats.score > 200 and PlayerStats.score <= 300 then
              gameStage = 4
              fadeOutBg( 4 )
              local closure3 = function () return spawnEnemies( 3, 3 ) end
              timer.performWithDelay( 6000, closure3 )
            elseif PlayerStats.score > 300 and PlayerStats.score <= 500 then
              local closure4 = function () return spawnEnemies( 3, 4 ) end
              timer.performWithDelay( 6000, closure4 )
              --fadeOutBg( 4 )
            elseif PlayerStats.score > 500 and PlayerStats.score <= 700 then
              local closure5 = function () return spawnEnemies( 4, 4 ) end
              timer.performWithDelay( 6000, closure5 )
              --fadeOutBg( 4 )
            elseif PlayerStats.score > 700 and PlayerStats.score <= 1000 then
              local closure6 = function () return spawnEnemies( 4, 5 ) end
              timer.performWithDelay( 6000, closure6 )
              --fadeOutBg( 4 )
            elseif PlayerStats.score > 1000 then
              local closure7 = function () return spawnEnemies( 4, 6 ) end
              timer.performWithDelay( 6000, closure7 )
              --fadeOutBg( 4 )
            end
          end
        end
        local gameTimer = timer.performWithDelay( 6000, gameLoop, 0 )

        local function pointsforTimeLoop ()
          print("10 seconds has passed")
          PlayerStats.score = PlayerStats.score + 1
          updateScore()
        end
        local survivalPointsTimer = timer.performWithDelay( 10000, pointsforTimeLoop, 0)

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

        local function pointArrow ()
          if PlayerStats.aiming == -1 then
            uiArrow.rotation = -45
          elseif PlayerStats.aiming == 0 then
            uiArrow.rotation = 0
          elseif PlayerStats.aiming == 1 then
            uiArrow.rotation = 45
          end
        end

        local function fireMain() 																		-- Fire main weapons
          if PlayerStats.bulletReady then
            local newLaser = display.newSprite( sceneGroup, bullet2Sheet,
            bulletModule.bullet2Sequence )
            audio.play( soundTable["shoot1"])
            -- Add sprite listener
            newLaser:setSequence("normal")
            newLaser:play()
            physics.addBody( newLaser, "dynamic", { isSensor=true } )
            newLaser.isBullet = true
            newLaser.myName = "allyBullet"
            mainGroup:insert(newLaser)
            newLaser:toBack()
            newLaser.x = playerSprite.x
            newLaser.y = playerSprite.y
            if PlayerStats.aiming == -1 then
              xVar = playerSprite.x - 1000
              newLaser.rotation = -45
            elseif PlayerStats.aiming == 0 then
              xVar = playerSprite.x
            elseif PlayerStats.aiming == 1 then
              xVar = playerSprite.x + 1000
              newLaser.rotation = 45
            end
            transition.to( newLaser, { x = xVar, y=-50, time=500,
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
          -- also update the arrow position
          if PlayerStats.aiming == -1 then
            uiArrow.x = playerSprite.x - playerSprite.width
            uiArrow.y = playerSprite.y - playerSprite.height
          elseif PlayerStats.aiming == 0 then
            uiArrow.x = playerSprite.x
            uiArrow.y = playerSprite.y - playerSprite.height
          elseif PlayerStats.aiming == 1 then
            uiArrow.x = playerSprite.x + playerSprite.width
            uiArrow.y = playerSprite.y - playerSprite.height
          end
          -- auto slow down moved to here so it slows down when you die and no longer
          -- have controls
          if (PlayerSpeed.xSpeed < 0 and not aDown and not dDown) then
            PlayerSpeed.xSpeed = PlayerSpeed.xSpeed + PlayerSpeed.xIncrement / 2
          elseif (PlayerSpeed.xSpeed > 0 and not aDown and not dDown) then
            PlayerSpeed.xSpeed = PlayerSpeed.xSpeed - PlayerSpeed.xIncrement / 2
          end
          --[[
          if (PlayerSpeed.ySpeed > 0 and not wDown and not sDown) then
          PlayerSpeed.ySpeed = PlayerSpeed.ySpeed - PlayerSpeed.yIncrement / 4
        end
        --]]
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
            obj2.stats.health = obj2.stats.health - PlayerStats.damage
            if ( obj2.stats.health <= 0 ) then
              transition.cancel( obj2 )
              PlayerStats.score = math.floor(PlayerStats.score + obj2.worth)
              updateScore()
              enemyCount = enemyCount - 1
              local randomExplosion = math.random( 1, 2 )
              if randomExplosion == 1 then audio.play( soundTable["explosion1_sound"])
              elseif randomExplosion == 2 then audio.play( soundTable["explosion2_sound"]) end
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
            elseif ( obj2.stats.health > 0 )  then
              local randomHit = math.random( 1, 2 )
              if randomHit == 1 then audio.play( soundTable["hit1"] )
              elseif randomHit == 2 then audio.play( soundTable["hit2"] ) end
            end
          elseif ( obj1.myName == "enemy" and obj2.myName == "allyBullet" ) then
            display.remove( obj2 )
            obj1.stats.health = obj1.stats.health - PlayerStats.damage
            if ( obj1.stats.health <= 0 ) then
              transition.cancel ( obj1 )
              PlayerStats.score = math.floor(PlayerStats.score + obj1.worth)
              updateScore()
              enemyCount = enemyCount - 1
              local randomExplosion = math.random( 1, 2 )
              if randomExplosion == 1 then audio.play( soundTable["explosion1_sound"])
              elseif randomExplosion == 2 then audio.play( soundTable["explosion2_sound"]) end
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
            elseif ( obj1.stats.health > 0 )  then
              local randomHit = math.random( 1, 2 )
              if randomHit == 1 then audio.play( soundTable["hit1"] )
              elseif randomHit == 2 then audio.play( soundTable["hit2"] ) end
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
            --wDown = true -- disabled
            print(enemyCount)
          end
          if (event.phase == "up" and event.keyName == "w") then
            --wDown = false
          end
          -- S button
          if (event.phase == "down" and event.keyName == "s") then
            --sDown = true -- disabled
          end
          if (event.phase == "up" and event.keyName == "s") then
            --sDown = false
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
          -- q button
          if (event.phase == "down" and event.keyName == "q") then
            if (PlayerStats.aiming > -1 and PlayerStats.aiming <= 1) then
              PlayerStats.aiming = PlayerStats.aiming - 1
              pointArrow()
            end
          end
          -- e button
          if (event.phase == "down" and event.keyName == "e") then
            if (PlayerStats.aiming >= -1 and PlayerStats.aiming < 1) then
              PlayerStats.aiming = PlayerStats.aiming + 1
              pointArrow()
            end
          end
          return false
        end

        -- Update function called every frame
        local function frameListener( event )
          if PlayerStats.currentLife > 0 then
            bgUpdate()
            keyUpdate()
          end
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
          composer.removeScene( "Scene.game" )
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
