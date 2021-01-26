local _M = {}
local EnemyClass = require('Enemies.Enemy')

-- Inherit from EnemyClass
setmetatable(_M, {__index = EnemyClass})



function _M:new(group)
    -- display.newImage(parent,filename,baseDir,x,y);
    self.displayObject = display.newImage(group, "Images/enemy2.png")
    local obj = self.displayObject
    physics.addBody( obj, "dynamic" )
    obj.isFixedRotation = true
    self.myName = "enemy"
    self.stats = {} -- Had to declare these out here for scoping
    self.stats.maxFireRate = 40
    self.stats.maxParticleSpeed = 40
    self.stats.maxHealth = 40
    self.stats.health = 0
    self.stats.fireRate = 0
    self.stats.particleSpeed = 0
    self.stats.beamActive = false
    -- Let's spawn on a random side
    local randomSide = math.random( 1, 3 ) -- 1 is west, 2 is north, 3 is east
    if (randomSide == 1) then
        obj.x = -50
        obj.y = math.random( -50, display.contentHeight / 2 )
    elseif (randomSide == 2) then
        obj.x = math.random( -50, display.contentWidth )
        obj.y = -50
    else
        obj.x = display.contentWidth + 50
        obj.y = math.random( -50, display.contentHeight / 2 )
    end
    -- Assign random stats to enemy
    local statTotal = 0
    repeat
        -- Make sure there is at least one point in everything
        local rand = math.random( 1, 3 )
        statTotal = statTotal + rand
        -- TODO: check if this is what you meant, this will make all these values the same.
        if self.stats.health == 0 then
            self.stats.health = rand
        elseif self.stats.fireRate == 0 then
            self.stats.fireRate = rand
        elseif self.stats.particleSpeed == 0 then
            self.stats.particleSpeed = rand
        else
            -- Randomly dish out remaining points
            local rand2 = 0 -- FIXME: immediaetly redeclared
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
    local function newBeam()
        local beam = {}
        local x1, y1 = obj.x, obj.y + obj.height / 2

        local function getBeamEnd ( startX ) 
            return math.random(startX - 1000, startX + 1000), display.contentHeight + 1000
        end

        local x2, y2 = getBeamEnd(obj.x)
        beam = display.newLine( group, x1, y1, x2, y2 )
        beam:setStrokeColor( 1, 0, 0, 0 )
        beam.strokeWidth = 4
        beam:toBack()
        physics.addBody( beam, "dynamic", { isSensor=true } )
        beam.isBullet = true
        beam.myName = "enemyBullet"
        return obj
    end
    self.beam = newBeam()
    -- Move function
    local function moveEnemy( enemy )
        local randX, randY = math.random( -100, 100 ), math.random( -100, 100 )
        obj:setLinearVelocity( randX, randY )
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
        print("Beam: standby mode")
        self.stats.beamActive = false
        self.beam.strokeWidth = 4
        self.beam:setStrokeColor( 1, 0, 0, 0 )
        self.beam = newBeam()
    end
    -- Attack function
    local function enemyFire ()
        print("Beam: fire mode")
        self.stats.beamActive = true
        self.beam.strokeWidth = 10
        self.beam:setStrokeColor( 1, 0, 0, 1 )
        timer.performWithDelay( 2000, stopFiring )
    end
    -- warn player
    local function warnPlayer ()
        print("Beam: warn player mode")
        self.beam:setStrokeColor( 1, 0, 0, 0.5 )
        timer.performWithDelay( 2000, enemyFire )
    end
    -- update beam position
    local function beamUpdate ()
        self.beam.x = obj.x
        self.beam.y = obj.y + obj.height / 2
    end
    -- Call enemy behaviours
    local newFireTime = 10000 - self.stats.fireRate * 100
    print("Laser will begin every: ", newFireTime)
    local newParticleTime = 5000 - self.stats.particleSpeed * 50
    local myClosure1 = function() return moveEnemy () end
    self.tm1 = timer.performWithDelay( math.random( 4000, 6000 ), myClosure1, 0 )
    local myClosure2 = function() return warnPlayer () end
    self.tm2 = timer.performWithDelay( newFireTime, myClosure2, 0 )
    local myClosure3 = function() return enemyUpdate ( obj ) end
    self.tm3 = timer.performWithDelay( 250, myClosure3, 0 )
    local myClosure4 = function() return beamUpdate () end
    self.tm4 = timer.performWithDelay( 25, myClosure4, 0 )
    local statTotal = 0 -- FIXME: unused
    return obj
end

return _M