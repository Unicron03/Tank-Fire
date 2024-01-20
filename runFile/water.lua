
local Water = {}
Water.__index = Water 
local ActiveWaters = {}

function Water.new(x, y, height, width)
    instance = setmetatable({}, Water)
    instance.scale = 1
    instance.r = 0
    instance.toBeRemoved = false
    
    instance.height = height
    instance.width = width
    instance.x = x + instance.width * 0.5
    instance.y = y + instance.height * 0.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData("water")

    table.insert(ActiveWaters, instance)
end

function Water:remove()
    for i,instance in ipairs(ActiveWaters) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveWaters, i)
        end
    end
end

function Water.removeAll()
    for i,v in ipairs(ActiveWaters) do
        v.physics.body:destroy()
    end

    ActiveWaters = {}
end

function Water:update(dt)
    self:syncPhysics()
    self:checkRemove()
end

function Water:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Water:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(0, 0)
end

function Water:draw()
    -- self:drawHitBox()
end

function Water:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Water.updateAll(dt)
    for i,instance in ipairs(ActiveWaters) do
        instance:update(dt)
    end
end

function Water.drawAll()
    for i,instance in ipairs(ActiveWaters) do
        instance:draw()
    end
end

return Water