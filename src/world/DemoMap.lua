DemoMap = Class{__include = Map}

function DemoMap:init() 

    -- Simplified version of a real map, only contains tiles and doesn't
    -- generate pockets and entities. Instead, will chosse from EMPTYSPACE
    -- or DESTRUCTABLE at random when filling lines and alternate. Used
    -- to display in the background on title screen.

    self.tPattern, self.cPattern = LevelGenerator.setTilePattern()
    
    self.tiles = {}
    self:generateTileIdRepresentation()

    for i = 1, MAX_MAP_LINE do
        if(i%2 == 1) then
            self:fillLine(i,1,MAX_MAP_COLUMN)
        else
            self:fillLineAlterante(i,1,MAX_MAP_COLUMN)
        end
    end
end

function DemoMap:generateTileIdRepresentation()

    for y = 1, MAX_MAP_LINE do
        table.insert(self.tiles, {})
        for x = 1, MAX_MAP_COLUMN do
            table.insert(self.tiles[y], {
                id = -1,
                texture = 'tiles',
            })
        end
    end
end

function DemoMap:fillLine(y,min,max)
    for x = min, max do 
        if math.random(1,100) <= 50 then
            self.tiles[y][x].id = self.tPattern[EMPTYSPACE_TILE]
        else
            self.tiles[y][x].id = self.tPattern[DESTRUCTABLE_TILE]
        end
    end
end

function DemoMap:fillLineAlterante(y,min,max)
    for x = min, max do
        if(x%2 == 0) then
            if math.random(1,100) <= 50 then
                self.tiles[y][x].id = self.tPattern[EMPTYSPACE_TILE]
            else
                self.tiles[y][x].id = self.tPattern[DESTRUCTABLE_TILE]
            end
        else
            self.tiles[y][x].id = self.tPattern[NONDESTRUCTABLE_TILE]
        end
    end
end

function DemoMap:update() 

end

function DemoMap:render()
    -- Draw tiles
    for y = 1, MAX_MAP_LINE do
        for x = 1, MAX_MAP_COLUMN do
            local tile = self.tiles[y][x]
                love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE,
                (y - 1) * TILE_SIZE)   
        end
    end
end