-- Class that is just a Display Effect.
-- Used to draw a score after an entity is killed by a blast.
--

ScorePopUp = Class{}

function ScorePopUp:init(def) 

    self.x = def.x
    self.y = def.y

    -- ScorePopUp's current time
    self.timer = 0

    -- If it is set delete or not
    self.delete = false

    -- The score to be printed
    self.score = def.score or 500

    Timer.every(0.5, function() 
        self.timer = self.timer + 0.5
    end):limit(5)
end

function ScorePopUp:update(dt) 
    if self.timer >= 2.5 then
        self.delete = true
    end
end

function ScorePopUp:render() 
    -- We only write the score on screen if it was'nt set to delete.
    if not self.delete then
        love.graphics.setFont(gFonts['info'])
        love.graphics.setColor(255, 235, 204, 255)
        love.graphics.print(tostring(self.score),  self.x, self.y)
    end
end