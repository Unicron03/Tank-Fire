love.graphics.setDefaultFilter("nearest","nearest")
local Map = require("map")
local Tank = require("tank")
local Camera = require("camera")
local Sound = require("sound")
local Button = require("button")
local Projectile = require("projectile")
local Mine = require("mine")
local GUI = require("gui")
local Enemy = require("enemy")
local Explosion = require("explosion")
local Crate = require("crate")
local Wall = require("wall")
local CrackStone = require("crackStone")
local Bush = require("bush")
local Water = require("water")
local DisplayAlert = require("displayAlert")

function love.load()
    local iconImageData = love.image.newImageData("assets/icon.jpeg")
    love.window.setIcon(iconImageData)

    math.randomseed(os.time())
    
    Map:load()
    Tank:load()
    Sound:loadSong()
    GUI:load()
    Tank:setSpawnProps()
    Camera:setPosition(Tank.x, Tank.y)
end

function love.update(dt)
    if not Tank.begin and not Tank.home and not GUI.button.pauseMenu and not GUI.button.creditsDisplay then
        World:update(dt)
        Tank:update(dt)
        Projectile.updateAll(dt)
        Mine.updateAll(dt)
        Enemy.updateAll(dt)
        Explosion.updateAll(dt)
        Crate.updateAll(dt)
        Wall.updateAll(dt)
        CrackStone.updateAll(dt)
        Bush.updateAll(dt)
        Water.updateAll(dt)
        Sound:update(dt)
        Map:update(dt)
    end
    Button.updateAll(dt)
    GUI:update(dt)
    DisplayAlert.updateAll(dt)
end

function love.draw()
    if not Tank.begin and not Tank.home then
        -- _G.map:draw()
        Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
        Camera:apply()
        Tank:draw()
        Projectile.drawAll()
        Mine.drawAll()
        Enemy.drawAll()
        Explosion.drawAll()
        Crate.drawAll()
        Wall.drawAll()
        CrackStone.drawAll()
        Bush.drawAll()
        Water.drawAll()
        Camera:clear()
    end
    
    GUI:draw()
    DisplayAlert.drawAll()
    Button.drawAll()
end

function beginContact(a, b, collision)
    Tank:beginContact(a, b, collision)
    if Mine.beginContact(a, b, collision) then return end
    if Projectile.beginContact(a, b, collision) then return end
    if Enemy.beginContact(a, b, collision) then return end
    if Crate.beginContact(a, b, collision) then return end
    if CrackStone.beginContact(a, b, collision) then return end
end

function endContact(a, b, collision)
    Tank:endContact(a, b, collision)
end

function love.mousepressed(x, y, button, istouch, presses)
    Button:mousepressed(x, y, button)
    if not Tank.begin and not Tank.death and not Tank.home and not GUI.button.creditsDisplay and not GUI.button.pauseMenu and not Tank.winGame then
        if button == 1 and Tank.missileLaunch then
            Projectile.new(Tank.x, Tank.y, x, y, 1, "Tank")
            Tank.missileLaunch = false
        end
    else
        Tank.missileLaunch = false
        Tank.rechargeMissile.timer = 0
    end
end

function love.keypressed(key)
    if key == "space" and Tank.begin then
        GUI.wordDelay = 0.01
        GUI.begin.opacityFrame = 0.8
    end

    if key == "escape" and not Tank.begin and not Tank.death and not Tank.home and not Tank.winGame and DisplayAlert:isTableEmpty() then
        if not GUI.button.pauseMenu and not GUI.button.creditsDisplay then
            theme:pause()
            menuAttente:play()
            menuEntrant:play()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = true
        elseif GUI.button.pauseMenu then
            menuSortant:play()
            menuAttente:pause()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = false
            Button.removeAll()
        elseif GUI.button.creditsDisplay then
            menuSortant:play()
            GUI.button.creditsDisplay = false
            Button.removeAll()
            GUI.buttonWebSite = nil
            GUI.button.pauseMenu = true
        end
    end

    if key == Tank.key.mine and Tank.state ~= "death" and not Tank.begin and not Tank.death and not Tank.home and not Tank.winGame and not GUI.button.creditsDisplay and not GUI.button.pauseMenu then
        if not Mine:isTableFull() then
            Mine.new(Tank.x, Tank.y)
        end
    end
end

function love:resetSpawnPlayer()
    Tank.startX, Tank.startY, Tank.startDirection = Map.tankSpawnX, Map.tankSpawnY, Map.tankSpawnDirection
    Tank:setSpawnProps()
end