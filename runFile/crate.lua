
local Crate = {}
Crate.__index = Crate 
local ActiveCrates = {}

function Crate.new(x, y)
    instance = setmetatable({}, Crate)
    instance.img = love.graphics.newImage("assets/tiles/object/crate.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scale = 1
    instance.r = 0
    instance.toBeRemoved = false
    
    instance.x = x + instance.width * 0.5
    instance.y = y + instance.height * 0.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData("crate")

    table.insert(ActiveCrates, instance)
end

function Crate:remove()
    for i,instance in ipairs(ActiveCrates) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveCrates, i)
        end
    end
end

function Crate.removeAll()
    for i,v in ipairs(ActiveCrates) do
        v.physics.body:destroy()
    end

    ActiveCrates = {}
end

function Crate:update(dt)
    self:syncPhysics()
    self:checkRemove()
end

function Crate:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Crate:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(0, 0)
end

function Crate:draw()
    love.graphics.draw(self.img, self.x, self.y, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Crate:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Crate.updateAll(dt)
    for i,instance in ipairs(ActiveCrates) do
        instance:update(dt)
    end
end

function Crate.drawAll()
    for i,instance in ipairs(ActiveCrates) do
        instance:draw()
    end
end

function Crate.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveCrates) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a:getUserData() == "explosion" or b:getUserData() == "explosion" then
                instance.toBeRemoved = true
            elseif a:getUserData() == "projectileTank" or b:getUserData() == "projectileTank" then
                instance.toBeRemoved = true
            end
        end
    end
end

return Crate