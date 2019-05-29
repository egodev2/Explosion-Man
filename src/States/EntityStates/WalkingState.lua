WalkingState = Class{__includes = BaseState}

function WalkingState:init(entity, tiles, objects, tPattern)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    self.tiles = tiles
    self.objects = objects
    self.tPattern = tPattern

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keep

    self.CollidedWhileWalkingLeft = false
    self.CollidedWhileWalkingRight = false
    self.CollidedWhileWalkingUp = false
    self.CollidedWhileWalkingDown = false

    -- keeps track of whether we just hit a wall
    self.bumped = false
end

function WalkingState:update(dt) -- TO DO  

    local i, texture = self.entity.hitbox:collisionCheck(nil, self.objects)

    if texture == 'objects' then 

        local Ej = math.floor(self.entity.hitbox.centeredX/TILE_SIZE) + 1
        local Ei = math.floor(self.entity.hitbox.centeredY/TILE_SIZE) + 1

        if self.objects[i].nhitboxes > 1 and not self.entity.invulnerable and 
        (self.objects[i].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
        self.objects[i].hitbox[VERTICALH]:isThereFlame(Ei,Ej)) then
            self.entity.HP = self.entity.HP - 1
            if self.entity.HP >= 1 then
                self.entity:goInvulnerable(ENTITY_INVUL_TIME)
            else
                self.entity.dead = true
            end
        end
    end
    self.entity.hitbox:update(dt)
end

function WalkingState:LeftOverlapDistance(obj)
    return math.abs(self.entity.x - (obj.x + obj.width))
end

function WalkingState:RightOverlapDistance(obj)
    return math.abs((self.entity.x + self.entity.width) - obj.x) 
end

function WalkingState:AboveOverlapDistance(obj)
    return math.abs((self.entity.y + self.entity.height) - obj.y)
end

function WalkingState:BelowtOverlapDistance(obj)
    return math.abs((obj.y + obj.height) - self.entity.y)
end

function WalkingState:processAI(dt) -- TO DO

    local i = math.floor(self.entity.hitbox.centeredY/TILE_SIZE) + 1
    local j = math.floor(self.entity.hitbox.centeredX/TILE_SIZE) + 1

    if self.entity.direction == 'up' then
        local oldY = (i-1) * TILE_SIZE
        local oldX = (j-1) * TILE_SIZE

        self.entity.y = self.entity.y - dt * self.entity.speed
        self.bumped = self.entity.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        if self.bumped then
            self.entity.y = oldY
            self.entity.x = oldX
        end
    elseif self.entity.direction == 'right' then
        local oldY = (i-1) * TILE_SIZE
        local oldX = (j-1) * TILE_SIZE

        self.entity.x = self.entity.x + dt * self.entity.speed
        self.bumped = self.entity.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        if self.bumped then
            self.entity.x = oldX
            self.entity.y = oldY
        end
    elseif self.entity.direction == 'down' then
        local oldY = (i-1) * TILE_SIZE
        local oldX = (j-1) * TILE_SIZE

        self.entity.y = self.entity.y + dt * self.entity.speed
        self.bumped = self.entity.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        if self.bumped then
            self.entity.y = oldY
            self.entity.x = oldX
        end
    else
        local oldY = (i-1) * TILE_SIZE
        local oldX = (j-1) * TILE_SIZE

        self.entity.x = self.entity.x - dt * self.entity.speed
        self.bumped = self.entity.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        if self.bumped then
            self.entity.x = oldX
            self.entity.y = oldY
        end
    end
    
    -- Need to choose a new random direction
    if self.bumped then
        local tRemainingDirections = self:FilterDirections()
        if #tRemainingDirections == 0 then
            self.entity.direction = 'down'
        else
            self.entity.direction = tRemainingDirections[math.random(1,#tRemainingDirections)]
        end
        self.entity:changeAnimation('walk-' .. self.entity.direction)
        self.bumped = false
    end
end

function WalkingState:FilterDirections()

    local tPossibleDirections = {'up','right','down','left'}
    local Ei = math.floor((self.entity.hitbox.centeredY/TILE_SIZE)) + 1
    local Ej = math.floor((self.entity.hitbox.centeredX/TILE_SIZE)) + 1

    -- remove actual direction
    for k, dir in pairs(tPossibleDirections) do
        if dir == self.entity.direction then
            table.remove(tPossibleDirections,k)
            break
        end
    end
     
    -- Check others
    for k, dir in pairs(tPossibleDirections) do
        if dir == 'up' then
            if self.tiles[Ei-1][Ej].id ~= self.tPattern[EMPTYSPACE_TILE] then
                table.remove(tPossibleDirections,k)
            end
        elseif dir == 'right' then
            if self.tiles[Ei][Ej+1].id ~= self.tPattern[EMPTYSPACE_TILE] then
                table.remove(tPossibleDirections,k)
            end
        elseif dir == 'down' then
            if self.tiles[Ei+1][Ej].id ~= self.tPattern[EMPTYSPACE_TILE] then
                table.remove(tPossibleDirections,k)
            end
        else
            if self.tiles[Ei][Ej-1].id ~= self.tPattern[EMPTYSPACE_TILE] then
                table.remove(tPossibleDirections,k)
            end
        end
    end

    return tPossibleDirections
end

function WalkingState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y))
end