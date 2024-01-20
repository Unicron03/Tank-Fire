

local Explosion = {}
Explosion.__index = Explosion

local ActiveExplosions = {}

function Explosion.new(x, y)
    instance = setmetatable({}, Explosion)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.toBeRemoved = false
    instance.scaleBase = 2
    instance.state = "idle"

    instance:loadAssets()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width * instance.scaleBase, instance.animation.height * instance.scaleBase)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("explosion")

    table.insert(ActiveExplosions, instance)
end

function Explosion:isTableEmpty()
    -- Indique s'il existe des Explosion sur la map
    return next(ActiveExplosions) == nil
end

function Explosion:remove()
    for i,instance in ipairs(ActiveExplosions) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveExplosions, i)
        end
    end
end

function Explosion.removeAll()
    for i,v in ipairs(ActiveExplosions) do
        v.physics.body:destroy()
    end

    ActiveExplosions = {}
end

function Explosion:loadAssets()
    self.animation = {timer = 0, rate = 0.035}

    self.animation.idle = {total = 22, current = 1, img = {}}
    for i=1,self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/explosion/"..i..".png")        
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Explosion:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:checkRemove()
end

function Explosion:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Explosion:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()     
    end 
end

function Explosion:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
        if anim.current == 11 then
            self.physics.fixture:destroy()
        end
    else
        self.toBeRemoved = true
    end
    self.animation.draw = anim.img[anim.current]
end

function Explosion:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(0, 0)
end

function Explosion:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleBase, self.scaleBase, self.animation.width/2, self.animation.height/2)
    love.graphics.setColor(1, 1, 1)

    -- self:drawHitBox()
end

function Explosion:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Explosion.updateAll(dt)
    for i,instance in ipairs(ActiveExplosions) do
        instance:update(dt)
    end
end

function Explosion.drawAll()
    for i,instance in ipairs(ActiveExplosions) do
        instance:draw()
    end
end

return Explosion