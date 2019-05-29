FadeInState = Class {__include = BaseState}

function FadeInState:init(time) 

    self.opacity = 0
    self.time = time

    -- Annoucement text's color. To be determined in level generation.
    self.annoucementColor = nil

    -- Position x of annoucement Text. It will be hidden!
    self.xText = FADE_TEXT_INIT

end
function FadeInState:enter(params) 

    self.levelNumber = params.levelNumber
    self.score = params.score

    -- We save the old level or demonstraion map so we can see it before we completely fade in.
    self.oldLevel = params.oldLevel
    self.demoMap = params.demoMap

    -- Create Player
    self.player = Player {
        HP = ENTITY_DEFS['player'].HP,
        speed = ENTITY_DEFS['player'].speed,
        animations = ENTITY_DEFS['player'].animations,
        speed = ENTITY_DEFS['player'].speed,
 
        maxBombs = params.maxBombs,
        power = params.power,
        lives = params.lives,
        width = 16,
        height = 32
    }

    -- Create our level
    local level = LevelGenerator.create({ 
        player = self.player, 
        levelNumber = self.levelNumber,
        score = self.score
    })

    -- Change the announcement color to the apropriate pattern
    self.annoucementColor = level.hud.cPattern[BACKGROUND]

    -- Set player state machine
    self.player.stateMachine = StateMachine {
        ['idle'] = function() return PlayerIdleState(self.player, level.map) end,
        ['walk'] = function() return PlayerWalkingState(self.player, level.map) end
    }

    -- Timer transition to white. Notice that we have everything ready to 
    -- fadeout and playstate.
    Timer.tween(self.time,{
        [self] = { opacity = 255 }
    }):finish(function()

        -- Move the announcement text to the middle of screen.
        Timer.tween(2.0,{
            [self] = {xText = FADE_TEXT_PAUSE}
        }):finish(function ()
            -- Play sound
            gSounds['newStage']:play()

            -- Once its finished, slide annoucement text to other end to make go out of ingame screen
            Timer.after(2.0, function()
                Timer.tween(2.0,{
                    [self] = { xText = FADE_TEXT_END }
                }):finish(function()
                    -- Change state on finish.
                    gStateMachine:change('fade-out', {
                        level = level
                    })
                end)
            end)
        end)
    end)

end
function FadeInState:exit() 

end
function FadeInState:update(dt) 

end
function FadeInState:render() 

    -- Render oldlevel or demonstration map (if we've come from title screen)
    if self.oldLevel then
        self.oldLevel:render()
    else
        self.demoMap:render()
    end

    -- Fade in
    love.graphics.setColor(255,255,255,self.opacity)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

    -- Level annoucement
    love.graphics.setFont(gFonts['fade-anouncement'])
    if self.annoucementColor then
        love.graphics.setColor(self.annoucementColor)
    else
        love.graphics.setColor(255,255,255,0)
    end
    love.graphics.print("Level ".. tostring(self.levelNumber),  self.xText, VIRTUAL_HEIGHT/2 - 20)
end