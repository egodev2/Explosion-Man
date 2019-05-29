LevelGenerator = Class{}

function LevelGenerator.create(params)

    -- Get passed parameters
    local levelNumber = params.levelNumber
    local player = params.player
    local score = params.score

    -- Create tables that will store the level's pattern.
    local tPattern,cPattern = LevelGenerator.setTilePattern()

    return LevelGenerator.createLevel(levelNumber,player,score,tPattern,cPattern)
end

-- Function to chosse level's tile and hud color patterns
function LevelGenerator.setTilePattern()

    local tilePatternConfig = {}
    local ColorPattern = {}

    -- Randomly choose tile pattern. We exclude the last line
    -- because it's reserved for exit tile.
    local y = math.random(1,TILE_SET_SPRITE_HEIGHT - 1)

    -- Calculate in which frame the pattern starts.
    local patternStart = ((y - 1) * TILE_SET_SPRITE_WIDTH) + 1

    -- Set our tilePattern shortcuts.
    tilePatternConfig = {
        [EMPTYSPACE_TILE] = patternStart,
        [DESTRUCTABLE_TILE] = patternStart + 1,
        [NONDESTRUCTABLE_TILE] = patternStart + 2,
        [DESTRUCTABLE_EXPLOSION_FRAMES] = patternStart + 3
    }

    -- Set our color pattern shorcuts. Will take the first one in case
    -- there is no specification in constants.
    ColorPattern = {
        [BACKGROUND] = BACKGROUND_LEVEL_COLOR[y] or BACKGROUND_LEVEL_COLOR[1],
        [BOX] = BOX_BACKGROUND_LEVEL_COLOR[y] or BOX_BACKGROUND_LEVEL_COLOR[1],
        [NUMBER] = NUMBER_LEVEL_COLOR[y] or NUMBER_LEVEL_COLOR[1],
        [OUTER_BORDER] = OUTER_BORDER_LEVEL_COLOR[y] or OUTER_BORDER_LEVEL_COLOR[1],
        [INNER_BORDER] = INNER_BORDER_LEVEL_COLOR[y] or INNER_BORDER_LEVEL_COLOR[1],
        [INFO] = INFO_LEVEL_COLOR[y] or INFO_LEVEL_COLOR[1]
    }

    return tilePatternConfig,ColorPattern
end

function LevelGenerator.createLevel(levelNumber,player,score,tPattern,cPattern,difficulty,ATCO)

    local tiles = {}
    local entities = {}
    local objects = {}

    -- Build a map with tile representation
    tiles = LevelGenerator.generateTileIdRepresentation()

    -- Generate Map's walls (Unpassable Border)
    LevelGenerator.generateWalls(tiles,tPattern)

    -- Considering we only generate a square..
    local tDestructableCandidatesPosition = LevelGenerator.setAreaInsideWalls(tPattern,tiles)
    
    -- Set Map Options
    local numberOfPockets, minPocketLenght, minEntityNumber = LevelGenerator.setAfterTileCreationOptions(ATCO)

    -- Generate pockets of empty space
    local tPocketsSpawnPosition = LevelGenerator.generateEmptySpacePockets(tDestructableCandidatesPosition,
        numberOfPockets,minPocketLenght,tiles,tPattern)

     -- Set player's position
    LevelGenerator.setPlayerPosition(tPocketsSpawnPosition, player)

    -- Set in which tile to spawn the exit
    local exitPosition = tDestructableCandidatesPosition[math.random(1,#tDestructableCandidatesPosition)]
    local eJ, eI = exitPosition%MAX_MAP_COLUMN + 1, math.floor(exitPosition/MAX_MAP_COLUMN) + 1
    local exit = LevelGenerator.generateExitTile((eJ - 1) * TILE_SIZE,(eI - 1) * TILE_SIZE,tiles,entities,tPattern,player)

    -- Fill with entities.
    LevelGenerator.generateEntities(minEntityNumber, tPocketsSpawnPosition, entities, tiles, objects, tPattern)

    -- Tweak on difficult
    local timer = LevelGenerator.setGameplayOptions(entities,difficulty)

    -- With all parameters in hand, return our created Level.
    return Level {
        number = levelNumber,
        timer = 500,
        cPattern = cPattern,
        map = Map {
            tiles = tiles,
            entities = entities,
            objects = objects,
            player = player,
            tPattern = tPattern,
            score = score,
            exit = exit,
        },
    }

end

function LevelGenerator.generateTileIdRepresentation()

    local tiles = {}

    for y = 1, MAX_MAP_LINE do
        table.insert(tiles, {})
        for x = 1, MAX_MAP_COLUMN do
            -- Each tile will hold and id, texture, and a possible hitbox
            table.insert(tiles[y], {
                id = -1,
                texture = 'tiles',
                hitbox = nil
            })
        end
    end

    return tiles
end

function LevelGenerator.generateWalls(tiles,tPattern)
    -- TRADITIONAL SQUARE
    -- Generate Walls on lines 2, MAX_MAP_LINES -1 and in columns 1, MAX_MAP_COLUMN - 1
    LevelGenerator.fillLine(2,1,MAX_MAP_COLUMN, tPattern[NONDESTRUCTABLE_TILE], nil, tiles)
    LevelGenerator.fillLine(MAX_MAP_LINE, 1, MAX_MAP_COLUMN, tPattern[NONDESTRUCTABLE_TILE], nil, tiles)
    LevelGenerator.fillColumn(1, 2, MAX_MAP_LINE, tPattern[NONDESTRUCTABLE_TILE], nil, tiles)
    LevelGenerator.fillColumn(MAX_MAP_COLUMN, 1, MAX_MAP_LINE, tPattern[NONDESTRUCTABLE_TILE], nil, tiles)
end

function LevelGenerator.fillLine(y,min,max,id,tPosition,tiles)
    for x = min, max do 
        tiles[y][x].id = id
        -- Save DESTRUCTABLE TILES if we are populating the map with them.
        if tPosition then
            table.insert(tPosition, (x - 1) + (y - 1) * (MAX_MAP_COLUMN))
        end
        -- Not an empty space -> Need a hitbox.
        if id ~= EMPTYSPACE_TILE then
            tiles[y][x].hitbox = Hitbox {
                x = (x - 1) * TILE_SIZE ,
                y = (y - 1) * TILE_SIZE ,
                width = TILE_SIZE,
                height = TILE_SIZE,
                texture = tiles[y][x].texture, 
            }
        end
    end
end

function LevelGenerator.fillColumn(x,min,max,id,tPosition,tiles)
    for y = min, max do
        tiles[y][x].id = id
        -- Save DESTRUCTABLE TILES if we are populating the map with them.
        if tPosition then
            table.insert(tPosition, (x - 1) + (y - 1) * (MAX_MAP_COLUMN))
        end
        -- Not an empty space -> Need a hitbox.
        if id ~= EMPTYSPACE_TILE then
            tiles[y][x].hitbox = Hitbox {
                x = (x - 1) * TILE_SIZE ,
                y = (y - 1) * TILE_SIZE ,
                width = TILE_SIZE,
                height = TILE_SIZE,
                texture = tiles[y][x].texture, 
            }
        end            
    end
end

function LevelGenerator.fillLineAlterante(y,min,max,Did,NDid,ptable,tiles)
    for x = min, max do
        if(x%2 == 0) then
            tiles[y][x].id = Did
            -- Save DESTRUCTABLE TILES if we are populating the map with them.
            if ptable then
                table.insert(ptable, (x - 1) + (y - 1) * (MAX_MAP_COLUMN))
            end
        else
            tiles[y][x].id = NDid
        end
    
        tiles[y][x].hitbox = Hitbox {
            x = (x - 1) * TILE_SIZE ,
            y = (y - 1) * TILE_SIZE ,
            width = TILE_SIZE,
            height = TILE_SIZE,
            texture = tiles[y][x].texture, 
        }
    end
end

function LevelGenerator.setAreaInsideWalls(tPattern,tiles)


    -- Table to save DESTRUCTABLE tiles
    local tDestructableTilesPos = {}

    -- Inside Limits
    local xMin, xMax = 2, MAX_MAP_COLUMN - 1
    local yMin, yMax = 3, MAX_MAP_LINE - 1

    -- Switching between filling a line with destructables and alternating between a destructable and a non destructable
    for y = yMin, yMax do
        if(y%2 == 1) then
            LevelGenerator.fillLine(y,xMin,xMax,tPattern[DESTRUCTABLE_TILE],tDestructableTilesPos,tiles)
        else
            LevelGenerator.fillLineAlterante(y,xMin,xMax,tPattern[DESTRUCTABLE_TILE],
            tPattern[NONDESTRUCTABLE_TILE],
            tDestructableTilesPos,
            tiles)
        end
    end

    return tDestructableTilesPos
end

function LevelGenerator.setAfterTileCreationOptions(ATCO) 

    -- I didn't plan to tweak the game based on player's choice, but here is the function 
    -- where it could be implemented map generation changes.
    local minNumberOfPockets, maxNumberOfPockets = 8,10

    return 6, math.random(8,10), math.random(math.floor(minNumberOfPockets/2),maxNumberOfPockets)
end

function LevelGenerator.generateEmptySpacePockets(tDestructablePositionCandidates,npockets,minPocketLenght,tiles,tPattern)

    local tSx = {}
    local tSy = {}

    -- Table to save pocket spawn positions.
    local tpocketsSpawnPosition = {}

    -- Optimization: we don't need to check for validation at the first pocket since there is no pocket to overlap.
    local i = math.random(1,#tDestructablePositionCandidates)
    local seed = tDestructablePositionCandidates[i]
    local sX, sY = (seed%MAX_MAP_COLUMN) + 1, math.floor(seed/MAX_MAP_COLUMN) + 1

    -- Keep track of all positions changed to EMPTY SPACE because they become invalid for creating new pockets.
    local tinvalidSeeds = {}

    -- Create one pocket, and remove the positions that were changed
    -- Optimization: we don't need to check for validation at the first pocket since there is no pocket to overlap.
    tinvalidSeeds = LevelGenerator.createPocket(sX,sY,minPocketLenght,tiles,tPattern)
    LevelGenerator.updateSeeds(tDestructablePositionCandidates,tinvalidSeeds)

    -- BUG
    for i = 2, npockets do 
        -- Choose one position to spawn our pocket
        i = math.random(1,#tDestructablePositionCandidates)
        seed = tDestructablePositionCandidates[i]

        sX, sY = (seed%MAX_MAP_COLUMN) + 1, math.floor(seed/MAX_MAP_COLUMN) + 1

        -- Try to create a pocket in a given seed,
        -- BUG: SOME INVALID SEEDS ARE BEING ACCEPTED.
        if(LevelGenerator.CheckForValidPocket(sX,sY,minPocketLenght,tiles,tPattern)) then
            -- Create a pocket, saving a list of positions that can't be used as seed anymore.
            tinvalidSeeds = LevelGenerator.createPocket(sX,sY,minPocketLenght,tiles,tPattern)

            -- Save seed positions, to be used for entity generation
            table.insert(tpocketsSpawnPosition, (sX - 1) + (sY - 1) * (MAX_MAP_COLUMN))

            -- Update our possible seeds.
            local i = 0

            LevelGenerator.updateSeeds(tDestructablePositionCandidates,tinvalidSeeds)
        else
            -- If it wasn't possible to check for a valid pocket, then we just remove prom our candidate table.
            table.remove(tDestructablePositionCandidates,i)
        end
    end

    return tpocketsSpawnPosition
end

function LevelGenerator.CheckForValidPocket(sX,sY,minPocketLenght,tiles,tPattern)

    -- Size of our pocket, only have the actual seed
    local tilecount = 1

    -- Table that will contain (x,y) to check initialized with pocket seed
    local tileToCheck = {sX, sY}  
    local tExploredTiles = {}

    -- Find and register pocket tiles until we have enough or there is no more possible tiles to check
    while tilecount < minPocketLenght and #tileToCheck > 0 do
        local x,y = tileToCheck[1],tileToCheck[2]

        -- Check all sides sides: Up, Right, Down, Left for destructable tiles avoiding repetition.
        -- No actual changes are made in tile map.
        if y >= 2 and tiles[y-1][x].id == tPattern[DESTRUCTABLE_TILE] and not LevelGenerator.WasAlreadyCounted(x,y-1,tExploredTiles) then
            table.insert(tileToCheck,x)
            table.insert(tileToCheck,y-1)
            tilecount = tilecount + 1
        end
        if x <= MAX_MAP_COLUMN - 1 and tiles[y][x+1].id == tPattern[DESTRUCTABLE_TILE] and not LevelGenerator.WasAlreadyCounted(x+1,y,tExploredTiles) then
            table.insert(tileToCheck,x+1)
            table.insert(tileToCheck,y)
            tilecount = tilecount + 1
        end
        if y <= MAX_MAP_LINE - 1 and tiles[y+1][x].id == tPattern[DESTRUCTABLE_TILE] and not LevelGenerator.WasAlreadyCounted(x,y+1,tExploredTiles) then
            table.insert(tileToCheck,x)
            table.insert(tileToCheck,y+1)
            tilecount = tilecount + 1
        end
        if x >= 2 and tiles[y][x-1].id == tPattern[DESTRUCTABLE_TILE] and not LevelGenerator.WasAlreadyCounted(x-1,y,tExploredTiles) then
            table.insert(tileToCheck,x-1)
            table.insert(tileToCheck,y)
            tilecount = tilecount + 1
        end

        -- Remove from tile to check and insert as an explored.
        table.remove(tileToCheck,1)
        table.remove(tileToCheck,1)
        table.insert(tExploredTiles,x)
        table.insert(tExploredTiles,y)
    end

    -- If we had enough tiles then its a valid pocket.
    if tilecount >= minPocketLenght then
        return true
    end

    return false
end

function LevelGenerator.WasAlreadyCounted(X,Y,tExploredTiles)

    local i = 2

    -- Check each pair (x,y) exaustively for no repetition.
    while(i <= #tExploredTiles) do 
        if tExploredTiles[i-1] == X and tExploredTiles[i] == Y then
            -- If a match (repitition) happens, return.
            return true
        end
        i = i + 2
    end


    return false
end

function LevelGenerator.createPocket(X,Y,minPocketLenght,tiles,tPattern)

    local pocketSize = 0

    -- Set the seed position as an empty space
    tiles[Y][X].id = tPattern[EMPTYSPACE_TILE]

    -- Keep track of all positions changed to EMPTY SPACE because they become invalid for creating new pockets.
    local tpocketInvalidSeeds = {}

    -- Initialization
    local tilesToExploreX = {X}
    local tilesToExploreY = {Y}

    -- Try to extend the pocket. At worst case, we will have an a pocket with size "minPocketLenght"
    while(LevelGenerator.extendPocket(pocketSize,minPocketLenght,#tilesToExploreX)) do
        -- Choose one candidate. First iteration will always be a pocket seed.
        local i = math.random(1,#tilesToExploreX)
        local currentX, currentY = tilesToExploreX[i], tilesToExploreY[i]
        
        -- Check neighboors: up, right, down, left to explore.
        if tiles[currentY - 1][currentX].id == tPattern[DESTRUCTABLE_TILE] then 
            table.insert(tilesToExploreX, currentX)
            table.insert(tilesToExploreY, currentY - 1) 
        end
        if tiles[currentY][currentX + 1].id == tPattern[DESTRUCTABLE_TILE] then 
            table.insert(tilesToExploreX, currentX + 1)
            table.insert(tilesToExploreY, currentY) 
        end
        if tiles[currentY + 1][currentX].id == tPattern[DESTRUCTABLE_TILE] then 
            table.insert(tilesToExploreX, currentX)
            table.insert(tilesToExploreY, currentY + 1) 
        end
        if tiles[currentY][currentX - 1].id == tPattern[DESTRUCTABLE_TILE] then 
            table.insert(tilesToExploreX, currentX - 1)
            table.insert(tilesToExploreY, currentY)
        end  

        -- Transform actual tile into an empty space, killing it's hitbox.
        tiles[currentY][currentX].id = tPattern[EMPTYSPACE_TILE]
        tiles[currentY][currentX].hitbox = nil

        -- Increment size for pocket
        pocketSize = pocketSize + 1

        -- Save this position as invalid seed for future calls to create new pockets 
        -- and remove it from possible to exploration.
        table.insert(tpocketInvalidSeeds, (currentX - 1) + (currentY - 1) * (MAX_MAP_COLUMN))
        table.remove(tilesToExploreX,i)
        table.remove(tilesToExploreY,i)
    end
    -- Return the table invalid seeds produced in this pocket creation

    return tpocketInvalidSeeds
end

function LevelGenerator.updateSeeds(tSeeds,tInvalidSeeds)


    -- Remove DESCTRUCTABLE positions that have been used due to a pocket's creation and are no longer
    -- usable for a seed.
    for k, seed in pairs (tInvalidSeeds) do
        for i = 1, #tSeeds do
            if(seed == tSeeds[i]) then
                table.remove(tSeeds,i)
                break
            end
        end
    end
end

function LevelGenerator.extendPocket(pocketSize,minPocketLenght,tilesLeft)

    -- always extend if didn't generate the min lenght. Remember we that checked for a minimum size first,
    -- so a pocket with minium lenght is garanted.
    if pocketSize < minPocketLenght then
        return true
    else 
        -- Try to extend: the chances get lower (limit at 30%) as the pocket gets bigger, though it's 0 if there
        -- is no more explorable tiles.
        if tilesLeft > 0 and math.random(1,100) <= 100 - math.max((pocketSize - minPocketLenght) * 10, 30) then
            return true
        end
    end

    return false
end

function LevelGenerator.setPlayerPosition(tPocketsSpawnPosition, player)

    -- Choose one pocket source for player's position.
    local p = math.random(1,#tPocketsSpawnPosition)

    -- Transform to apropriate coordinates
    player.x = tPocketsSpawnPosition[p]%MAX_MAP_COLUMN * TILE_SIZE
    player.y = math.floor(tPocketsSpawnPosition[p]/MAX_MAP_COLUMN) * TILE_SIZE

    -- Create it's hitbox.
    player.hitbox = Hitbox({
        x = player.x,
        y = player.y,
        
        width = player.width,
        height = player.height/2,
        entity = player
    })

    -- Finally, remove the choosen seed.
    table.remove(tPocketsSpawnPosition,p)
end

function LevelGenerator.generateEntities(minEntityNumber, tPocketsSpawnPosition, entities, tiles, objects, tPattern) 

    -- We already have the player
    local totalEntity = 1

    -- Generating a minimum number o monsters, using pocket seeds as spawn.
    while(#tPocketsSpawnPosition > 0) do
        -- Choose a pocket spawn position
        local i = math.random(1,#tPocketsSpawnPosition)

        -- Try to spawn an entity. Will always do if we don't have the minimum.
        if LevelGenerator.SpawnEntity(totalEntity,minEntityNumber) then

            -- Roll a monster fro mthe entity list
            local k = math.random(1,#ENTITY_LIST)
            local entity = ENTITY_LIST[k]

            -- Create our monster
            table.insert(entities, Entity {
                HP = ENTITY_DEFS[entity].HP,
                speed = ENTITY_DEFS[entity].speed,
                animations = ENTITY_DEFS[entity].animations,
                flying = ENTITY_DEFS[entity].flying,
                maxHP = ENTITY_DEFS[entity].maxHP,
                
                -- Position related
                x = (tPocketsSpawnPosition[i]%MAX_MAP_COLUMN) * TILE_SIZE,
                y = math.floor(tPocketsSpawnPosition[i]/MAX_MAP_COLUMN) * TILE_SIZE,
                width = 16,
                height = 16,
            })

            -- Add to our total number of entities
            totalEntity = totalEntity + 1
        end
        table.remove(tPocketsSpawnPosition,i)
    end

    -- Set State Machine for each Entity.
    for k, entity in pairs(entities) do 

        -- Only one Possible state, the are always moving.
        -- Even though there is only one, helps with flexibility in case adding more.
        entities[k].stateMachine = StateMachine {
           ['walk'] = function() return WalkingState(entities[k], tiles, objects, tPattern) end
         }

        -- Change to the only state.
        entities[k]:changeState('walk')

        -- Create it's hitbox
        entities[k].hitbox = Hitbox {
            x = entities[k].x,
            y = entities[k].y,
            width = entities[k].width,
            height = entities[k].height,
            entity = entities[k]
        }
    end
end

function LevelGenerator.SpawnEntity(totalEntity,minEntityNumber)

    -- If we didn't reach the minimum number, set to create a new entity.
    if totalEntity < minEntityNumber then
        return true
    else
        -- If we reached minimum number, we try to create more. The more entities we have, the smaller the
        -- probability gets with a minimum of 30%
        if math.random(1,100) <= 100 - math.max((totalEntity - minEntityNumber) * 15, 30) then
            return true
        end
    end

    return false
end

function LevelGenerator.generateExitTile(eX, eY, tiles, entities, tPattern, player)
    -- Create Our "Exit" which is a special tile.
    return Exit {
        x = eX,
        y = eY,
        tiles = tiles,
        entities = entities,
        tPattern = tPattern,
        player = player
    }
end

function LevelGenerator.setGameplayOptions(entities, difficulty)

    -- I didn't plan to tweak the game based on player's choice, but here is the function 
    -- where it could be implemented gameplay changes. For now, it only returns the default 
    -- time of the level.

    return 500
end
