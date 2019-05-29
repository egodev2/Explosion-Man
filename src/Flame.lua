Flame = Class{}

function Flame:init(def)

    self.x = def.x
    self.y = def.y
    self.width = TILE_SIZE
    self.height = TILE_SIZE

    -- Set or not to flip sprite
    self.flip = def.flip

    -- Is it a tip of the blast?
    self.tip = def.tip or false

    -- Is the souce of the blast?
    self.source = def.source or false

    self.texture = def.texture or 'objects'
    self.animations = self:createAnimations(OBJECT_DEFS['blast'].animations)

    -- Set apropriate animation for each flame part.
    if self.tip then
        self:changeAnimation('tip')
    elseif self.source then
        self:changeAnimation('source')
    else
        self:changeAnimation('mid')
    end
end

function Flame:createAnimations(animations)
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

function Flame:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Flame:update(dt)
    -- Animation update only.
    self.currentAnimation:update(dt)
end

function Flame:render() 

    local anim = self.currentAnimation
    
     -- Horizontal Flame
    if self.flip == 90 or self.flip == 270 then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][anim:getCurrentFrame()],
        self.x + self.width/2, self.y + self.height/2, -math.rad(self.flip), 1, 1, TILE_SIZE/2, TILE_SIZE/2)
    -- Vertical Flame
    elseif self.flip == 180 or self.flip == 0 then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][anim:getCurrentFrame()],
        self.x + self.width/2, self.y + self.height/2, math.rad(self.flip), -1, 1, TILE_SIZE/2, TILE_SIZE/2)
    -- Source Flame
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][anim:getCurrentFrame()],
        self.x, self.y)
    end
    
end