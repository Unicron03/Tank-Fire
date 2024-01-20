
local Wall = {}
Wall.__index = Wall 
local ActiveWalls = {}

function Wall.new(x, y, height, width)
    instance = setmetatable({}, Wall)
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
    instance.physics.fixture:setUserData("wall")

    table.insert(ActiveWalls, instance)
end

function Wall:remove()
    for i,instance in ipairs(ActiveWalls) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveWalls, i)
        end
    end
end

function Wall.removeAll()
    for i,v in ipairs(ActiveWalls) do
        v.physics.body:destroy()
    end

    ActiveWalls = {}
end

function Wall:update(dt)
    self:syncPhysics()
    self:checkRemove()
end

function Wall:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Wall:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(0, 0)
end

function Wall:draw()
    -- self:drawHitBox()
end

function Wall:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Wall.updateAll(dt)
    for i,instance in ipairs(ActiveWalls) do
        instance:update(dt)
    end
end

function Wall.drawAll()
    for i,instance in ipairs(ActiveWalls) do
        instance:draw()
    end
end

return Wall