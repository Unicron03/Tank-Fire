local DisplayAlert = {}
DisplayAlert.__index = DisplayAlert
local ActiveSimpleAlerts = {}

local Button = require("button")

function DisplayAlert.new(numTanksDestroyed, currentMap, backFunction)
    local instance = setmetatable({}, DisplayAlert)
    instance.numTanksDestroyed = numTanksDestroyed
    instance.currentMap = currentMap

    instance.alertBoxWidth = 400
    instance.alertBoxHeight = 200
    instance.alertBoxX = (love.graphics.getWidth() - instance.alertBoxWidth) / 2
    instance.alertBoxY = (love.graphics.getHeight() - instance.alertBoxHeight) / 2
    
    instance.text = "Next Level"
    instance.nextLevelButtonImg = love.graphics.newImage("assets/ui/button_up.png")
    local textWidth = love.graphics.getFont():getWidth(instance.text)
    local textHeight = love.graphics.getFont():getHeight(instance.text)
    local textX = love.graphics:getWidth() * 0.5 - (instance.nextLevelButtonImg:getWidth() * 1.4) * 0.5

    instance.nextLevelButton = Button.new(textX, instance.alertBoxY + 120, instance.nextLevelButtonImg:getWidth(), instance.nextLevelButtonImg:getHeight(),
    1.4, instance.nextLevelButtonImg, instance.text, function() backFunction() Button.removeAll() ActiveSimpleAlerts = {}
    end)

    instance.isVisible = true

    winRound:play()
    table.insert(ActiveSimpleAlerts, instance)
    return instance
end

function DisplayAlert:removeAll()
    ActiveSimpleAlerts = {}
    Button.removeAll()
end

function DisplayAlert:isTableEmpty()
    -- Indique s'il existe des Enemy sur la map
    return next(ActiveSimpleAlerts) == nil
end

function DisplayAlert:update(dt)
    if self.isVisible then
        self.nextLevelButton:update(dt)
    end

    theme:stop()
end

function DisplayAlert:draw()
    if self.isVisible then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8) -- Fond sombre semi-transparent
        love.graphics.rectangle("fill", self.alertBoxX, self.alertBoxY, self.alertBoxWidth, self.alertBoxHeight)

        love.graphics.setColor(1, 1, 1) -- Couleur du texte
        love.graphics.printf("You have destroy " .. self.numTanksDestroyed .. " tanks !", self.alertBoxX, self.alertBoxY + 20, self.alertBoxWidth, "center")

        self.nextLevelButton:draw()

        love.graphics.setColor(1, 1, 1) -- Réinitialise la couleur
    end
end

function DisplayAlert.drawAll()
    for i, instance in ipairs(ActiveSimpleAlerts) do
        instance:draw()
    end
end

function DisplayAlert.updateAll(dt)
    for i, instance in ipairs(ActiveSimpleAlerts) do
        instance:update(dt)
    end
end

return DisplayAlert