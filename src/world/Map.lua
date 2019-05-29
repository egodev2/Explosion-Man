Map = Class{}

function Map:init(params)

    -- Get player, tile pattern and score from passed parameters.
    self.tiles = params.tiles
    self.entities = params.entities
    self.objects = params.objects
    self.player = params.player
    self.tPattern = params.tPattern
    self.score = params.score
    self.exit = params.exit

    -- Positions (x,y) save from dead entities to manipulater their scores.
    self.tDeadEntititiesCycleToInclude = {}

    -- Used to keep track of poped scores from entities on screen
    self.tDeadEntititiesCycle = {}

    -- How many hits took to kill necessary will work as a score multiplayer when you kill an entity
    self.tHPmultiplier = {}

    -- Number of dead entities. Used together with blast count to get multiple deaths.
    self.deadCount = 0

    -- A counter used as "Lock" to get multiple mobs deaths.
    self.blastCount = 0
end

function Map:DestroyTile(j,i)

    -- Get Tiles's destruction 1st animation frames
    self.tiles[i][j].id = self.tPattern[DESTRUCTABLE_EXPLOSION_FRAMES]

    -- Cycle through the the rest of animations (4 in total)
    Timer.every(BLOCK_DESTRUCTION_TOTAL_TIME/4, function() self.tiles[i][j].id = self.tiles[i][j].id  + 1  end):limit(3):
    finish(function() 
        -- Set as Empty Space
        self.tiles[i][j].id = self.tPattern[EMPTYSPACE_TILE]
        -- Try to spawn a power up
        self:SpawnPowerUp(self.tiles[i][j].hitbox.x,self.tiles[i][j].hitbox.y, POWERUP_NONDESTRUCTABLE_CHANCE)
        -- Delete it's hitbox
        self.tiles[i][j].hitbox = nil
    end)
end

function Map:isThereBomb(Ti, Tj)
    
    -- Straight foward. Try to find a bomb in a given line and colmun of our map.
    for k, object in pairs(self.objects) do
        if object.solid and math.floor(object.x/TILE_SIZE) + 1 == Tj and math.floor(object.y/TILE_SIZE) + 1 == Ti then
            return true
        end
    end
    
    return false
end

function Map:SpawnPowerUp(x,y,chanceToSpawn)

    -- Try to spawn a powerup with a "chanceToSpawn"percentage
    if math.random(1,100) <= chanceToSpawn then
        -- If sucessfull, 1/2 chance to spawn each power up.
        if math.random(1,100) <= 50 then
            table.insert(self.objects, GameObject {
                x = x,
                y = y,
                width = TILE_SIZE,
                height = TILE_SIZE,
                texture = 'objects',
                type = OBJECT_DEFS['power-up-fire'].type,
                consumable = OBJECT_DEFS['power-up-fire'].consumable,
                animations = OBJECT_DEFS['power-up-fire'].animations,
                onConsume = OBJECT_DEFS['power-up-fire'].onConsume
            })
        else
            table.insert(self.objects, GameObject {
                x = x,
                y = y,
                width = TILE_SIZE,
                height = TILE_SIZE,
                texture = 'objects',
                type = OBJECT_DEFS['power-up-bomb'].type,
                consumable = OBJECT_DEFS['power-up-bomb'].consumable,
                animations = OBJECT_DEFS['power-up-bomb'].animations,
                onConsume = OBJECT_DEFS['power-up-bomb'].onConsume
            })
        end
    end

end

function Map:update(dt)
    
    -- Update our entities
    for k, entity in pairs(self.entities) do
        if entity.dead then
            -- We save the dead entity positions to later display points value at proper position.
            table.insert(self.tDeadEntititiesCycleToInclude, entity.x)
            table.insert(self.tDeadEntititiesCycleToInclude, entity.y)
            
            -- Save its max HP because influences score's value.
            table.insert(self.tHPmultiplier, entity.maxHP)

            -- Remove entity from our entity table.
            table.remove(self.entities, k)
        else
            entity:update(dt)
            entity.stateMachine:processAI(dt)
        end
    end

    -- Update our objects (Flame is NOT included)
    for k, object in pairs(self.objects) do
        object:update(dt)

        -- Check if a blast triggered a bomb to explode (a hitbox tile WITH flame collided with bomb)
        if object.solid and not object.explode then
            local collidedIndex, texture = object.hitbox[1]:collisionCheck(nil, self.objects)
            if texture == 'objects' and self.objects[collidedIndex].blast then

                local Ei = math.floor(object.y/TILE_SIZE) + 1
                local Ej = math.floor(object.x/TILE_SIZE) + 1

                -- Need to check if there is a flame drawn.
                if self.objects[collidedIndex].hitbox[HORIZONTALH]:isThereFlame(Ei,Ej) or 
                self.objects[collidedIndex].hitbox[VERTICALH]:isThereFlame(Ei,Ej) then
                    -- Set to explode, regardless of bomb's time.
                    object.explode = true
                end
            end
        end

        -- Check if a bomb was set to explode, and create the blast if positive.
        if object.solid and object.explode then
            -- Save Bomb's position for blast's source
            local x = object.x
            local y = object.y

            gSounds['explosionBomb']:play()

            -- Create the blast
            self.objects[k] = GameObject {
                x = x,
                y = y,
                texture = OBJECT_DEFS['blast'].texture,
                animations = OBJECT_DEFS['blast'].animations,
                nhitboxes = 2,
                power = self.player.power,
                tiles = self.tiles,
                tPattern = self.tPattern,
                timer = BLAST_TOTAL_TIME
            }

            -- Update player's number of placed bombs
            self.player.actualBombs = self.player.actualBombs - 1

            -- Destroy tiles that were set to destroy on blast creation in horizontal
            for pos = 1, #self.objects[k].hitbox[HORIZONTALH].tblocksToDestroy, 2 do
                local j = self.objects[k].hitbox[HORIZONTALH].tblocksToDestroy[pos]
                local i = self.objects[k].hitbox[HORIZONTALH].tblocksToDestroy[pos+1]
                self:DestroyTile(j,i)
            end
    
            -- Destroy tiles that were set to destroy on blast creation in Vertical
            for pos = 1, #self.objects[k].hitbox[VERTICALH].tblocksToDestroy, 2 do
                local j = self.objects[k].hitbox[VERTICALH].tblocksToDestroy[pos]
                local i = self.objects[k].hitbox[VERTICALH].tblocksToDestroy[pos+1]
                self:DestroyTile(j,i)
            end

            -- "Lock" to get multiple entities deaths
            self.blastCount = self.blastCount + 1
        end
    end

    -- To reset our the counter of multiple entities deaths, we see if there is no more blasts in the map (unlocked).
    if self.blastCount == 0 then
        self.deadCount = 0
    end

    -- Check if there dead entity(ies) to increment our score.
    if #self.tDeadEntititiesCycleToInclude > 0 then

        -- Acess to each entity multiplier 
        local multiplierIndex = 1
        -- Each dead entity has a pair of position.
        for k = 1, #self.tDeadEntititiesCycleToInclude, 2 do 
            -- Include to our dead count
            self.deadCount = self.deadCount + 1

            -- Score is calculated based on death count until we have no active blasts,
            -- entity's max HP and a base of 500. NOTICE: The killing order DOES changes 
            -- the score of each mob, if they have different HPs.
            local eScore = (self.deadCount) * 500 * self.tHPmultiplier[multiplierIndex]

            -- Create a Pop-Up the score where the entity died to inform player
            table.insert(self.tDeadEntititiesCycle, ScorePopUp {
                x = self.tDeadEntititiesCycleToInclude[k],
                y = self.tDeadEntititiesCycleToInclude[k+1],
                score = eScore
            })

            -- Add total score the entity's calculated score.
            self.score = self.score + eScore

            -- Try To Spawn a power-up. Killing a Entity has a good chance of spawning one.
            self:SpawnPowerUp(self.tDeadEntititiesCycleToInclude[k],self.tDeadEntititiesCycleToInclude[k+1], POWERUP_MONSTER_DEATH_CHANCE)

            -- Go to the next mob's maxHP.
            multiplierIndex = multiplierIndex + 1
        end

        -- Table clearing, since we have included all dead entities and we are
        -- done with calculations and other desirable commands.
        self.tDeadEntititiesCycleToInclude = {}
        self.tHPmultiplier = {}
    end

    -- Update our delete  the score shown next to a dead entity.
    if #self.tDeadEntititiesCycle > 0 then
        for k, scorePopUp in pairs(self.tDeadEntititiesCycle) do
            if scorePopUp.delete then
                table.remove(self.tDeadEntititiesCycle,k)
            else 
                scorePopUp:update()
            end
        end
    end
    
    -- Update Exit Tile
    self.exit:update(dt)

    -- Update Player
    self.player:update(dt)
end

function Map:render()
    -- Draw tiles
    for y = 2, MAX_MAP_LINE do
        for x = 1, MAX_MAP_COLUMN do
            local tile = self.tiles[y][x]
                love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE,
                (y - 1) * TILE_SIZE)   
        end
    end

    -- Draw exit
    self.exit:render()

    -- Draw objects
    for k, object in pairs(self.objects) do
        if object.inPlay then
            object:render()
        else
            if object.blast then
                self.blastCount = self.blastCount - 1
            end
            table.remove(self.objects,k)
        end
    end

    -- Draw Entities
    for k, entity in pairs(self.entities) do
        if not dead then
            entity:render()
        end
    end

    for k, scorePopUp in pairs(self.tDeadEntititiesCycle) do
        scorePopUp:render()
    end

    -- Draw Player
    self.player:render()
end