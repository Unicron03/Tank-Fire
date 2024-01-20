

local Sound = {active = {}, source = {}}

local Tank = require("tank")

function Sound:init(id,source,soundType)
    assert(self.source[id] == nil, "Sound with that ID already exists!")
    self.source[id] = love.audio.newSource(source, soundType)
end

function Sound:loadSong()
    theme = love.audio.newSource("assets/sfx/wizards_battlefield_bpm165.ogg", "stream")
    theme:setVolume(0.1)
    gameOver = love.audio.newSource("assets/sfx/gameOver.ogg", "stream")
    gameOver:setVolume(0.2)
    menuEntrant = love.audio.newSource("assets/sfx/menuEntrant.ogg", "stream")
    menuEntrant:setVolume(0.1)
    menuSortant = love.audio.newSource("assets/sfx/menuSortant.ogg", "stream")
    menuSortant:setVolume(0.1)
    menuAttente = love.audio.newSource("assets/sfx/Menu Music.ogg", "stream")
    menuAttente:setVolume(0.2)
    home = love.audio.newSource("assets/sfx/oga_secret_devastates.mp3", "stream")
    home:setVolume(0.2)
    rlaunch = love.audio.newSource("assets/sfx/rlaunch.ogg", "stream")
    rlaunch:setVolume(0.05)
    blaunch = love.audio.newSource("assets/sfx/iceball.ogg", "stream")
    blaunch:setVolume(0.05)
    explosion = love.audio.newSource("assets/sfx/explosion.ogg", "stream")
    explosion:setVolume(0.2)
    setUpMine = love.audio.newSource("assets/sfx/Click_Electronic_13.mp3", "stream")
    setUpMine:setVolume(0.2)
    winRound = love.audio.newSource("assets/sfx/WinPizzicato.ogg", "stream")
    winRound:setVolume(0.4)
    victory = love.audio.newSource("assets/sfx/Victory.ogg", "stream")
    victory:setVolume(0.4)
end

function Sound:stopSound()
    love.audio.stop(theme)
end

function Sound:stopMenu()
    love.audio.stop(menuEntrant)
    love.audio.stop(menuSortant)
end

function Sound:update(dt)
    self:redoTheme()
end

function Sound:redoTheme()
    if not Tank.death and not Tank.winGame then
        if not theme:isPlaying() then
		    love.audio.play(theme)
        end
	else
        self:stopSound()
    end
end

function Sound:play(id, channel)
    local channel = channel or "default"
    local clone = Sound.source[id]:clone()
    clone:play()

    if Sound.active[channel] == nil then
        Sound.active[channel] = {}
    end

    table.insert(Sound.active[channel], clone)
end

return Sound