Entity = Class{}

function Entity:init(def) 

    self.direction = def.direction or 'down'
    self.texture = def.texture
    self.HP = def.HP or 1
    self.maxHP = def.maxHP or 1
    self.animations = self:createAnimations(def.animations)   

    self.width = def.width or 16
    self.height = def.height or 16
    self.x = def.x or 0
    self.y = def.y or 0
    self.speed = def.speed or ENTITY_DEFAULT_SPEED

    self.invulnerable = def.invulnerable or false
    self.invulnerableDuration = def.invulnerableDuration or 0
    self.invulnerableTimer = 0
    self.flashTimer = 0
    self.dead = false

    -- properties
    -- NOT USED, BUT IMPLEMENTABLE: self.flying = def.flying or false
end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

function Entity:getHitbox()
    return self.hitbox
end

function Entity:goInvulnerable(duration)
    self.invulnerable = true
    self.invulnerableDuration = duration
end

function Entity:changeState(name)
    self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

function Entity:onDeath()
    self.hitbox = nil
end

function Entity:update(dt) 

    -- Entity invulnerability, appliable if he has max HP > 1
    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        -- Turn off invulnerability, reset timers.
        if self.invulnerableTimer > self.invulnerableDuration then
            self.invulnerable = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end

    self.stateMachine:update(dt)
    self.currentAnimation:update(dt)
end

function Entity:render() 

    -- Invul rendering
    if self.invulnerable and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(255, 255, 255, 64)
    end

    -- Entity State Machine rendering
    if not self.dead then
        self.stateMachine:render()
    end

    love.graphics.setColor(255, 255, 255, 255)
end
