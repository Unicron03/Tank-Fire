
local Tank = {}

function Tank:load()
    self.x = 240
    self.y = 544
    self.startX = self.x
    self.startY = self.y
    self.startDirection = "right"
    self.r = self:changeDirection(self.startDirection)
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 200
    self.maxSpeedBase = self.maxSpeed
    self.acceleration = 750
    self.friction = 4500
    self.scaleBase = 3.75
    self.tankDestroyed = 0
    self.tankDestroyedInLevel = self.tankDestroyed
    self.tankPoints = 0
    self.state = "idle"

    self.home = true
    self.begin = false
    self.death = false
    self.winGame = false
    self.deathPlaySong = false

    self.rechargeMissile = {timer = 0, rate = 1}
    self.missileLaunch = true
    self.inBush = false

    self.key = {
        top = "z",
        bottom = "s",
        right = "d",
        left = "q",
        mine = "space"
    }

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    local tankWidth, tankHeight = self.animation.width * self.scaleBase, self.animation.height * self.scaleBase
    self.physics.shape = love.physics.newRectangleShape(tankWidth, tankHeight)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setFixedRotation(true)
    self.physics.body:setGravityScale(0)
    self.physics.fixture:setUserData("tank")
end

function Tank:setSpawnProps()
    self.physics.body:setPosition(self.startX, self.startY)
    self.r = self:changeDirection(self.startDirection)
end

function Tank:loadAssets()
    self.animation = {timer = 0, rate = 0.15}

    self.animation.idle = {total = 4, current = 1, img = {}}
    for i=1,self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/tank/idle/lvl1/"..i..".png")        
    end

    self.animation.death = {total = 1, current = 1, img = {}}
    for i=1,self.animation.death.total do
        self.animation.death.img[i] = love.graphics.newImage("assets/tank/idle/lvl1/death.png")        
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Tank:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:handleInput(dt)
    self:applyFriction(dt)
    self:reactiveMissile(dt)
end

function Tank:animate(dt)
    if self.xVel ~= 0 or self.yVel ~= 0 or self.state == "death" then
        self.animation.timer = self.animation.timer + dt
        if self.animation.timer > self.animation.rate then
            self.animation.timer = 0
            self:setNewFrame()     
        end
    end 
end

function Tank:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Tank:reactiveMissile(dt)
    if not self.missileLaunch then
        self.rechargeMissile.timer = self.rechargeMissile.timer + dt
        if self.rechargeMissile.timer > self.rechargeMissile.rate then
            self.missileLaunch = true
            self.rechargeMissile.timer = 0
        end
    end
end

function Tank:changeDirection(direction)
    local rad = 0.01745329
    if direction == "up" then
        r = 0 * rad
    elseif direction == "down" then
        r = 180 * rad
    elseif direction == "left" then
        r = 270 * rad
    elseif direction == "right" then
        r = 90 * rad
    end

    return r
end

function Tank:isTopKeyPressed()
    return love.keyboard.isDown(self.key.top)
end

function Tank:isLeftKeyPressed()
    return love.keyboard.isDown(self.key.left)
end

function Tank:isBottomKeyPressed()
    return love.keyboard.isDown(self.key.bottom)
end

function Tank:isRightKeyPressed()
    return love.keyboard.isDown(self.key.right)
end

function Tank:handleInput(dt)
    if self.state ~= "death" then
        if self:isTopKeyPressed() then
            self.yVel = math.max(self.yVel - self.acceleration * dt, -self.maxSpeed)
            self.xVel = 0
            self.r = self:changeDirection("up")
        elseif self:isLeftKeyPressed() then
            self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
            self.yVel = 0
            self.r = self:changeDirection("left")
        elseif self:isBottomKeyPressed() then
            self.yVel = math.min(self.yVel + self.acceleration * dt, self.maxSpeed)
            self.xVel = 0
            self.r = self:changeDirection("down")
        elseif self:isRightKeyPressed() then
            self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
            self.yVel = 0
            self.r = self:changeDirection("right")
        end
    end
end

function Tank:applyFriction(dt)
    if not (self:isTopKeyPressed() or self:isLeftKeyPressed() or self:isBottomKeyPressed() or self:isRightKeyPressed()) then
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.max(self.xVel + self.friction * dt, 0)
        elseif self.yVel > 0 then
            self.yVel = math.max(self.yVel - self.friction * dt, 0)
        elseif self.yVel < 0 then
            self.yVel = math.max(self.yVel + self.friction * dt, 0)
        end
    end
end

function Tank:deathState()
    self.state = "death"
    self.death = true
    self.xVel, self.yVel = 0, 0
    gameOver:play()
end

function Tank:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Tank:draw()
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleBase, self.scaleBase, self.animation.width/2, self.animation.height/2)
    love.graphics.setColor(1, 1, 1)

    -- self:drawHitBox()
end

function Tank:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Tank:beginContact(a, b, collision)
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny > 0 then
            self.yVel = 0
        end
    end

    if a == self.physics.fixture or b == self.physics.fixture then
        if a:getUserData() == "projectileEnemy" or b:getUserData() == "projectileEnemy" then
            self:deathState()
        elseif a:getUserData() == "explosion" or b:getUserData() == "explosion" then
            self:deathState()
        elseif a:getUserData() == "bush" or b:getUserData() == "bush" then
            self.inBush = true
        end
    end
end

function Tank:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if a:getUserData() == "bush" or b:getUserData() == "bush" then
            self.inBush = false
        end
    end
end

return Tank