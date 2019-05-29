Hud = Class{}

function Hud:init(def) 

    -- HUD phyical parameters so we can rrender it
    self.x = 0
    self.y = 0
    self.width = VIRTUAL_WIDTH
    self.height = TILE_SIZE * 1.5

    -- Collor Pallete for Hud
    self.cPattern = def.cPattern

    -- Player and levelinfo
    self.level = def.level
    self.player = self.level.map.player

    -- Blicnk
    self.TimeDisplay = true
    self.TimeLock = false
end

function Hud:drawBorder()

    love.graphics.setColor(self.cPattern[OUTER_BORDER])
    love.graphics.line(0, self.height, VIRTUAL_WIDTH, self.height)
    love.graphics.setColor(self.cPattern[INNER_BORDER])
    love.graphics.line(0, self.height - 1, VIRTUAL_WIDTH, self.height - 1)
    love.graphics.setColor(self.cPattern[OUTER_BORDER])
    love.graphics.line(0, self.height - 2, VIRTUAL_WIDTH, self.height - 2)

end

function Hud:drawInfo()

    local verticalPadding = 1
    local horizontalPadding = 2

    -- Lives Info -- 

    -- First draw icon (player's head)
    love.graphics.setColor(255, 255, 255, 255)
    local imageXoffest = TILE_SIZE/2
    love.graphics.draw(gTextures['icons'], gFrames['icons'][1], imageXoffest, math.floor(self.height/5)) 

    -- Draw box
    love.graphics.setColor(self.cPattern[BOX])
    love.graphics.rectangle("fill", imageXoffest + TILE_SIZE + 4, math.floor(self.height/4) + 1, 12, 12)
    love.graphics.setFont(gFonts['info'])

    -- Finnally, draw the number corresponding to his life
    love.graphics.setColor(self.cPattern[NUMBER])
    love.graphics.print(tostring(self.player.lives), imageXoffest + TILE_SIZE + 4 + horizontalPadding, math.floor(self.height/4) +  verticalPadding)

    -- TIME --

    -- Box to display value
    love.graphics.setColor(self.cPattern[BOX])
    love.graphics.rectangle("fill", VIRTUAL_WIDTH/8 + 3 * TILE_SIZE, math.floor(self.height/4) + 1, TILE_SIZE * 2  , 12)
    -- Abreviation:
    love.graphics.setFont(gFonts['info'])
    love.graphics.setColor(self.cPattern[INFO])
    love.graphics.print("TIME",  VIRTUAL_WIDTH/8 + 12 + horizontalPadding, math.floor(self.height/4) +  verticalPadding)

    -- Actual value
    love.graphics.setFont(gFonts['info'])
    if self.level.timer > 100 then
        love.graphics.setColor(self.cPattern[NUMBER])
    else
        love.graphics.setColor(255,0,0,255)
    end

    if self.TimeDisplay then
        love.graphics.print(tostring(self.level.timer),  VIRTUAL_WIDTH/8 + 3 * TILE_SIZE + horizontalPadding, math.floor(self.height/4) +  verticalPadding)
    end

    -- SCORE --

    -- Box to display value
    love.graphics.setColor(self.cPattern[BOX])
    love.graphics.rectangle("fill", VIRTUAL_WIDTH/2 + 2 * TILE_SIZE, math.floor(self.height/4) + 1, TILE_SIZE * 5 + TILE_SIZE/2 , 12)
    -- Abreviation:
    love.graphics.setFont(gFonts['info'])
    love.graphics.setColor(self.cPattern[INFO])
    love.graphics.print("SC",  VIRTUAL_WIDTH/2 + 12 + horizontalPadding, math.floor(self.height/4) +  verticalPadding)

    -- Actual value
    love.graphics.setFont(gFonts['info'])
    love.graphics.setColor(self.cPattern[NUMBER])
    love.graphics.print(tostring(self.level.map.score),  VIRTUAL_WIDTH/2 + 2 * TILE_SIZE + horizontalPadding, math.floor(self.height/4) +  verticalPadding)


end

function Hud:update(dt) 

    if self.level.timer > 100 and self.level.timer %100 == 0 and not self.TimeLocked then
        self.TimeLocked = true
        Timer.every(0.25, function ()
            self.TimeDisplay = not self.TimeDisplay
        end):limit(14):finish(function()
            self.TimeLocked = false
        end)
    elseif self.level.timer <= 100 and not self.TimeLocked then
        self.TimeLocked = true
        -- Blimp por 100 seconds (4 * 0.7 * 100) = 280
        Timer.every(0.25, function ()
            self.TimeDisplay = not self.TimeDisplay
        end):limit(280):finish(function()
            self.TimeLocked = false
        end)
    end

end

function Hud:render() 

    -- First, draw our hud's wrapper
    love.graphics.setColor(self.cPattern[BACKGROUND])
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    self:drawBorder()

    -- Finally, draw the boxes and information.
    self:drawInfo()
    love.graphics.setColor(255, 255, 255, 255)
end