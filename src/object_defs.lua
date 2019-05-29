OBJECT_DEFS = {
    ['bomb'] = {
        texture = 'objects',
        solid = true,
        collidable = true,
        animations = {
            ['ticking'] = {
                frames = {7,8},
                interval = 2.5
            }
        }
    },
    ['power-up-bomb'] = {
        texture = 'objects',
        consumable = true,
        type = "bomb",
        nhitboxes = 1,
        animations = {
            ['bomb-flash'] = {
                frames = {9,10},
                interval = 0.125
            }
        },
        onConsume = function (player)
            if player.maxBombs < PLAYER_MAX_NUMBER_BOMBS then
                player.maxBombs = player.maxBombs + 1
            end
            return POWERUP_SCORE_VALUE
        end
    },
    ['power-up-fire'] = {
        texture = 'objects',
        consumable = true,
        type = "fire",
        nhitboxes = 1,
        animations = {
            ['fire-flash'] = {
                frames = {11,12},
                interval = 0.125
            }
        },
        onConsume = function (player)
            if player.maxBombs < PLAYER_MAX_POWER then 
                player.power = player.power + 1
            end
            return POWERUP_SCORE_VALUE
        end
    },
    ['blast'] = {
        texture = 'objects',
        animations = {
            ['source'] = {
                frames = {1,4,1},
                interval =  0.28
            },
            ['mid'] = {
                frames = {2,5,2},
                interval =  0.28
            },
            ['tip'] = {
                frames = {3,6,3},
                interval = 0.28
            }
        }
    }
}