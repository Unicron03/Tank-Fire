local GUI = {}

local Tank = require("tank")
local Button = require("button")
local DisplayAlert = require("displayAlert")

function GUI:load()
    self.tank = {}
    self.tank.img = love.graphics.newImage("assets/ui/tank.png")
    self.tank.width = self.tank.img:getWidth()
    self.tank.height = self.tank.img:getHeight()
    self.tank.scale = 4.0
    self.tank.x = love.graphics.getWidth() - 170
    self.tank.y = 50

    self.war = {}
    self.war.img = love.graphics.newImage("assets/background/War3.png")
    self.war.width = self.war.img:getWidth()
    self.war.height = self.war.img:getHeight()
    self.war.scale = math.max(love.graphics:getWidth() / self.war.width, love.graphics:getHeight() / self.war.height)
    self.war.x = love.graphics:getWidth() * 0.5 - (self.war.width * self.war.scale) * 0.5
    self.war.y = 0

    self.homePage = {}
    self.homePage.img = love.graphics.newImage("assets/background/postapocalypse2Title.png")
    self.homePage.width = self.homePage.img:getWidth()
    self.homePage.height = self.homePage.img:getHeight()
    self.homePage.scale = math.max(love.graphics:getWidth() / self.homePage.width, love.graphics:getHeight() / self.homePage.height)
    self.homePage.x = love.graphics:getWidth() * 0.5 - (self.homePage.width * self.homePage.scale) * 0.5
    self.homePage.y = 0

    self.button = {}
    self.button.img = love.graphics.newImage("assets/ui/button_up.png")
    self.button.width = self.button.img:getWidth()
    self.button.height = self.button.img:getHeight()
    self.button.scale = 1.4
    self.button.x1 = love.graphics:getWidth() * 0.5 - (self.button.width * self.button.scale) * 1.5
    self.button.x2 = love.graphics:getWidth() * 0.5 - (self.button.width * self.button.scale) * 0.5
    self.button.x3 = love.graphics:getWidth() * 0.5 + (self.button.width * self.button.scale) * 0.5
    self.button.y = 0
    self.button.creditsDisplay = false

    self.begin = {
        opacity = 0,
        opacityFrame = 0.3
    }
    self.opacityFade = 0
    self.beginRectangleHeight = 0.4

    self.buttonHome = nil
    self.buttonHomeScale = 1.4
    self.buttonMaxScale = 2
    self.buttonMinScale = 1.4
    self.buttonX = self.button.x2
    self.buttonY = love.graphics:getHeight() * 0.6
    self.scaleChangeSpeed = 0.6
    self.isScalingUp = true
    self.buttonWebSite = nil

    self.text = ""
    self.words = {}
    self.currentWordIndex = 1
    self.currentWordTimer = 0
    self.wordDelay = 0.1  -- Délai entre chaque mot (en secondes)

    self.font = love.graphics.newFont("assets/bit.ttf", 36)
    self.icon = love.graphics.newImage("assets/icon.jpeg")
    self.iconScale = 0.016
    self.gameVersion = "Version : 1.0.0"

    self.textAff = "In a world in chaos, war is raging. You are the commander of a powerful tank, the last ray of hope in a country devastated by conflict. Your mission is clear : destroy the enemy and restore peace. The roar of guns and tank engines echoes around you. Explosions erupt, darkening the sky. Your tank is ready, the steel cold in your hands. It's time to plunge into battle, defend your nation and face the enemy with courage."
    self:displayTextWithAnimation(self.textAff, self.font, self:getRectOfTextBegin())
end

function GUI:update(dt)
    self:beginning(dt)
    self:agrandissementButton(dt)
end

function GUI:agrandissementButton(dt)
    if Tank.home then
        if self.isScalingUp then
            self.buttonHomeScale = self.buttonHomeScale + self.scaleChangeSpeed * dt
            self.buttonX = self.buttonX - self.scaleChangeSpeed * 0.3
            -- self.buttonY = self.buttonY - self.scaleChangeSpeed + 10 * dt
        else
            self.buttonHomeScale = self.buttonHomeScale - self.scaleChangeSpeed * dt
            self.buttonX = self.buttonX + self.scaleChangeSpeed * 0.3
            -- self.buttonY = self.buttonY + self.scaleChangeSpeed + 10 * dt
        end

            -- Vérifiez si la valeur a atteint le max et inversez l'état si nécessaire
        if self.buttonHomeScale >= self.buttonMaxScale then
            self.isScalingUp = false
        elseif self.buttonHomeScale <= self.buttonMinScale then
            self.isScalingUp = true
        end

        if self.buttonHome then
            self.buttonHome.scale = self.buttonHomeScale
            self.buttonHome.x = self.buttonX
            self.buttonHome.y = self.buttonY
            -- print(self.buttonHome.y, Button:returnNbEntities())
        end
    end
end

function GUI:getRectOfTextBegin()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.46 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2 + 40

    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    return textRect
end

function GUI:beginning(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.47 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth,
        height = rectHeight
    }

    if Tank.begin then
        self.begin.opacity = math.min(self.begin.opacity + self.begin.opacityFrame * dt, 1)

        if self.begin.opacity >= 1 then
            if self.currentWordIndex <= #self.words then
                self.currentWordTimer = self.currentWordTimer + dt
                if self.currentWordTimer >= self.wordDelay then
                    self.currentWordTimer = 0
                    self.text = self.text .. self.words[self.currentWordIndex] .. " "
                    self.currentWordIndex = self.currentWordIndex + 1
                end
            else
                offsetY = rectY + rectHeight - self.button.height * 2
                Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, 
                self.button.img, "Play", function() menuEntrant:play() Tank.begin = false Button.removeAll() end)
            end
        end 
        home:play()
    else
        home:stop()
    end
end

function GUI:draw()
    if Tank.home then
        self:displayHomePage()
    elseif Tank.begin then
        self:displayBeginning()
    else
        self:displayTank()
        self:displayEvo()
        self:displayRedFadeEffect()
    end
end

-- Fonction pour afficher un effet de fondu rougeâtre sur les bords de l'écran
function GUI:displayRedFadeEffect()
    if not Tank.death then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Largeur du fondu sur les bords (par exemple, 20 pixels)
        local fadeWidth = 20

        -- Couleur du fondu rougeâtre (rouge avec une faible composante alpha)
        local redFadeColor = {1, 0, 0, self.opacityFade}  -- Rouge avec une transparence de 50%

        -- Dessinez des rectangles semi-transparents sur les bords de l'écran
        -- Haut
        love.graphics.setColor(unpack(redFadeColor))
        love.graphics.rectangle("fill", 0, 0, screenWidth, fadeWidth)

        -- Bas
        love.graphics.rectangle("fill", 0, screenHeight - fadeWidth, screenWidth, fadeWidth)

        -- Gauche
        love.graphics.rectangle("fill", 0, fadeWidth, fadeWidth, screenHeight - 2 * fadeWidth)

        -- Droite
        love.graphics.rectangle("fill", screenWidth - fadeWidth, fadeWidth, fadeWidth, screenHeight - 2 * fadeWidth)

        -- Réinitialisez la couleur
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function GUI:displayHomePage()
    menuAttente:play()
    love.graphics.draw(self.homePage.img, self.homePage.x, self.homePage.y, 0, self.homePage.scale, self.homePage.scale)

    love.graphics.setFont(self.font)
    if Button:returnNbEntities() < 1 then
        self.buttonHome = Button.new(self.button.x2, self.button.y, self.button.img:getWidth(), self.button.img:getHeight(), self.buttonHomeScale, self.button.img, "Enter", function() menuAttente:stop() menuEntrant:play() Tank.home = false Tank.begin = true Button.removeAll() end)
    end
end

function GUI:displayTextWithAnimation(inputText, font, rect)
    self.text = ""
    self.words = {}  -- Réinitialisez les mots
    self.currentWordIndex = 1
    self.currentWordTimer = 0
    self.wordDelay = 0.1

    for word in inputText:gmatch("%S+") do
        table.insert(self.words, word)
    end

    self.displayTextRect = rect  -- Enregistrez le rectangle de destination
end

function GUI:displayBeginning()
    love.graphics.draw(self.war.img, self.war.x, self.war.y, 0, self.war.scale, self.war.scale)

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.5 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * self.beginRectangleHeight -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, self.begin.opacity - 0.2) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0, self.begin.opacity)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    if self.displayTextRect then
        local formattedText = self:wrapText(self.text, self.font, self.displayTextRect)

        love.graphics.setFont(self.font)

        -- Dessinez chaque ligne de texte dans le rectangle spécifié
        love.graphics.setColor(0, 0, 0, 0.65)
        for i, line in ipairs(formattedText) do
            local textWidth = self.font:getWidth(line)
            local x = self.displayTextRect.x + (self.displayTextRect.width - textWidth) / 2
            local y = self.displayTextRect.y + (i - 1) * self.font:getHeight()
            love.graphics.print(line, x + 2, y + 2)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    local x = 10
    local y = love.graphics.getHeight() - self.font:getHeight() - 10

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Skip : [Space]", x, y)
end

function GUI:displayPause(text)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.5 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * 0.4 -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.8) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    -- Utilisez la police actuelle
    local font = love.graphics.newFont("assets/bit.ttf", 48)
    love.graphics.setFont(font)

    -- Obtenez la rectangle dans lequel le texte doit s'inscrire
    local textRect = {
        x = rectX,
        y = rectY,
        width = rectWidth * 0.9,
        height = rectHeight
    }

    -- Divisez le texte en lignes en fonction de sa largeur et du rectangle
    local formattedText = self:wrapText(text, font, textRect)

    -- Calculez la hauteur totale du texte rendu
    local textHeight = #formattedText * font:getHeight()

    -- Calculez les coordonnées y pour centrer le texte verticalement
    local y = rectY + (rectHeight - textHeight) * 0.2

    -- Couleur du texte (noir)
    love.graphics.setColor(0, 0, 0, 0.65)

    -- Dessinez chaque ligne de texte
    for i, line in ipairs(formattedText) do
    -- Obtenez la largeur de cette ligne
    local textWidth = font:getWidth(line)

    -- Calculez les coordonnées x pour centrer la ligne horizontalement
    local x = rectX + (rectWidth - textWidth) / 2

    -- Dessinez la ligne de texte
    love.graphics.print(line, x + 2, y + 2)

    -- Passez à la ligne suivante
    y = y + font:getHeight()
    end

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1, 1)

    --Affichage des boutons
    offsetX = (rectWidth - (3 * self.button.width * self.button.scale)) * 0.25
    offsetY = rectY + rectHeight - self.button.height * 2.5
    
    Button.new(self.button.x1 - offsetX, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Credits", function() menuEntrant:play() self.button.creditsDisplay = true self.button.pauseMenu = false Button.removeAll() end)
    if self.buttonWebSite == nil then
        self.buttonWebSite = Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Website", function() menuEntrant:play() love.system.openURL("https://unicron03.github.io/") end)
    end
    Button.new(self.button.x3 + offsetX, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Exit", function() menuSortant:play() love.event.quit() end)
    if not Tank.death and not Tank.winGame then
        Button.new(self.button.x2, self.button.y + offsetY * 0.85, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Back", function() menuSortant:play() menuAttente:pause() self.button.pauseMenu = false Button.removeAll() self.buttonWebSite = nil end)
    end

    if not Tank.death and not Tank.winGame then
        love.graphics.draw(self.icon, rectX + 10, rectY + 10, 0, 0.15, 0.15)
        love.graphics.print(self.gameVersion, rectX + rectWidth - font:getWidth(self.gameVersion) - 10, rectY + 10)
    end
end

function GUI:displayEvo()
    if Tank.death and not self.button.creditsDisplay then
        if not DisplayAlert:isTableEmpty() then DisplayAlert:removeAll() end
        love.graphics.draw(self.war.img, self.war.x, self.war.y, 0, self.war.scale, self.war.scale)

        -- Texte à afficher
        local text = nil
        local text1 = "You are dead ! Your body lies on the ground... BUT YOU HAD TIME TO SMOKE "..Tank.tankDestroyed.." ENEMY ! Good job soldier, that's really impressive ! The nation salutes your high-quality left click."
        local text2 = "You are dead ! Your body lies on the ground... BUT YOU HAD TIME TO SMOKE "..Tank.tankDestroyed.." ENEMY ! Not bad at all ! You did better than Morales, who wanted to travel and ended up scattered... Have you got it, mate ?!"
        local text3 = "You are dead ! Your body lies on the ground... BUT YOU HAD TIME TO SMOKE "..Tank.tankDestroyed.." ENEMY ! Ugh... Still better than nothing, may your soul rest in peace... 'Always' (It's below the developer's score, by the way...)"
        local text4 = "You are dead ! Your body lies on the ground... BUT YOU HAD TIME TO SMOKE "..Tank.tankDestroyed.." ENEMY ! Have you felt pity for your enemies?! ...You're right, war solves nothing. Freedom is the right of all sentient beings..."
        local text42 = "...Bro. Is your name Douglas or...? You're probably a smart guy... If you see this message, please contact me anywhere by simply send 'My favourite game is Zelda' (yes I love Zelda). Check my website for that."

        if Tank.tankDestroyed == 42 then
            text = text42
        elseif Tank.tankDestroyed == 0 then
            text = text4
        elseif Tank.tankDestroyed > 0 and Tank.tankDestroyed < 10 then
            text = text3
        elseif Tank.tankDestroyed >= 10 and Tank.tankDestroyed < 30 then
            text = text2
        else
            text = text1
        end
        
        self:displayPause(text)
    elseif Tank.winGame and not self.button.creditsDisplay then
        love.graphics.draw(self.war.img, self.war.x, self.war.y, 0, self.war.scale, self.war.scale)

        local text = "Well done soldier! You've succeeded in your mission and single-handedly defeated "..Tank.tankDestroyed.." enemies! The nation salutes your dedication and efficiency. Go home to your family and enjoy life... You've earned it."
        self:displayPause(text)
    elseif (Tank.death or Tank.winGame) and self.button.creditsDisplay then
        love.graphics.draw(self.war.img, self.war.x, self.war.y, 0, self.war.scale, self.war.scale)
        self:displayCredits()
    elseif not Tank.home and not Tank.death and not Tank.winGame and not Tank.begin and not self.button.creditsDisplay and self.button.pauseMenu then
        self:displayPause("Menu (Pause)")
    elseif not Tank.home and not Tank.death and not Tank.winGame and not Tank.begin and self.button.creditsDisplay and not self.button.pauseMenu then
        self:displayCredits()
    end
end

function GUI:displayCredits()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local rectWidth = love.graphics:getWidth() * 0.75 -- Largeur du rectangle
    local rectHeight = love.graphics:getHeight() * 0.70 -- Hauteur du rectangle

    -- Calcul des coordonnées pour centrer le rectangle
    local rectX = (screenWidth - rectWidth) / 2
    local rectY = (screenHeight - rectHeight) / 2

    -- Couleur du rectangle (gris)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.8) -- Couleur grise avec une transparence

    -- Dessin du rectangle rempli
    love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)

    -- Couleur des contours (noirs)
    love.graphics.setColor(0, 0, 0)

    -- Dessin des contours du rectangle
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1)

    -- Texte à afficher
    local text = "Assets UI : Blood _ Copyright 2011 by shimobayashi <http://opengameart.org/content/teqq-princess-image-materials> Color edit to look like explosion Copyright 2012 by qubodup <http://opengameart.org/users/qubodup> License: CCBY3 or later <http://creativecommons.org/licenses/by/3.0/ Assets SFX : AIRYLUVS SONORES par ISAo https://airyluvs.com/; Oiboo; Some of the sounds in this project were created by ViRiX Dreamcore (David McKee) soundcloud.com/virix; Little Robot Sound Factory : www.littlerobotsoundfactory.com>; Little Robot Sound Factory : www.littlerobotsoundfactory.com. Thank you to them for creating free assets for everyone. It's thanks to their contribution that this game has a soul and was able to be created."

    -- Utilisez la police actuelle
    local font = love.graphics.newFont("assets/bit.ttf", 48)
    love.graphics.setFont(font)

    -- Obtenez la rectangle dans lequel le texte doit s'inscrire
    local textRect2 = {
        x = rectX,
        y = rectY,
        width = rectWidth * 0.9,
        height = rectHeight
    }

    -- Divisez le texte en lignes en fonction de sa largeur et du rectangle
    local formattedText = self:wrapText(text, font, textRect2)

    -- Calculez la hauteur totale du texte rendu
    local textHeight = #formattedText * font:getHeight()

    -- Calculez les coordonnées y pour centrer le texte verticalement
    local y = rectY + (rectHeight - textHeight) * 0.2

    -- Couleur du texte (noir)
    love.graphics.setColor(0, 0, 0, 0.65)

    -- Dessinez chaque ligne de texte
    for i, line in ipairs(formattedText) do
    -- Obtenez la largeur de cette ligne
    local textWidth = font:getWidth(line)

    -- Calculez les coordonnées x pour centrer la ligne horizontalement
    local x = rectX + (rectWidth - textWidth) / 2

    -- Dessinez la ligne de texte
    love.graphics.print(line, x + 2, y + 2)

    -- Passez à la ligne suivante
    y = y + font:getHeight()
    end

    -- Réinitialisation de la couleur (blanc)
    love.graphics.setColor(1, 1, 1, 1)

    --Affichage des boutons
    offsetY = rectY + rectHeight - self.button.height * 2.5
    
    Button.new(self.button.x2, self.button.y + offsetY, self.button.img:getWidth(), self.button.img:getHeight(), self.button.scale, self.button.img, "Back", function() menuSortant:play() self.button.creditsDisplay = false self.button.pauseMenu = true Button.removeAll() self.buttonWebSite = nil end)
end

-- Fonction pour diviser le texte en lignes en fonction de la largeur du rectangle
function GUI:wrapText(text, font, rect)
    local lines = {}
    local words = {}

    for word in text:gmatch("%S+") do
       table.insert(words, word)
    end
 
    local line = ""
 
    for i, word in ipairs(words) do
       local testLine = line .. word
       local testLineWidth = font:getWidth(testLine)
 
       if testLineWidth <= rect.width then
          line = testLine .. " "  -- Ajoutez un espace après chaque mot
       else
          table.insert(lines, line)
          line = word .. " "
       end
    end
 
    table.insert(lines, line)
 
    return lines
end
 

function GUI:displayTank()
    if not Tank.death then
        --Affichage Image
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.draw(self.tank.img, self.tank.x + 2, self.tank.y + 2, 0, self.tank.scale, self.tank.scale)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.tank.img, self.tank.x, self.tank.y, 0, self.tank.scale, self.tank.scale)

        --Affichage Text
        local font = love.graphics.newFont("assets/bit.ttf", 48)
        love.graphics.setFont(font)
        local x =  self.tank.x + self.tank.width * self.tank.scale
        local y = self.tank.y + self.tank.height / 2 * self.tank.scale - self.font:getHeight() / 2
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.print(" : "..Tank.tankDestroyed, x + 2, y + 2)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(" : "..Tank.tankDestroyed, x, y)
    end
end

return GUI