

local Projectile = {}
Projectile.__index = Projectile 
local ActiveProjectiles = {}

function Projectile.new(x, y, targetX, targetY, lvl, from)
    instance = setmetatable({}, Projectile)
    instance.x = x
    instance.y = y
    instance.targetX = targetX
    instance.targetY = targetY
    instance.speed = 300 + 50 * lvl
    instance.from = from
    instance.img = instance:getImg(lvl)
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scale = instance:getScale(lvl)
    instance.xVel, instance.yVel = instance:getVelocity()
    instance.offsetR = instance:getOffsetR(lvl)
    instance.r = instance:getRotation(lvl)
    instance.toBeRemoved = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape((instance.width * instance.scale * 0.25), instance.height * instance.scale * 0.5)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("projectile"..instance.from)

    table.insert(ActiveProjectiles, instance)
    if lvl == 3 then
        rlaunch:stop()
        rlaunch:play()
    else
        blaunch:stop()
        blaunch:play()
    end
end

function Projectile:isTableEmpty()
    -- Indique s'il existe des Projectiles sur la map
    return next(ActiveProjectiles) == nil
end

function Projectile:getOffsetR(lvl)
    if lvl == 1 or lvl == 2 then
        offsetR = 1.57079633
    else
        offsetR = 0.78539816
    end

    return offsetR
end

function Projectile:getScale(lvl)
    if lvl == 1 or lvl == 2 then
        scale = 1
    else
        scale = 2.75
    end

    return scale
end

function Projectile:getImg(lvl)
    if lvl == 1 or lvl == 2 then
        img = love.graphics.newImage("assets/tank/weapons/bullet.png")
    else
        img = love.graphics.newImage("assets/tank/weapons/missile.png")
    end

    return img
end

function Projectile:getVelocity()
    local xDist = self.targetX - self.x
    local yDist = self.targetY - self.y
    local distance = math.sqrt(xDist * xDist + yDist * yDist)
    
    -- Calcul des vitesses x et y pour atteindre la cible
    local xVel = (xDist / distance) * self.speed
    local yVel = (yDist / distance) * self.speed
    
    return xVel, yVel
end

function Projectile:getRotation()
    local xDist = self.targetX - self.x
    local yDist = self.targetY - self.y
    local rad = math.atan2(yDist, xDist) + self.offsetR
    return rad
end

function Projectile:remove()
    for i,instance in ipairs(ActiveProjectiles) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveProjectiles, i)
        end
    end
end

function Projectile.removeAll()
    for i,v in ipairs(ActiveProjectiles) do
        v.physics.body:destroy()
    end

    ActiveProjectiles = {}
end

function Projectile:update(dt)
    self:syncPhysics()
    self:checkRemove()
end

function Projectile:exitMap()
    if not (self.x > 0 and self.x < love.graphics.getWidth()) then
        return true
    elseif not (self.y > 0 and self.y < love.graphics.getHeight()) then
        return true
    end
end

function Projectile:checkRemove()
    if self.toBeRemoved or self:exitMap() then
        self:remove()
    end
end

function Projectile:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Projectile:draw()
    love.graphics.draw(self.img, self.x, self.y, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Projectile:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Projectile.updateAll(dt)
    for i,instance in ipairs(ActiveProjectiles) do
        instance:update(dt)
    end
end

function Projectile.drawAll()
    for i,instance in ipairs(ActiveProjectiles) do
        instance:draw()
    end
end

function Projectile.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveProjectiles) do
        --Collision avec entité
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if (a:getUserData() == "mine" or b:getUserData() == "mine") and (instance.from == "Tank") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "enemy" or b:getUserData() == "enemy") and (instance.from == "Tank") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "crate" or b:getUserData() == "crate") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "crackStone" or b:getUserData() == "crackStone") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "projectileEnemy" or b:getUserData() == "projectileEnemy") and (instance.from == "Tank") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "projectileTank" or b:getUserData() == "projectileTank") and (instance.from == "Enemy") then
                instance.toBeRemoved = true
            elseif (a:getUserData() == "wall" or b:getUserData() == "wall") then
                instance.toBeRemoved = true
            end            
        end

        --Collision avec solide
        -- local nx, ny = collision:getNormal()
        -- if a == instance.physics.fixture then
        --     if ny < 0 and not ((a:getUserData() == "enemy" or b:getUserData() == "enemy") or (a:getUserData() == "tank" or b:getUserData() == "tank")) then
        --         instance.toBeRemoved = true
        --     end
        -- elseif b == instance.physics.fixture then
        --     if ny > 0 and not ((a:getUserData() == "tank" or b:getUserData() == "tank") or (a:getUserData() == "enemy" or b:getUserData() == "enemy")) then
        --         instance.toBeRemoved = true
        --     end
        -- end
    end
end

return Projectile