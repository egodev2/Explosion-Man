Exit = Class {}

function Exit:init(def) 

    self.x = def.x
    self.y = def.y

    self.hitbox = Hitbox {
        x = self.x,
        y = self.y,
        texture = 'tiles'
    }
    -- There will always be entities on level creation, false by default
    self.activated = false

    -- Exit is created on a NONDESTRUCTABLE on level creation, true by default.
    self.obstructed = true

    -- Check if player collided the Exit.
    self.usedByPlayer = false

    -- Level information necessary
    self.entities = def.entities
    self.tiles = def.tiles
    self.tPattern = def.tPattern
    self.player = def.player

    -- Tile Animation
    -- Will always start off (1 frame). However, once its not obstructed and it activates, it will never
    -- turn off and the cycle will go trough 6 frames. Since framestart is the first frame when it's turned on, we need to ge the frame 
    -- before for currentFrame (look at tile sprite sheet).
    self.frameStart = TILE_SET_SPRITE_WIDTH * (TILE_SET_SPRITE_HEIGHT - 1) + 2
    self.frameEnd = TILE_SET_SPRITE_WIDTH * TILE_SET_SPRITE_HEIGHT
    self.currentFrame = self.frameStart - 1
    self.currentAnimationTime = 0
    self.swtichAnimationTime = 0.2


end
function Exit:update(dt) 

    if self.obstructed then
        local i = math.floor(self.hitbox.centeredY/TILE_SIZE) + 1
        local j = math.floor(self.hitbox.centeredX/TILE_SIZE) + 1

        -- Check if tile was turned into EMPTYSPACE
        if self.tiles[i][j].id == self.tPattern[EMPTYSPACE_TILE] then
            -- No longer obstructed
            self.obstructed = false
        end
    elseif not self.activated then
        -- Check if all entities are dead.
            if #self.entities == 0 then
                -- Set animation to change (TURN ON)
                Timer.every(0.1, function () 
                    self.currentAnimationTime = self.currentAnimationTime + 0.1
                end)

                gSounds['exitTurnsOn']:play()
                -- Now is activated
                self.activated = true
            end
    elseif self.activated then
        -- Once activated, keep Exit tile's animation running
        if self.currentAnimationTime > self.swtichAnimationTime then
            if self.currentFrame + 1 > self.frameEnd then
                self.currentFrame = self.frameStart
            else
                self.currentFrame = self.currentFrame + 1
            end
            self.currentAnimationTime = 0
        end
        -- Check if player collided with the exit.
        if #self.entities == 0 and self.hitbox:aabb(self.player) then
            self.usedByPlayer = true
        end
    end
end
function Exit:render() 
    -- Only draw our special tile if it's no obstructed.
    if not self.obstructed then
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.currentFrame],
            math.floor(self.x), math.floor(self.y))
    end

--    DEBUG -- show exit's hit box in the map
--    else
--        love.graphics.setColor(0, 0, 255, 255)
--        love.graphics.rectangle('line', self.x, self.y, TILE_SIZE, TILE_SIZE)
--        love.graphics.setColor(255, 255, 255, 255)
--    end
end