

local Enemy = {}
Enemy.__index = Enemy

local ActiveEnemies = {}
local Tank = require("tank")
local Projectile = require("projectile")

function Enemy.new(x, y, lvl, allowMove, infiniteRange)
    instance = setmetatable({}, Enemy)
    instance.x = x
    instance.y = y
    instance.lvl = lvl
    instance.r = 0
    instance.speed = 100 + 15 * lvl -- Vitesse de déplacement
    instance.maxSpeed = 100 + 15 * lvl -- Vitesse de déplacement
    instance.attackRange = 650 + 30 * lvl -- Portée d'attaque
    instance.attackCooldown = 2.5 - 0.5 * lvl -- Délai entre les attaques en secondes
    instance.attackTimer = 2.0
    instance.isAttacking = false
    instance.toBeRemoved = false
    instance.scaleBase = 3.75
    instance.moveRangeIA = 100
    instance.xVel, instance.yVel = 0, 0
    instance.targetX, instance.targetY = 0, 0
    instance.state = "idle"
    instance.canChangeCo = true
    instance.IAmove = false
    instance.allowMove = allowMove
    instance.pointPerKill = 1 * lvl
    instance.giveKill = 1
    instance.infiniteRange = infiniteRange

    instance:loadAssets()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width * instance.scaleBase, instance.animation.height * instance.scaleBase)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("enemy")

    table.insert(ActiveEnemies, instance)
end

function Enemy.removeAll()
    for i,v in ipairs(ActiveEnemies) do
        v.physics.body:destroy()
    end

    ActiveEnemies = {}
end

function Enemy:isTableEmpty()
    -- Indique s'il existe des Enemy sur la map
    return next(ActiveEnemies) == nil
end

function Enemy:loadAssets()
    self.animation = {timer = 0, rate = 0.15}

    self.animation.idle = {total = 4, current = 1, img = {}}
    for i=1,self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/tank/idle/lvl"..self.lvl.."/"..i..".png")        
    end

    self.animation.death = {total = 1, current = 1, img = {}}
    for i=1,self.animation.death.total do
        self.animation.death.img[i] = love.graphics.newImage("assets/tank/idle/lvl"..self.lvl.."/death.png")        
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Enemy:update(dt)
    self:sysIA(dt)
    self:syncPhysics()
    self:animate(dt)
end

function Enemy:sysIA(dt)
    if self.state ~= "death" then
        local distance = self:getDistance()

        -- Attaque si le joueur est à portée et que rien ne les séparent
        if (distance <= self.attackRange or self.infiniteRange) and not self:hasSolidWallsBetweenPlayer(Tank.x, Tank.y) then
            self:launchProjectile(dt)
        else
            self.isAttacking = false
        end

        --Si le joueur est à porter mais qu'un mur les séparent
        if ((distance > self.attackRange or self.infiniteRange) or self:hasSolidWallsBetweenPlayer(Tank.x, Tank.y)) and self.allowMove then
            self:gotoAI()
            self.r = self:getRotation(self.targetX, self.targetY)
        else
            self.r = self:getRotation(Tank.x, Tank.y)
            self.xVel = 0
            self.yVel = 0
        end
    else
        Tank.tankPoints = Tank.tankPoints + self.pointPerKill
        Tank.tankDestroyed = Tank.tankDestroyed + self.giveKill
        self.pointPerKill = 0
        self.giveKill = 0
    end
end

function Enemy:hasSolidWallsBetweenPlayer(x, y)
    local x1, y1 = self.x, self.y
    local x2, y2 = x, y

    local hitSolidWall = false

    World:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, fraction)
        local userData = fixture:getUserData()

        if userData == "wall" or userData == "crate" or userData == "crackStone" or (userData == "bush" and Tank.inBush) then
            hitSolidWall = true
            -- Arrêtez le raycast en retournant -1
            return -1
        end

        -- Continuer le raycast en retournant la fraction
        return fraction
    end)

    -- Si nous avons touché un mur (hitSolidWall)
    return hitSolidWall
end

function Enemy:newCoordOnPos(x, y)
    local x1, y1 = self.x, self.y
    local x2, y2 = x, y

    local hitSolidWall = false

    World:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, fraction)
        local userData = fixture:getUserData()
        
        if userData == "wall" or userData == "crate" or userData == "crackStone" or userData == "water" then
            hitSolidWall = true
            -- Arrêtez le raycast en retournant -1
            return -1
        end

        -- Continuer le raycast en retournant la fraction
        return fraction
    end)

    -- Si nous avons touché un mur (hitSolidWall)
    return hitSolidWall
end

-- function Enemy:gotoAI()
--     if self.canChangeCo then
--         self.targetX, self.targetY = math.random(self.x - 100, self.x + 100), math.random(self.y - 100, self.y + 100)
--         self.canChangeCo = false
--         self.IAmove = true
--     end
--     self:goto(self.targetX, self.targetY)
--     if math.floor(self.x) == math.floor(self.targetX) and math.floor(self.y) == math.floor(self.targetY) then
--         self.canChangeCo = true
--         self.IAmove = false
--     end
-- end

function Enemy:gotoAI()
    if self.canChangeCo then
        self.canChangeCo = false
        self.IAmove = true

        local getPoints = false
        local newTargetX, newTargetY

        while not getPoints do
            newTargetX = math.random(self.x - self.moveRangeIA, self.x + self.moveRangeIA)
            newTargetY = math.random(self.y - self.moveRangeIA, self.y + self.moveRangeIA)
            
            -- Vérifiez si le nouveau pointPerKill est sur un mur
            if not self:newCoordOnPos(newTargetX, newTargetY) then
                getPoints = true
            end
        end

        self.targetX, self.targetY = newTargetX, newTargetY
    end

    self:goto(self.targetX, self.targetY)
    if math.floor(self.x) == math.floor(self.targetX) and math.floor(self.y) == math.floor(self.targetY) then
        self.canChangeCo = true
        self.IAmove = false
    end
end

function Enemy:goto(x, y)
    local angle = math.atan2(y - self.y, x - self.x)
    self.xVel = self.maxSpeed * math.cos(angle)
    self.yVel = self.maxSpeed * math.sin(angle)
end

function Enemy:getDistance()
    return math.sqrt((Tank.x - self.x)^2 + (Tank.y - self.y)^2)
end

function Enemy:launchProjectile(dt)
    self.isAttacking = true
    self.attackTimer = self.attackTimer + dt
    if self.attackTimer >= self.attackCooldown and Tank.state == "idle" then
        Projectile.new(self.x, self.y, Tank.x, Tank.y, self.lvl, "Enemy")
        self.attackTimer = 0
    end
end

function Enemy:getRotation(x, y)
    local xDist = x - self.x
    local yDist = y - self.y
    local rad = math.atan2(yDist, xDist) + 1.57079633

    return rad
end

function Enemy:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()     
    end 
end

function Enemy:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total and self.allowMove then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Enemy:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Enemy:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleBase, self.scaleBase, self.animation.width/2, self.animation.height/2)
    love.graphics.setColor(1, 1, 1)

    -- self:drawHitBox()
end

function Enemy:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Enemy.updateAll(dt)
    for i,instance in ipairs(ActiveEnemies) do
        instance:update(dt)
    end
end

function Enemy.drawAll()
    for i,instance in ipairs(ActiveEnemies) do
        instance:draw()
    end
end

function Enemy.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveEnemies) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a:getUserData() == "projectileTank" or b:getUserData() == "projectileTank" then
                instance.state = "death"
                instance.xVel, instance.yVel = 0, 0
            elseif a:getUserData() == "explosion" or b:getUserData() == "explosion" then
                instance.state = "death"
                instance.xVel, instance.yVel = 0, 0
            end
        end

        -- local nx, ny = collision:getNormal()
        -- if a == instance.physics.fixture then
        --     if ny < 0 then
        --         instance.yVel = 0
        --     end
        -- elseif b == instance.physics.fixture then
        --     if ny > 0 then
        --         instance.yVel = 0
        --     end
        -- end
    end
end

return Enemy