GameOverState = Class {__include = BaseState}

function GameOverState:init() 
    -- Play GameOver sound
    gSounds['gameover']:play()
end

function GameOverState:enter(params) 

end

function GameOverState:exit() 

end

function GameOverState:update(dt) 
    -- Wait for player input to return to title
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['menuSelection']:play()
        gStateMachine:change('title')
    end
end

function GameOverState:render() 

    -- Gray-Black color backgroud.
    love.graphics.setColor(50,50,50,255)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- Printing other messages.
    love.graphics.setFont(gFonts['title'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("GAMEOVER", 40, VIRTUAL_HEIGHT / 2 - 70)

    love.graphics.setFont(gFonts['toption'])
    love.graphics.setColor(255, 153, 0, 255)
    love.graphics.print("Press START", VIRTUAL_WIDTH/3 - 10, 3 * VIRTUAL_HEIGHT / 4 + 10) 
    
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("to return to the title", VIRTUAL_WIDTH/2 - VIRTUAL_WIDTH/3 - 5, 3 * VIRTUAL_HEIGHT / 4 + 30)
end