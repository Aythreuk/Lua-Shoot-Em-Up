local bomberModule = {}

local gameModule = require("Scene.game")

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

return bomberModule
