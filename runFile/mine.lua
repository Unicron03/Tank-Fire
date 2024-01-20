
local Mine = {}
Mine.__index = Mine 
local ActiveMines = {}
local Explosion = require("explosion")

function Mine.new(x, y)
    instance = setmetatable({}, Mine)
    instance.x = x
    instance.y = y
    instance.targetX = targetX
    instance.targetY = targetY
    instance.img = love.graphics.newImage("assets/tank/weapons/mine.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scale = 2
    instance.r = 0
    instance.xVel, instance.yVel = 0, 0
    instance.toBeRemoved = false
    instance.explos = {timer = 0, rate = 15}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("mine")

    table.insert(ActiveMines, instance)
    setUpMine:stop()
    setUpMine:play()
end

function Mine:isTableFull()
    -- Indique s'il existe des Mines sur la map
    return #ActiveMines == 3
end

function Mine:remove()
    for i,instance in ipairs(ActiveMines) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveMines, i)
            explosion:stop()
            explosion:play()
            Explosion.new((self.x + self.width / 2) - (64 - self.width) / 2, (self.y + self.height / 2) - (64 - self.height) / 2)
        end
    end
end

function Mine.removeAll()
    for i,v in ipairs(ActiveMines) do
        v.physics.body:destroy()
    end

    ActiveMines = {}
end

function Mine:update(dt)
    self:syncPhysics()
    self:checkRemove()
    self:doExplos(dt)
end

function Mine:doExplos(dt)
    self.explos.timer = self.explos.timer + dt
    if self.explos.timer > self.explos.rate then
        self.toBeRemoved = true
    end
end

function Mine:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Mine:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Mine:draw()
    love.graphics.draw(self.img, self.x, self.y, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Mine:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Mine.updateAll(dt)
    for i,instance in ipairs(ActiveMines) do
        instance:update(dt)
    end
end

function Mine.drawAll()
    for i,instance in ipairs(ActiveMines) do
        instance:draw()
    end
end

function Mine.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveMines) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a:getUserData() == "projectileTank" or b:getUserData() == "projectileTank" then
                instance.toBeRemoved = true
            end
        end
    end
end

return Mine