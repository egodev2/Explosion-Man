TitleState = Class{__includes = BaseState}

function TitleState:init() 
    -- Default Title menu option (cursor)
    self.selection = 1

     -- Create high-score file if it doesn't exist.
     if (not love.filesystem.exists("HighScore.lst")) then
        local scoreFile = love.filesystem.newFile("HighScore.lst")
        scoreFile:open("w")

        -- Highest score belongs to dev! :D
        local position = 1
        local name = "DIE"
        local score = 300000 
        scoreFile:write(formatedScoreLine(position,name,score))
        score = score + 5000
        -- Write other 9 entries, there is a little easter egg.
        for i = 1, 9 do 
            score = score - math.random(1,3) * 10000
            position = position + 1
            scoreFile:write(formatedScoreLine(position,NAMES_LIST[i],score))
        end
        scoreFile:close()
    end

    -- Create a demosntration map to be displayed at the background
    self.demoMap = DemoMap {}

    -- Give a blinking effect in the menu cursor
    self.menuCursor = true
    Timer.every(0.25, function ()
        self.menuCursor = not self.menuCursor
    end)
end

function TitleState:enter(params) 

end

function TitleState:update(dt) 
    
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Tile screen menu selection
    if love.keyboard.wasPressed('up') then
        gSounds['menuSelection']:play()
        if(self.selection == TITLE_MENU_FIRST) then
            self.selection = TITLE_MENU_LAST
        else
            self.selection = self.selection - 1
        end
    end
    if love.keyboard.wasPressed('down') then
        gSounds['menuSelection']:play()
        if(self.selection == TITLE_MENU_LAST) then
            self.selection = TITLE_MENU_FIRST
        else
            self.selection = self.selection + 1
        end
    end

    -- Wait for user input in menu option.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

        -- Start selection
        if(self.selection == 1) then
        gSounds['menuSelection']:play()
            gStateMachine:change('fade-in', {
                demoMap = self.demoMap,
                levelNumber = 1,
                score = 0,
            })
        -- High-score Selection
        elseif self.selection == 2 then
            gSounds['menuSelection']:play()
            gStateMachine:change('show-high-score', {

            })
        -- Exit Selection
        elseif self.selection == 3 then
            love.event.quit()
        end
    end
end

function formatedScoreLine(position, name, score)

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

function TitleState:render() 

    -- Render our demosntration map.
    self.demoMap:render()

    -- Box Game's Title --

    -- Title Background
    love.graphics.setColor(self.demoMap.cPattern[BACKGROUND])
    love.graphics.rectangle("fill", 32, 16, VIRTUAL_WIDTH - 4 * TILE_SIZE, TILE_SIZE * 4.5)

    -- Border
    love.graphics.setColor(self.demoMap.cPattern[OUTER_BORDER])
    -- Upper line
    love.graphics.line(32, 16, VIRTUAL_WIDTH - 2 * TILE_SIZE, 16)
    -- Down Line
    love.graphics.line(32, 16 + TILE_SIZE * 4.5, VIRTUAL_WIDTH - 2 * TILE_SIZE, 16 + TILE_SIZE * 4.5)
    -- Right column
    love.graphics.line(32 + VIRTUAL_WIDTH - 4 * TILE_SIZE, 16, 32 + VIRTUAL_WIDTH - 4 * TILE_SIZE, TILE_SIZE * 5.5)
    -- Left column
    love.graphics.line(32, 16, 32, TILE_SIZE * 5.5)

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Explosion", VIRTUAL_WIDTH/2 -VIRTUAL_WIDTH/4 - 32, VIRTUAL_HEIGHT / 2 - 90)

    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Man", VIRTUAL_WIDTH/2 - 32, VIRTUAL_HEIGHT / 2 - 58)
    
    -- Render Title Menu --

    love.graphics.setColor(self.demoMap.cPattern[BACKGROUND][1],self.demoMap.cPattern[BACKGROUND][2],self.demoMap.cPattern[BACKGROUND][3], 144)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH/2 + -VIRTUAL_WIDTH/4 - 12, VIRTUAL_HEIGHT / 2 + 24, 7 * TILE_SIZE, 4 * TILE_SIZE)

    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("START", VIRTUAL_WIDTH/2 + -VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT / 2 + 29)

    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("HIGHSCORE", VIRTUAL_WIDTH/2 + -VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT / 2 + 49)

    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("EXIT", VIRTUAL_WIDTH/2 + -VIRTUAL_WIDTH/4, VIRTUAL_HEIGHT / 2 + 69)

    -- Menu Cursor
    if self.menuCursor then
        love.graphics.rectangle('fill', VIRTUAL_WIDTH/2 + -VIRTUAL_WIDTH/4 - 8, (VIRTUAL_HEIGHT + 32)/ 2 + (20 * self.selection), 4, 4)
    end

end