
local CrackStone = {}
CrackStone.__index = CrackStone 
local ActiveCrackStones = {}

function CrackStone.new(x, y)
    instance = setmetatable({}, CrackStone)
    instance.img = love.graphics.newImage("assets/tiles/object/crackStone.png")
    instance.imgCracked = love.graphics.newImage("assets/tiles/object/crackStone2.png")
    instance.imgDraw = instance.img
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scale = 1
    instance.r = 0
    instance.toBeRemoved = false
    instance.toBeRemovedDirect = false
    
    instance.x = x + instance.width * 0.5
    instance.y = y + instance.height * 0.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setUserData("crackStone")

    table.insert(ActiveCrackStones, instance)
end

function CrackStone:remove()
    for i,instance in ipairs(ActiveCrackStones) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveCrackStones, i)
        end
    end
end

function CrackStone.removeAll()
    for i,v in ipairs(ActiveCrackStones) do
        v.physics.body:destroy()
    end

    ActiveCrackStones = {}
end

function CrackStone:update(dt)
    self:syncPhysics()
    self:checkRemove()
end

function CrackStone:checkRemove()
    if self.toBeRemoved or self.toBeRemovedDirect then
        if self.imgDraw == self.imgCracked then
            self:remove()
        else
            self.imgDraw = self.imgCracked
            self.toBeRemoved = false
        end
    end
end

function CrackStone:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(0, 0)
end

function CrackStone:draw()
    love.graphics.draw(self.imgDraw, self.x, self.y, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function CrackStone:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function CrackStone.updateAll(dt)
    for i,instance in ipairs(ActiveCrackStones) do
        instance:update(dt)
    end
end

function CrackStone.drawAll()
    for i,instance in ipairs(ActiveCrackStones) do
        instance:draw()
    end
end

function CrackStone.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveCrackStones) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a:getUserData() == "explosion" or b:getUserData() == "explosion" then
                instance.toBeRemovedDirect = true
            elseif a:getUserData() == "projectileTank" or b:getUserData() == "projectileTank" then
                instance.toBeRemoved = true
            end
        end
    end
end

return CrackStone