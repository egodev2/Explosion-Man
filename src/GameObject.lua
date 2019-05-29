GameObject = Class{}

function GameObject:init(def) 

    self.x = def.x
    self.y = def.y
    self.width = def.width or TILE_SIZE
    self.height = def.height or TILE_SIZE


    self.texture = def.texture
    self.animations = self:createAnimations(def.animations)

    self.nhitboxes = def.nhitboxes or 1
    self.hitbox = {}

    if self.nhitboxes == 1 then
        table.insert(self.hitbox, def.hitbox or Hitbox {
            x = self.x,
            y = self.y,
            width = TILE_SIZE,
            height = TILE_SIZE,
            texture = self.texture,
            centeredX = self.x + self.width/2,
            centeredY = self.y + self.height/2
        })
    -- The blast will have two hitboxes: vertical and horizontal.   
    else

        -- HORIZONTAL
        self.blast = true
        self.power = def.power

        table.insert(self.hitbox,  Hitbox {
            x = self.x - TILE_SIZE * self.power,
            y = self.y,
            width = TILE_SIZE * (1 + 2 * self.power),
            height = TILE_SIZE,
            texture = self.texture,
            centeredX = self.x + self.width/2,
            centeredY = self.y + self.height/2,
            tPattern = def.tPattern,
            power = def.power,
            tiles = def.tiles,
        })
        -- VERTICAL
        table.insert(self.hitbox,  Hitbox {
            x = self.x,
            y = self.y - TILE_SIZE * self.power,
            width = TILE_SIZE,
            height = TILE_SIZE * (1 + 2 * self.power),
            texture = self.texture,
            centeredX = self.x + self.width/2,
            centeredY = self.y + self.height/2,
            power = def.power,
            tiles = def.tiles,
            tPattern = def.tPattern
        })
    end

    -- To identify a bomb and set it to explode
    self.solid = def.solid or false
    self.explode = false

    -- To identify a powerup 
    self.type = def.type or nil 
    self.consumable = def.consumable or false

    -- Time for aniamtion will come from a def or it will be for a bomb
    self.timer = def.timer or BOMB_TOTAL_TIME 

    self.inPlay = true

    -- Change to apropriate animations, if possible.
    if self.solid then self:changeAnimation('ticking') end

    if self.consumable then
        self.onConsume = def.onConsume
        if self.type == "fire" then
            self:changeAnimation('fire-flash')
        else
            self:changeAnimation('bomb-flash')
        end
    else
        self.onConsume = function() end
    end
end

function GameObject:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'objects',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

function GameObject:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function GameObject:update(dt) 

    -- Update our objects.
    if self.inPlay and not self.explode then
        -- Check if it's a bomb (only bombs are solid)
        if self.solid then 
            self.timer = self.timer - dt
            -- If time's up for bomb -> set for BOOM
            if self.timer < 0 then 
                 -- set to create the explosion
                self.explode = true
                self.inPlay = false
            else
                self.currentAnimation:update(dt)
            end
    -- If it's a blast
        elseif self.blast then
            if self.timer < 0 then
                self.inPlay = false
            else
                self.timer = self.timer - dt
                self.hitbox[HORIZONTALH]:update(dt) 
                self.hitbox[VERTICALH]:update(dt)
            end
        -- If's a power-up
        elseif self.nhitboxes == 1 and not self.blast then 
            self.currentAnimation:update(dt)
        end
    end
end

function GameObject:render() 

    -- Blast is drawn by the flame class, only draw objects that have 1 hitbox
    if self.nhitboxes == 1 then
        local anim = self.currentAnimation
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][anim:getCurrentFrame()],
        math.floor(self.x), math.floor(self.y))  
    else
        for i = 1, self.nhitboxes do
            self.hitbox[i]:render()
        end
    end
end