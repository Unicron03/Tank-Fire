
local Bush = {}
Bush.__index = Bush 
local ActiveBushs = {}

function Bush.new(x, y, height, width)
    instance = setmetatable({}, Bush)
    instance.width = width
    instance.height = height
    instance.x = x + instance.width * 0.5
    instance.y = y + instance.height * 0.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("bush")

    table.insert(ActiveBushs, instance)
end

function Bush.removeAll()
    for i,v in ipairs(ActiveBushs) do
        v.physics.body:destroy()
    end

    ActiveBushs = {}
end

function Bush:update(dt)
end

function Bush:draw()
    -- self:drawHitBox()
end

function Bush:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Bush.updateAll(dt)
    for i,instance in ipairs(ActiveBushs) do
        instance:update(dt)
    end
end

function Bush.drawAll()
    for i,instance in ipairs(ActiveBushs) do
        instance:draw()
    end
end

return Bush