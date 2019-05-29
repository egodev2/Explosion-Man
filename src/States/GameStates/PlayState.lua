PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- Set timer's level go down by one at each 0.7s
    Timer.every(0.7, function() 
        self.level.timer = self.level.timer - 1
    end)

    -- Select a music stage
    self.randomMusicIndex = math.random(1,#gStageMusic)

    -- Set to apropriate volume
    love.audio.setVolume(0.3)

    -- Set to loop and play
    gStageMusic[self.randomMusicIndex]:setLooping(true)
    gStageMusic[self.randomMusicIndex]:play()
end

function PlayState:enter(params)
    -- Get level passed 
    self.level = params.level

    -- Get current score
    self.score = params.score

    -- Set player to invulnurable and change to the idle state.
    self.level.map.player:goInvulnerable(PLAYER_INVUL_TIME)
    self.level.map.player:changeState('idle')

    -- Update the score needed to get a 1UP
    self.scoreToOneUP = math.floor(self.level.map.score/SCORE_TO_ONEUP) * SCORE_TO_ONEUP + SCORE_TO_ONEUP
end

function PlayState:update(dt)

    -- Check if the player died (lost a life and no lives left)
    if self.level.map.player.dead then
        -- Stop stage music
        love.audio.stop(gStageMusic[self.randomMusicIndex])

        -- Check which position in highscore list player achieved
        local scorePosition = self:HighScorePlace() 

        -- If the score is not in the top 10, change to GameOver screen
        -- Otherwise, change to input score screen
        if scorePosition > 10 then
            gStateMachine:change("game-over")
        else
            gStateMachine:change("type-high-score", {
                score = self.level.map.score,
                line = scorePosition
            })
        end
    end

    -- Check if level's time has expired
    if self.level.timer <= 0 then
        -- If the player still has lives left, game continues. 
        -- Otherwise, same as lines 38-55
        if self.level.map.player.lives >= 0 then
            -- Make player invulnurable again
            self.level.map.player:goInvulnerable(PLAYER_INVUL_TIME)

            -- self.level.map.player.stateMachine[ANYSTATE]:Respawn()

            -- Decrement a life from player and reset powerups
            self.level.map.player:onDeath()

            -- Reset Timer
            self.level.timer = 500
        else
            -- stop stage music
            love.audio.stop(gStageMusic[self.randomMusicIndex])

            -- Check which position in highscore list player achieved
            local scorePosition = self:HighScorePlace() 
            
            -- If the score is not in the top 10, change to GameOver screen
            -- Otherwise, change to input score screen
            if scorePosition > 10 then
                gStateMachine:change("game-over")
            else
                gStateMachine:change("type-high-score", {
                    score = self.level.map.score,
                    line = scorePosition
                })
            end
        end
    end

    -- Check if player scored enough to get one life
    if self.level.map.score >= self.scoreToOneUP then
        -- Apply changes to player
        self.level.map.player:onOneUP()
        -- Update the new score to reach.
        self.scoreToOneUP = self.scoreToOneUP + SCORE_TO_ONEUP
    end

    -- Player killed all mobs and reached the exit. Change to another level.
    if self.level.map.exit.usedByPlayer then

        -- Give points based on how many levels the player progressed, up to 4000.
        self.level.map.score = self.level.map.score +  math.min(1000 + (self.level.number - 1) * 100, 4000)

        -- Check if player scored enough to get one life before changing levels.
        if self.level.map.score >= self.scoreToOneUP then
            -- Do apropriate logic on player's side (increment a life and play a sound)
            self.level.map.player:onOneUP()

            -- Update score for a 1UP
            self.scoreToOneUP = self.scoreToOneUP + SCORE_TO_ONEUP
        end

        -- Audio when colliding with exit.
        gSounds['exitReached']:play()

        -- Stop stage music
        love.audio.stop(gStageMusic[self.randomMusicIndex])

        -- Fade in, saving relevant information for next level.
        gStateMachine:change('fade-in', {
            levelNumber = self.level.number + 1,
            score = self.level.map.score,
            maxBombs = self.level.map.player.maxBombs,
            power = self.level.map.player.power,
            lives = self.level.map.player.lives,
            oldLevel = self.level
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
    -- Update our level's logic
    self.level:update(dt)
end

function PlayState:render()
    -- Render our level
    self.level:render()
end

function PlayState:HighScorePlace()

    local DEBUG = love.filesystem.newFile("DEBUG.txt")
    DEBUG:open("w")

    -- The player's score's possible position
    local scorePosition = 1

    -- Read each line from our HighScore file
    for line in love.filesystem.lines("HighScore.lst") do 
        -- Read spaces
        local space = 0

        -- Our read string score
        local score = " "

        -- Read char by char of the line
        -- Each line is formated as: "POS" ' ' "NAME" ' ' "SCORE", so we know that the score
        -- will be after two spaces.
        for k = 1, #line do
            local c = line:sub(k,k)
            if space == 2 then
                score = score .. c
            elseif c == ' ' then
                space = space + 1
            end
        end

        DEBUG:write(tostring(tonumber(score)) .. '\n')
        DEBUG:write(tostring(self.level.map.score) .. '\n')

        -- If player's score is higher than the one read from the line, stop.
        if self.level.map.score >= tonumber(score) then
            break
        end

        -- Increment it's score position, thus decreasing player's possible high score position.
        scorePosition = scorePosition  + 1
    end

    DEBUG:write("TESTE - TERMINEI" .. '\n')
    DEBUG:close()

    return scorePosition
end