PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player, map) 

    self.player = player
    self.map = map
    self.objects = self.map.objects

    -- Make sure that player is inside tile. It's the "hoovering" effect
    -- when you stop between tiles.
    local x = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
    local y = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
    self.player.x = (x - 1) * TILE_SIZE
    self.player.y = (y - 1) * TILE_SIZE  

    -- Apply changes to hitbox too.
    self.player.hitbox.x = self.player.x + 1 
    self.player.hitbox.y = self.player.y + 1
    
    self.player:changeAnimation('idle-' .. self.player.direction)

end

function PlayerIdleState:update(dt) 

    -- Check if player tried to move.
    if love.keyboard.isDown('up') or love.keyboard.isDown('right') or
    love.keyboard.isDown('down') or love.keyboard.isDown('left') then
        self.player:changeState('walk')
    end

    -- Check if player tried to put a bomb. There can't be a bomb where he is and player didn't
    -- put all possible bombs.
    if love.keyboard.wasPressed('space') and self.player.actualBombs < self.player.maxBombs 
    and not self.map:isThereBomb(i,j) then

        -- Get Tile(x,y) of where the player is
        local j = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
        local i = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1
        local x,y = (j - 1) * TILE_SIZE, (i - 1) * TILE_SIZE

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

        -- Update player's current placed bombs.
        self.player.actualBombs = self.player.actualBombs + 1
    end

    -- Collision Check with Blasts and Entities
    local i, texture = self.player.hitbox:collisionCheckPlayer(self.map.entities, self.map.objects)
    if texture == 'objects' then 

        local Ej = math.floor(self.player.hitbox.centeredX/TILE_SIZE) + 1
        local Ei = math.floor(self.player.hitbox.centeredY/TILE_SIZE) + 1

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
        end
    elseif texture == 'entities' then
        if not self.player.invulnerable then
            self.player:onDeath()
            if self.player.lives >= 0 then
                self.player:goInvulnerable(PLAYER_INVUL_TIME )
                self:Respawn()
            else
                self.player.dead = true
            end
        end
    end

    -- Update our hitbox
    self.player.hitbox:update(dt)
end

function PlayerIdleState:Respawn()

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

function PlayerIdleState:render() 
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x), math.floor(self.player.y + PLAYER_OFFSET_Y_RENDER))
    --love.graphics.setColor(255, 0, 255, 255)
    --love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    --love.graphics.setColor(255, 255, 255, 255)
end