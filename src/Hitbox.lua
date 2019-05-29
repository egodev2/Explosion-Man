Hitbox = Class{}

function Hitbox:init(def) 

    self.x = def.x 
    self.y = def.y 
    self.width = def.width or TILE_SIZE
    self.height = def.height or TILE_SIZE
    self.power = def.power

    -- Positions used to read correct tiles, given a direction.
    self.centeredX = self.x + self.width/2
    self.centeredY = self.y + self.height/2

    self.texture = def.texture 
    self.entity = def.entity or nil

    -- Blast especific.
    if self.width > TILE_SIZE or self.height > TILE_SIZE then

        -- Needed parameters
        self.tiles = def.tiles
        self.tPattern = def.tPattern

        -- Direction, finalTile and endTile of a blast's HITBOX.
        self.dir = ''
        self.fTile = -1
        self.eTile = -1

        -- Set which flames to draw and which blocks to destroy.
        -- The flame -> MAY <- be the same size of the blast's hitbox
        self.tFlamesToDrawn, self.tblocksToDestroy = self:getDrawableFireTiles()

        -- Create our Flames, to be update in the map.
        self.flames = self:createFlames()
    else
        -- If it's not a blast, this is set to empty.
        self.flames = {}
    end

    -- DEBUG ONLY - To actually see the hitbox, make sure to enable in render too.
    -- self.DEBUG = true
end

-- Standard aabb collision for entities.
function Hitbox:aabb(target)

    -- x1 < x2 + w2
    -- y1 < y2 + h2
    -- x2 < x1 + w1
    -- y2 < y1 + h1

    return self.x < target.hitbox.x + target.hitbox.width 
    and target.hitbox.x < self.x + self.width 
    and target.hitbox.y < self.y + self.height 
    and self.y < target.hitbox.y + target.hitbox.height 
end

-- Used for player. A more forgiving aabb collision.
function Hitbox:aabbPlayer(target)

     -- x1 < x2 + w2
    -- y1 < y2 + h2
    -- x2 < x1 + w1
    -- y2 < y1 + h1

    return self.x + PLAYER_HITBOX_OFFSET < target.hitbox.x + target.hitbox.width 
    and target.hitbox.x < self.x + self.width - PLAYER_HITBOX_OFFSET
    and target.hitbox.y + PLAYER_HITBOX_OFFSET < self.y + self.height - PLAYER_HITBOX_OFFSET
    and self.y + PLAYER_HITBOX_OFFSET < target.hitbox.y + target.hitbox.height 

end

-- Can be used for all objects which have one hitbox,
-- but since i used only for a bomb, i put the name on it.
function Hitbox:aabbBomb(target)

    return self.x < target.hitbox[1].x + target.hitbox[1].width 
    and target.hitbox[1].x < self.x + self.width 
    and target.hitbox[1].y < self.y + self.height 
    and self.y < target.hitbox[1].y + target.hitbox[1].height 

end

-- Collision with blasts for entities.
function Hitbox:aabbMultiple(target)

    -- x1 < x2 + w2
    -- y1 < y2 + h2
    -- x2 < x1 + w1
    -- y2 < y1 + h1

    for i = 1, target.nhitboxes do 
        if self.x < target.hitbox[i].x + target.hitbox[i].width 
        and target.hitbox[i].x < self.x + self.width 
        and target.hitbox[i].y  < self.y  + self.height 
        and self.y  < target.hitbox[i].y  + target.hitbox[i].height then
            return true
        end
    end

    return false
end

-- Collision with blasts for player, more forgiving.
function Hitbox:aabbMultiplePlayer(target)

    -- x1 < x2 + w2
    -- y1 < y2 + h2
    -- x2 < x1 + w1
    -- y2 < y1 + h1

    for i = 1, target.nhitboxes do 
        if self.x + PLAYER_HITBOX_OFFSET < target.hitbox[i].x + target.hitbox[i].width
        and target.hitbox[i].x < self.x + self.width - PLAYER_HITBOX_OFFSET
        and target.hitbox[i].y < self.y  + self.height - PLAYER_HITBOX_OFFSET
        and self.y + PLAYER_HITBOX_OFFSET < target.hitbox[i].y  + target.hitbox[i].height + PLAYER_HITBOX_OFFSET then
            return true
        end
    end

    return false
end

function Hitbox:getDrawableFireTiles()

    local tFire = {}
    local tblocksToDestroy = {}
    
    -- Get hitbox (x,y) line and column 
    local i = math.floor((self.y)/TILE_SIZE) + 1
    local j = math.floor((self.x)/TILE_SIZE) + 1

        -- HORIZONTAL
    if self.width > TILE_SIZE then
        -- Save first, source (fire), and last tile position
        local maxTile =  j + ((self.width)/TILE_SIZE) - 1
        local firstTile = j
        local sourceTile = math.floor((maxTile + firstTile)/2) 

        -- LEFT            
        for n = sourceTile - 1, firstTile, -1 do
             -- Look if a hitbox tile is inside the map before doing anything with it
            if (self:isInsideMap((n-1)*TILE_SIZE, (i- 1) * TILE_SIZE, 'Horizontal',f)) then
               -- Include as drawable fire if it's an empty space.
               if(self.tiles[i][n].id == self.tPattern[EMPTYSPACE_TILE]) then
                  table.insert(tFire,n)
                  table.insert(tFire,i)
                -- If it's a nondestructable, then we need to save that is set to destroy.
               else
                    if self.tiles[i][n].id == self.tPattern[DESTRUCTABLE_TILE] then
                        table.insert(tblocksToDestroy, n)
                        table.insert(tblocksToDestroy, i)
                    end

                    -- Since the fire don't go trough a non desctructable, we stop.
                    break
               end
            end
        end
        -- SOURCE
        table.insert(tFire,sourceTile)
        table.insert(tFire,i)
        -- RIGHT
        for n = sourceTile + 1, maxTile do
             -- Look if a hitbox tile is inside the map before doing anything with it
            if (self:isInsideMap((n-1)*TILE_SIZE, (i- 1) * TILE_SIZE, 'Horizontal',f)) then
                -- Include as drawable fire if it's an empty space.
                if(self.tiles[i][n].id == self.tPattern[EMPTYSPACE_TILE]) then
                    table.insert(tFire,n)
                    table.insert(tFire,i)
                -- If there is a nondestructable, then we need to save that is set to destroy.
                else
                    if self.tiles[i][n].id == self.tPattern[DESTRUCTABLE_TILE] then
                        table.insert(tblocksToDestroy, n)
                        table.insert(tblocksToDestroy, i)
                    end

                    -- Since the fire don't go trough a non desctructable, we stop.
                    break
                end
             end
        end

        -- Set the direction, and our "tips".
        self.dir = 'Horizontal'
        self.fTile = firstTile
        self.eTile = maxTile

    -- VERTICAL
    else
        -- Save first, source (fire), and last tile position
        local maxTile = i + ((self.height)/TILE_SIZE) - 1
        local firstTile = i
        local sourceTile = math.floor((maxTile + firstTile)/2)
        
        -- UP
        for n = sourceTile - 1, firstTile, -1 do
            -- Look if a hitbox tile is inside the map before doing anything with it
            if (self:isInsideMap((j-1)*TILE_SIZE, (n-1)*TILE_SIZE, 'Vertical',f)) then
               -- Include as drawable fire if it's an empty space.
               if(self.tiles[n][j].id == self.tPattern[EMPTYSPACE_TILE]) then
                 table.insert(tFire,j)
                 table.insert(tFire,n)
               else
                    if self.tiles[n][j].id == self.tPattern[DESTRUCTABLE_TILE] then
                        table.insert(tblocksToDestroy, j)
                        table.insert(tblocksToDestroy, n)
                    end

                    -- Since the fire don't go trough a non desctructable, we stop.
                    break
               end
            end
        end
        -- SOURCE: 
        -- No need to include again, it's common for both hitboxes.
            --table.insert(tFire,j)
            --table.insert(tFire,sourceTIle)
        -- DOWN
        for n = sourceTile + 1, maxTile do
            -- Look if a hitbox tile is inside the map before doing anything with it
            if (self:isInsideMap((j-1)*TILE_SIZE, (n-1)*TILE_SIZE, 'Vertical',f)) then
                -- Include as drawable fire if it's an empty space.
                if(self.tiles[n][j].id == self.tPattern[EMPTYSPACE_TILE]) then
                    table.insert(tFire,j)
                    table.insert(tFire,n)
                -- Include as drawable fire if it's an empty space.
                else
                    if self.tiles[n][j].id == self.tPattern[DESTRUCTABLE_TILE] then
                        table.insert(tblocksToDestroy, j)
                        table.insert(tblocksToDestroy, n)
                    end  
                    
                    -- Since the fire don't go trough a non desctructable, we stop.
                    break
                end
            end
        end

        -- Set the direction, and our "tips".
        self.dir = 'Vertical'
        self.fTile = firstTile
        self.eTile = maxTile
    end

    return tFire, tblocksToDestroy
end

function Hitbox:createFlames()

    local tFlames = {}
    local k = 1

    -- Before creating a new flame, we need determine values or flags
    -- to draw the sprite in its correct rotation and appropiate flame sprite frame.

    while k < #self.tFlamesToDrawn do  

        -- Is it the end of a flame?
        local tip = false

        -- Is the flame to be created the source position?
        local source = false

        -- Sprite rotation.
        local flip = 0
        
        if self.dir == 'Horizontal' then 
            -- First Tile == tip
            if self.tFlamesToDrawn[k] == self.fTile then
                tip = true
            -- End Tile == tip
            elseif self.tFlamesToDrawn[k] == self.eTile then 
                tip = true
                flip = 180
            elseif self.tFlamesToDrawn[k] == math.floor((self.fTile + self.eTile)/2) then
                source = true
            end
        else
            -- Vertical will always flip to at least 90
            -- First Tile == tip
            if self.tFlamesToDrawn[k+1] == self.fTile then
                tip = true
                flip = 90
            -- End Tile == tip
            elseif self.tFlamesToDrawn[k+1] == self.eTile then 
                tip = true
                flip = 270
            elseif self.tFlamesToDrawn[k+1] == math.floor((self.fTile + self.eTile)/2) then
                source = true
            else
                flip = 90
            end
        end

        -- Finally, create the flame.
        table.insert(tFlames, Flame {
            x = (self.tFlamesToDrawn[k] - 1) * TILE_SIZE,
            y = (self.tFlamesToDrawn[k+1] - 1) * TILE_SIZE,
            flip = flip,
            tip = tip,
            source = source,
            texture = 'objects'
        })
        k = k + 2
    end

    return tFlames
end

function Hitbox:isThereFlame(Ei, Ej)

    for k, flame in pairs (self.flames) do
        if math.floor(flame.x/TILE_SIZE) + 1 == Ej and math.floor(flame.y/TILE_SIZE) + 1 == Ei then
            return true
        end
    end

    return false
end

function Hitbox:bumpCheck(tiles, objects, tPattern) 

    -- Fist bump check function. Check every driection for a bump.

    -- Get tiles line and column
    local tileY = math.floor(self.centeredY/TILE_SIZE) + 1
    local tileX = math.floor(self.centeredX/TILE_SIZE) + 1

    -- Check bump in each direction.
    if self.entity.direction == 'up' and self:bumpTest(tiles,objects,tPattern,tileY-1,tileX) then
        return true
    elseif self.entity.direction == 'right' and self:bumpTest(tiles,objects,tPattern,tileY,tileX + 1) then
        return true
    elseif self.entity.direction == 'down' and  self:bumpTest(tiles,objects,tPattern,tileY+1,tileX) then
        return true
    elseif self.entity.direction == 'left' and  self:bumpTest(tiles,objects,tPattern,tileY,tileX-1) then
        return true
    end     

    return false
end

function Hitbox:bumpTest(tiles, objects, tPattern, i, j)

    -- Function used by both player and other entities. Detects bumps
    -- with solid tiles and objects.

    -- Check collision with every tile except EMPTYSPACE
    if tiles[i][j].id ~= tPattern[EMPTYSPACE_TILE] then
        return self:aabb(tiles[i][j])
    end

    -- Check collision with bombs that are present on map.
    for k, object in pairs(objects) do
        if object.solid and j == (math.floor(object.hitbox[1].centeredX/TILE_SIZE) + 1) and i == (math.floor(object.hitbox[1].centeredY/TILE_SIZE) + 1) then
            return self:aabbBomb(object)
        end
    end

    return false
end

function Hitbox:collisionCheck(entities, objects)

    -- Collision check with other entities and blasts, used by entities.

    -- Check collision with entities
    if entities then
        for k, entity in pairs(entities) do
            if(self:aabb(entity)) then
                return k, 'entities'
            end
        end
    end

    -- Check Objects... Blast has priority over power ups.
    for k, object in pairs(objects) do 
        if object.blast and self:aabbMultiple(object) then
            return k, 'objects'
        end
    end

    for k, object in pairs(objects) do 
        if object.consumable and self:aabbMultiple(object) then
            return k, 'objects'
        end
    end
    
    return -1, nil
end

function Hitbox:collisionCheckPlayer(entities, objects)

    -- Collision checking for player's hitbox. Need a separate function
    -- because of the more forgiving aabb collision for player.

    if entities then
        for k, entity in pairs(entities) do
            if(self:aabbPlayer(entity)) then
                return k, 'entities'
            end
        end
    end

    -- Check Objects... Blast has priority.
    for k, object in pairs(objects) do 
        if object.blast and self:aabbMultiplePlayer(object) then
            return k, 'objects'
        end
    end

    for k, object in pairs(objects) do 
        if object.consumable and self:aabbMultiplePlayer(object) then
            return k, 'objects'
        end
    end
    
    return -1, nil
end

function Hitbox:isInsideMap(X,Y,direction) 

    -- Function that checks if a given a direction, and (X,Y) position,
    -- see if its inside map (0,TILE_SIZE*MAX_MAP_COLUMN) in horizontal
    -- or (0,TILE_SIZE*MAX_MAP_LINE) in vertical.

    if direction == 'Horizontal' then
        local x = math.min(math.max(X, 0), TILE_SIZE * (MAX_MAP_COLUMN ))
        return x > 0 and x < VIRTUAL_WIDTH
    end

    local y = math.min(math.max(Y, TILE_SIZE * 1), TILE_SIZE * (MAX_MAP_LINE))
    return y > TILE_SIZE and y < VIRTUAL_HEIGHT
end

function Hitbox:update(dt) 

    -- If the hit box belongs to an entity
    if self.entity then
        self.x = self.entity.x 
        self.y = self.entity.y
        self.centeredX = self.x + self.width/2
        self.centeredY = self.y + self.height/2
    end
    
    -- Update drawn flames.
    if self.flames then
        for k, flame in pairs(self.flames) do
            flame:update(dt)
        end
    end
end

function Hitbox:render()
    
    for k, flame in pairs(self.flames) do
        flame:render()
    end
    -- DEBUG ONLY -- TO Actually see the hitbox, make sure to enable on init.

    --if self.DEBUG then
    --love.graphics.setColor(255, 0, 255, 255)
    --if self.entity then
    --    love.graphics.rectangle('line', self.x + PLAYER_HITBOX_OFFSET, self.y + PLAYER_HITBOX_OFFSET, self.width - 8, self.height - 8)
    --else
    --    if self.flames then
    --        love.graphics.setColor(0, 255, 255, 255)
    --    end
    --    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    --end
    --love.graphics.setColor(255, 255, 255, 255)
    --end
end