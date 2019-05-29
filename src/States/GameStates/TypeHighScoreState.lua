TypeHighScoreState = Class{__includes = BaseState}

function TypeHighScoreState:init(def)
    -- Which name char is selected.
    self.currentSpaceSelection = 1

    -- Flag to know that player finished typing
    self.registrationComplete = false

    -- Represents the three letter inputs.
    self.nameSelection = {1, 1, 1}
end

function TypeHighScoreState:enter(params) 
    -- Save line position and player's high score.
    self.line = params.line
    self.score = params.score
end

function TypeHighScoreState:exit()

end

function TypeHighScoreState:Register()

    -- Open our HighScore list
    local scoreFile = love.filesystem.newFile("HighScore.lst")
    scoreFile:open("r")

    -- Since we are switching lines, we will need to store which line's text to save (lineToSave)
    -- and which to recover (lineToRecover) to maintain the high score file consistent.

    -- Important when switching important positions such as from 2nd to 3rd.
    local lineCount = 1
    
    -- Text to be saved in file.
    local text = ""

    -- Line that needs to be recovered (manipulated).
    local lineToRecover = " "

    -- Line to be saved (store), takes precedence in comparation to recovery.
    local lineToSave= " "

    for line in love.filesystem.lines("HighScore.lst") do 
        -- Easiest case: just copy
        if lineCount < self.line then
            text = text .. line .. '\n'
        -- Reached the line to be swaped, needs to be recovered later.
        elseif lineCount == self.line then
            -- Save the actual line to be recovered
            lineToRecover = line

            -- Set player's name input
            local name = VALID_CHAR[self.nameSelection[1]] .. VALID_CHAR[self.nameSelection[2]] .. VALID_CHAR[self.nameSelection[3]]

            -- store it's formated text to display.
            text = text .. self:formatedScoreLine(lineCount, name, self.score)     
        -- Hardest case: Save actual line, 
        else
            -- Save actua line.
            lineToSave = line

            -- Remove the position from our line to recover, that needs to be redone.
            lineToRecover = string.sub(lineToRecover, 4, string.len(lineToRecover))

            -- Determine the new position
            local position = "ERR"
            if lineCount == 2 then
                position = "2nd"
            elseif lineCount == 3 then
                position = "3rd"
            else    
                position = tostring(lineCount) .. "th"
            end

            -- Glue all together again.
            text = text .. position .. lineToRecover .. '\n'

            -- The saved line brecomes the new to be recovered.
            lineToRecover = lineToSave
        end
        -- Increment our position count.
        lineCount = lineCount + 1
    end
    scoreFile:close()

    -- Since we finished reading the old file, now we can overwrite it.
    scoreFile:open("w")
    scoreFile:write(text)
    scoreFile:close()
end

function TypeHighScoreState:formatedScoreLine(position, name, score)

    local str = ""

    -- Position
    if(position == 1) then
        str = str .. tostring(position) .. "st" .. " "
    elseif (position == 2) then
        str = str .. tostring(position) .. "nd" .. " "
    elseif (position == 3) then
        str = str .. tostring(position) .. "rd" .. " "
    else
        str = str .. tostring(position) .. "th" .. " "
    end

    -- Name
    str = str .. name .. " "

    -- Score
    str = str .. tostring(score) .. '\n'

    -- Return final string
    return str
end

function TypeHighScoreState:update(dt)

    -- UP and DOWN change character. We have SCORE_VALIDCHAR_FIRST and SCORE_VALIDCHAR_LAST as our min,max limits.
    -- Notice that we are only change indexes, the translation to a char happens on render function.
    -- LEFT and RIGHT change cursor's position to another letter of the three letter name

    -- Selection handle
    if love.keyboard.wasPressed('up') then
        gSounds['menuSelection']:play()
        if(self.nameSelection[self.currentSpaceSelection] == SCORE_VALIDCHAR_FIRST) then
            self.nameSelection[self.currentSpaceSelection] = SCORE_VALIDCHAR_LAST
        else
            self.nameSelection[self.currentSpaceSelection]  = self.nameSelection[self.currentSpaceSelection]  - 1
        end
    end
    if love.keyboard.wasPressed('down') then
        gSounds['menuSelection']:play()
        if(self.nameSelection[self.currentSpaceSelection]  == SCORE_VALIDCHAR_LAST) then
            self.nameSelection[self.currentSpaceSelection]  = SCORE_VALIDCHAR_FIRST
        else
            self.nameSelection[self.currentSpaceSelection]  = self.nameSelection[self.currentSpaceSelection]  + 1
        end
    end
    if love.keyboard.wasPressed('left') then
        gSounds['menuSelection']:play()
        if(self.currentSpaceSelection == SCORE_LETTER_FIRST) then
            self.currentSpaceSelection= SCORE_LETTER_RIGHT
        else
            self.currentSpaceSelection = self.currentSpaceSelection - 1
        end
    end
    if love.keyboard.wasPressed('right') then
        gSounds['menuSelection']:play()
        if(self.currentSpaceSelection == SCORE_LETTER_RIGHT) then
            self.currentSpaceSelection = SCORE_LETTER_FIRST
        else
            self.currentSpaceSelection = self.currentSpaceSelection + 1
        end
    end

    -- Finsihed.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- Register changes in score file.
        self:Register()

        -- Go to show high score state, letting know there is a new highscore.
        gStateMachine:change('show-high-score', {
            line = self.line,
            newHighScore = true
        })
    end
end

function TypeHighScoreState:render() 

    -- Draw brick background
    love.graphics.draw(gTextures['show-score'], -32, 0)

    -- Final score Text
    love.graphics.setFont(gFonts['info'])
    love.graphics.setColor(255,165,0, 255)
    love.graphics.print("FINAL SCORE:", VIRTUAL_WIDTH/4 + 25, 15)

    -- Print score on screen
    love.graphics.setFont(gFonts['final-score'])
    love.graphics.print(tostring(self.score), VIRTUAL_WIDTH/4 + 30, 45)
    
    -- Message to player
    love.graphics.setFont(gFonts['info'])
    love.graphics.print("CONGRATULATIONS", VIRTUAL_WIDTH/4 + 10, 85)

    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("A NEW HIGH SCORE! ENTER YOUR NAME:", 20, 105)


    -- Set new font
    love.graphics.setFont(gFonts['final-score'])

    -- Print our name letters. Current selected letter will be orange and will have and
    -- an underscore, others will be green. Player changes (cursor or character) are updated
    -- Translation of index to character happens after choosing colors. See VALID_CHAR table
    -- in constant.lua to see who change to who.

    love.graphics.setFont(gFonts['final-score'])
    if self.currentSpaceSelection == 1 then
        love.graphics.setColor(255,165,0, 255)
        love.graphics.rectangle("fill", 85 + 20, VIRTUAL_HEIGHT / 2 + 50, 12, 2)
    else
        love.graphics.setColor(0, 255, 0, 255)
    end
    love.graphics.print(VALID_CHAR[self.nameSelection[1]], 85 + 20, VIRTUAL_HEIGHT / 2 + 30)

    if self.currentSpaceSelection == 2 then
        love.graphics.setColor(255,165,0, 255)
        love.graphics.rectangle("fill", 85 + 40, VIRTUAL_HEIGHT / 2 + 50, 12, 2)
    else
        love.graphics.setColor(0, 255, 0, 255)
    end
    love.graphics.print(VALID_CHAR[self.nameSelection[2]], 85 + 40, VIRTUAL_HEIGHT / 2 + 30)

    if self.currentSpaceSelection == 3 then
        love.graphics.setColor(255,165,0, 255)
        love.graphics.rectangle("fill", 85 + 60, VIRTUAL_HEIGHT / 2 + 50, 12, 2)
    else
        love.graphics.setColor(0, 255, 0, 255)
    end
    love.graphics.print(VALID_CHAR[self.nameSelection[3]], 85 + 60, VIRTUAL_HEIGHT / 2 + 30)

    -- Foot message.
    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("PRESS START TO  FINISH", OFFSET_X + TILE_SIZE/2, VIRTUAL_HEIGHT - 32)
end