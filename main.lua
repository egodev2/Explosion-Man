require 'src/Dependencies'

function love.load()

    -- DEBUG
    love.filesystem.setIdentity('Explosion Man')

    math.randomseed(os.time())
    love.window.setTitle(WINDOW_TITLE)
    love.graphics.setDefaultFilter('nearest','nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['title'] = function() return TitleState() end,
        ['fade-in'] = function () return FadeInState(FADE_TIME) end,
        ['fade-out'] = function () return FadeOutState(FADE_TIME) end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end,
        ['type-high-score'] = function() return TypeHighScoreState() end,
        ['show-high-score'] = function() return ShowHighScoreState() end
    }

    gStateMachine:change('title', {
        levelNumber = 1
    })

    -- gSounds['music']:setLooping(true)
    -- gSounds['music']:play()

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    Timer.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end