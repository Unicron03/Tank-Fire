local Map = {}
local STI = require("sti")
local Crate = require("crate")
local Wall = require("wall")
local Enemy = require("enemy")
local CrackStone = require("crackStone")
local Bush = require("bush")
local Water = require("water")
local DisplayAlert = require("displayAlert")
local Tank = require("tank")
local Button = require("button")
local Projectile = require("projectile")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0,0)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function Map:init()
    self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})
 
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16
    MapHeight = self.groundLayer.height * 16
 
    self.nbTankInLevel = 0
    self:spawnEntities()
end

function Map:clean()
   self.level:box2d_removeLayer("solid")
   Crate.removeAll()
   Wall.removeAll()
   Enemy.removeAll()
   CrackStone.removeAll()
   Bush.removeAll()
   Water.removeAll()
   Projectile.removeAll()
   Tank.tankDestroyedInLevel = Tank.tankDestroyed
end

function Map:getDimensionsMap()
    return MapWidth, MapHeight
end

function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    love:resetSpawnPlayer()
    theme:play()
end

function Map:update(dt)
    self:sysDisplayAlert()
    -- print(Tank.tankDestroyed, Tank.tankDestroyedInLevel, self.nbTankInLevel)
end

function Map:sysDisplayAlert()
    if Tank.tankDestroyed >= Tank.tankDestroyedInLevel + self.nbTankInLevel and DisplayAlert:isTableEmpty() and not Tank.death and not Tank.winGame then
        if self.currentLevel == 11 then
            Tank.winGame = true
            victory:play()
        else
            DisplayAlert.new(self.nbTankInLevel, self.currentLevel, function() self:next() end)
        end
    end
end

function Map:draw()
end

function Map:spawnEntities()
    for i, v in ipairs(self.entityLayer.objects) do
        if v.type == "crate" then
           Crate.new(v.x, v.y)
        elseif v.type == "wall" then
            Wall.new(v.x, v.y, v.height, v.width)
        elseif v.type == "enemy" then
            Enemy.new(v.x, v.y, v.properties.lvl, v.properties.allowMove, self.currentLevel>=5)
            self.nbTankInLevel = self.nbTankInLevel + 1
        elseif v.type == "tank" then
            self.tankSpawnX, self.tankSpawnY, self.tankSpawnDirection = v.x, v.y, v.properties.direction
        elseif v.type == "crackStone" then
            CrackStone.new(v.x, v.y)
        elseif v.type == "bush" then
            Bush.new(v.x, v.y, v.height, v.width)
        elseif v.type == "water" then
            Water.new(v.x, v.y, v.height, v.width)
        end
    end
end

return Map