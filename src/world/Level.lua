Level = Class{}

function Level:init(params)

    self.number = params.number
    self.timer = params.timer
    self.map = params.map

    -- Create a Hud at Top Screen
    self.hud = Hud {
        level = self,
        cPattern = params.cPattern,
    }
end

function Level:update(dt)
    -- Update Map. 
    self.map:update(dt)

    -- Update Hud
    self.hud:update(dt)
end

function Level:render()
    -- Draw Map
    self.map:render()

    -- Draw status bar
    self.hud:render()
end