PlayerWalkingState = Class{__includes = WalkingState}

function PlayerWalkingState:init(player, map) 

    self.player = player
    self.map = map
    self.objects = map.objects
    self.entities = map.entities
    self.tiles = map.tiles
    self.tPattern = map.tPattern

    self.lastDirection = self.player.direction
    self.player:changeAnimation('walk-' .. self.player.direction)

end
-- function PlayerWalkingState:enter() end
function PlayerWalkingState:update(dt) 

    if love.keyboard.isDown('up') then
        self.player.direction = 'up'
        self.player:changeAnimation('walk-up')
        -- Hover player back to current tile before walking to a perpendicular direction,
        -- otherwise player malk walk partially trough blocks
        if self.oldDirection == 'right' or self.oldDirection == 'left' then
            local Hx = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
            local Hy = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
            self.player.x = (Hx - 1) * TILE_SIZE
            self.player.y = (Hy - 1) * TILE_SIZE
        end
        self.oldDirection = self.player.direction
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player:changeAnimation('walk-right')
        -- Hover player back to current tile before walking to a perpendicular direction,
        -- otherwise player you walk partially blocks
        if self.oldDirection == 'up' or self.oldDirection == 'down' then
            local Hx = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
            local Hy = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
            self.player.x = (Hx - 1) * TILE_SIZE
            self.player.y = (Hy - 1) * TILE_SIZE
        end
        self.oldDirection = self.player.direction
    elseif love.keyboard.isDown('down') then
        self.player.direction = 'down'
        self.player:changeAnimation('walk-down')
        -- Hover player back to current tile before walking to a perpendicular direction,
        -- otherwise player you walk partially blocks
        if self.oldDirection == 'right' or self.oldDirection == 'left' then
            local Hx = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
            local Hy = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
            self.player.x = (Hx - 1) * TILE_SIZE
            self.player.y = (Hy - 1) * TILE_SIZE
        end
        self.oldDirection = self.player.direction
    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player:changeAnimation('walk-left')
        -- Hover player back to current tile before walking to a perpendicular direction,
        -- otherwise player you walk partially blocks
        if self.oldDirection == 'up' or self.oldDirection == 'down' then
            local Hx = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
            local Hy = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
            self.player.x = (Hx - 1) * TILE_SIZE
            self.player.y = (Hy - 1) * TILE_SIZE
        end
        self.oldDirection = self.player.direction
    else
        self.player:changeState('idle')
    end

    local Ej = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
    local Ei = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1

    if love.keyboard.wasPressed('space') and self.player.actualBombs < self.player.maxBombs 
    and not self.map:isThereBomb(Ei,Ej) then 
        -- Get Tile(x,y) of where the player is
        local x,y = (Ej - 1) * TILE_SIZE, (Ei - 1) * TILE_SIZE

        -- insert the bomb
        gSounds['putBomb']:play()  
        table.insert(self.objects, GameObject {
            x = x,
            y = y,
            solid = true,
            animations = OBJECT_DEFS['bomb'].animations,
            texture = 'objects',
            tiles = self.map.tiles,
            tPattern = self.map.tPattern,
            power = self.player.power
        })

        
        self.player.actualBombs = self.player.actualBombs + 1
    end

    if self.player.direction == 'up' then
        local oldY = (Ei-1) * TILE_SIZE
        local oldX = (Ej-1) * TILE_SIZE

        self.player.y = self.player.y - dt * self.player.speed
        local bumped = self.player.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        local i, texture = self.player.hitbox:collisionCheckPlayer(self.entities, self.objects)

        if bumped then
            self.player.x = oldX
            self.player.y = oldY
        elseif texture then
            if texture == 'entities' then
                if not self.player.invulnerable then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME )
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                end
            else
                -- Blast collision
                if self.objects[i].nhitboxes > 1 and not self.player.invulnerable and 
                (self.objects[i].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
                self.objects[i].hitbox[VERTICALH]:isThereFlame(Ei,Ej)) then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME)
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                    -- powerup
                elseif self.objects[i].inPlay and not self.objects[i].solid and self.objects[i].nhitboxes == 1 then
                    gSounds['pickup']:play()
                    self.map.score = self.map.score + self.objects[i].onConsume(self.player)
                    self.objects[i].inPlay = false
                end
            end
        end
    elseif self.player.direction == 'right' then
        local oldY = (Ei-1) * TILE_SIZE
        local oldX = (Ej-1) * TILE_SIZE

        self.player.x = self.player.x + dt * self.player.speed
        local bumped = self.player.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        local i, texture = self.player.hitbox:collisionCheckPlayer(self.entities, self.objects)

        if bumped then
            self.player.x = oldX
            self.player.y = oldY
        elseif texture then
            if texture == 'entities' then
                if not self.player.invulnerable then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME )
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                end
                -- object collision
            else
                -- Blast collision
                if self.objects[i].nhitboxes > 1 and not self.player.invulnerable and 
                (self.objects[i].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
                self.objects[i].hitbox[VERTICALH]:isThereFlame(Ei,Ej)) then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME)
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                    -- powerup
                elseif self.objects[i].inPlay and not self.objects[i].solid and self.objects[i].nhitboxes == 1 then
                    gSounds['pickup']:play()
                    self.map.score = self.map.score + self.objects[i].onConsume(self.player)
                    self.objects[i].inPlay = false
                end
            end
        end
    elseif self.player.direction == 'down' then
        local oldY = (Ei-1) * TILE_SIZE
        local oldX = (Ej-1) * TILE_SIZE
        
        self.player.y = self.player.y + dt * self.player.speed
        local bumped = self.player.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        local i, texture = self.player.hitbox:collisionCheckPlayer(self.entities, self.objects)

        if bumped then
            self.player.y = oldY
            self.player.x = oldX
        elseif texture then
            if texture == 'entities' then
                if not self.player.invulnerable then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME )
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                end
                -- object collision
            else
                -- Blast collision
                if self.objects[i].nhitboxes > 1 and not self.player.invulnerable and 
                (self.objects[i].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
                self.objects[i].hitbox[VERTICALH]:isThereFlame(Ei,Ej)) then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME)
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                    -- powerup
                elseif self.objects[i].inPlay and not self.objects[i].solid and self.objects[i].nhitboxes == 1 then
                    gSounds['pickup']:play()
                    self.map.score = self.map.score + self.objects[i].onConsume(self.player)
                    self.objects[i].inPlay = false
                end
            end
        end
    elseif self.player.direction == 'left' then
        local oldY = (Ei-1) * TILE_SIZE
        local oldX = (Ej-1) * TILE_SIZE

        self.player.x = self.player.x - dt * self.player.speed
        local bumped = self.player.hitbox:bumpCheck(self.tiles, self.objects, self.tPattern)
        local i, texture = self.player.hitbox:collisionCheckPlayer(self.entities, self.objects)

        if bumped then
            self.player.y = oldY
            self.player.x = oldX
        elseif texture then
            if texture == 'entities' then
                if not self.player.invulnerable then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME )
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                end
                -- object collision
            else
                 -- Blast collision
                if self.objects[i].nhitboxes > 1 and not self.player.invulnerable and 
                (self.objects[i].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
                self.objects[i].hitbox[VERTICALH]:isThereFlame(Ei,Ej)) then
                    self.player:onDeath()
                    if self.player.lives >= 0 then
                        self.player:goInvulnerable(PLAYER_INVUL_TIME)
                        self:Respawn()
                    else
                        self.player.dead = true
                    end
                -- powerup
                elseif self.objects[i].inPlay and not self.objects[i].solid and self.objects[i].nhitboxes == 1 then
                    gSounds['pickup']:play()
                    self.map.score = self.map.score + self.objects[i].onConsume(self.player)
                    self.objects[i].inPlay = false
                end
            end
        end
    end

    self.player.hitbox:update(dt)
end

function PlayerWalkingState:Respawn()

    local i,j
    local found = false
    for i = 3, MAX_MAP_LINE - 1 do
        for j = 2, MAX_MAP_COLUMN - 1 do 
            if(self.map.tiles[i][j].id == self.map.tPattern[EMPTYSPACE_TILE]) then
                self.player.y = TILE_SIZE * (i - 1)
                self.player.x = TILE_SIZE * (j - 1)
                found = true
                break
            end
        end
        if found then break end
    end
end

function PlayerWalkingState:render() 
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x), math.floor(self.player.y + PLAYER_OFFSET_Y_RENDER))
    --love.graphics.setColor(255, 0, 255, 255)
    --love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    --love.graphics.setColor(255, 255, 255, 255)
end