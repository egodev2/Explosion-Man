Player = Class{__includes = Entity}

function Player:init(def)
    self.lives = def.lives or 2

    -- Bombs placed
    self.actualBombs = 0

    -- Max bombs that can be placed.
    self.maxBombs = def.maxBombs or 1

    -- Current bomb power.
    self.power = def.power or 1
    Entity.init(self, def)
end

function Player:onOneUP()
    -- Increase life, if it is not at the max limit.
    if self.lives < MAX_LIVES then
        gSounds['oneUp']:play()
        self.lives = self.lives + 1
    end
end

function Player:onDeath()

    -- Decrement a life
    self.lives = self.lives - 1 

    -- Remove all the powerups that the player got
    self.maxBombs = 1
    self.power = 1

    -- Death sound
    gSounds['playerDies']:play()
end

function Player:update(dt)
    Entity.update(self, dt) 
end
function Player:render()
    Entity.render(self)
end