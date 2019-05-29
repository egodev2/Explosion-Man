FadeOutState = Class {__include = BaseState}

function FadeOutState:init(time) 

    self.opacity = 255
    self.time = time

    -- Timer transition to white
    Timer.tween(self.time, {
        [self] = {opacity = 0}
    }):finish(function()
        gStateMachine:change('play', {
            level = self.level,
        })
    end)

end
function FadeOutState:exit() 

end
function FadeOutState:enter(params) 
    self.level = params.level
end
function FadeOutState:update(dt) 

end
function FadeOutState:render() 
    -- Draw Level
    self.level:render()

    -- Draw fade effect
    love.graphics.setColor(255,255,255,self.opacity)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
end