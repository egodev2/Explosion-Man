ShowHighScoreState = Class {__includes = BaseState}

function ShowHighScoreState:init() 

    -- Find our HighScore File and open it
    local scoreFile = love.filesystem.newFile("HighScore.lst")
    scoreFile:open("r")

    -- Intialize a matrix to hold our score lines
    self.tLines = {}
    for i = 1, 10 do
        self.tLines[i] = {}
    end

    -- Our line index, starting from 1.
    local lineCount = 1

    -- Read each line unti end of file.
    -- Each line will be formated as: "POSITION" ' ' "NAME" ' ' "SCORE"
    for line in love.filesystem.lines("HighScore.lst") do 
        -- the space char tell us if we finished to read an information.
        local space = 0

        -- Save the information we need from each line:
        local position = ""
        local name = ""
        local score = ""

        -- Read char by char.
        for k = 1, #line do
            local c = line:sub(k,k)
            if c == ' ' then
                space = space + 1
            else
                if space == 0 then
                    position = position .. c 
                elseif space == 1 then
                    name = name .. c
                elseif space == 2 then
                    score = score .. c
                end
            end
        end

        -- Finally, save the information using the line index to acess it later.
        self.tLines[lineCount] = {
            position,
            name,
            score
        }
        
        -- Increment line read by 1.
        lineCount = lineCount + 1
    end
end

function ShowHighScoreState:enter(params)
    -- This block of code is only relevant if we came from TypeHighScore State.

    -- Saves the score position the player achieved.
    self.line = params.line or nil

    -- Flag that if says if there is a new highscore.
    self.newHighScore = params.newHighScore or false

    -- Variable that controls the blinking effect on player's score line.
    -- We do the full blinking with a callback for each 0.5s passed.
    self.display = true
    if self.newHighScore then
        Timer.every(0.5, function()
            self.display = not self.display
        end)
    end
end

function ShowHighScoreState:update(dt) 

    -- Wait for player's input.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        if self.newHighScore then
            gStateMachine:change('game-over')
        else
            gStateMachine:change('title')
        end
    end

end

function ShowHighScoreState:formatedLine(i)

    -- Get appropiate values from a line to get printed in a formated style..
    local pos = self.tLines[i][1]
    local name = self.tLines[i][2]
    local score = self.tLines[i][3]


    if i == 1 then
        -- 1st - GOLD
        love.graphics.setColor(192,192,19, 255)
    elseif i == 2 then
        -- 2nd - SILVER
        love.graphics.setColor(192,192,192, 255)
    elseif i == 3 then
        -- 3rd - BRONZE
        love.graphics.setColor(205,127,50, 255)
    else
        -- REST: Orange
        love.graphics.setColor(255,165,0, 255)
    end
    
    love.graphics.print(pos .. "     " .. name .. "  .............................  " .. score, OFFSET_X, 15 + i * 15 )
end

function ShowHighScoreState:render() 

    -- Brick Background
    love.graphics.draw(gTextures['show-score'], -32, 0)

    -- Set color to Orange.
    love.graphics.setFont(gFonts['info'])
    love.graphics.setColor(255,165,0, 255)

    -- Information Line
    love.graphics.print("POS" .. "  " .. "NAME" .. "  .............................  "   .. "SCORE", OFFSET_X, 15)

    -- Print normal if there is no new high score.
    -- Otherwuise, player's score link will blink.
    if not self.newHighScore then
        for i = 1, #self.tLines do
            self:formatedLine(i)
        end
    else
        for i = 1, #self.tLines do
            if i ~= self.line then
                self:formatedLine(i)
            else -- BLinking of player's score line happens here
                if self.display then
                    self:formatedLine(i)
                end 
            end
        end
    end

    -- Set color to green.
    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(0, 255, 0, 255)

    -- Appropriate foot messages for different states.
    if self.newHighScore then
        love.graphics.print("PRESS START TO CONTINUE", OFFSET_X + TILE_SIZE/2, VIRTUAL_HEIGHT - 32)
    else
        love.graphics.print("PRESS START TO GO BACK", OFFSET_X + TILE_SIZE/2, VIRTUAL_HEIGHT - 32)
    end
end