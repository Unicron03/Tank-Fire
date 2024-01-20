

local Camera = {
    x = 0,
    y = 0,
    scale = 1,
}

function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end

function Camera:setPosition(x, y)
    self.x = x - love.graphics.getWidth() / 2 / self.scale
    self.y = y - love.graphics.getHeight() / 2 / self.scale
    local RS = self.x + love.graphics.getWidth() / self.scale
    local RY = self.y + love.graphics.getHeight() / self.scale

    if self.x < 0 then
        self.x = 0
    elseif RS > MapWidth then
        self.x = MapWidth - love.graphics.getWidth() / self.scale
    end

    if self.y < 0 then
        self.y = 0
    elseif RY > MapHeight then
        self.y = MapHeight - love.graphics.getHeight() / self.scale
    end
end

function Camera:worldToScreen(x, y)
    print(self.scale)
    local screenX = (x - self.x) * self.scale
    local screenY = (y - self.y) * self.scale
    return screenX, screenY
end

return Camera