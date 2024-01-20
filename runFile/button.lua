local Button = {}
Button.__index = Button
local ActiveSimpleButtons = {}

function Button.new(x, y, width, height, scale, img, name, callback)
    local instance = setmetatable({}, Button)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.img = img
    instance.name = name
    instance.scale = scale
    instance.callback = callback
    instance.isHovered = false

    table.insert(ActiveSimpleButtons, instance)
    return instance
end

function Button:returnNbEntities()
    return #ActiveSimpleButtons
end

function Button.removeAll()
    ActiveSimpleButtons = {}
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.isHovered = mx >= self.x and mx <= self.x + self.width * self.scale and my >= self.y and my <= self.y + self.height * self.scale
end

function Button:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale)

    local textWidth = love.graphics.getFont():getWidth(self.name)
    local textHeight = love.graphics.getFont():getHeight(self.name)
    
    local textX = self.x + (self.width * self.scale - textWidth) / 2
    local textY = self.y + (self.height * self.scale - textHeight) / 2
    
    love.graphics.print(self.name, textX, textY)
end

function Button.drawAll()
    for i, instance in ipairs(ActiveSimpleButtons) do
        instance:draw()
    end
end

function Button.updateAll(dt)
    for i, instance in ipairs(ActiveSimpleButtons) do
        instance:update(dt)
    end
end

function Button.mousepressed(x, y, button, istouch, presses)
    for _, instance in ipairs(ActiveSimpleButtons) do
        if instance.isHovered then
            instance.callback()
        end
    end
end

return Button