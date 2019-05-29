Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/entity_defs'
require 'src/object_defs'
require 'src/constants'
require 'src/Util'

-- Games States related src files
require 'src/States/StateMachine'
require 'src/States/GameStates/BaseState'
require 'src/States/GameStates/TitleState'
require 'src/States/GameStates/FadeInState'
require 'src/States/GameStates/FadeOutState'
require 'src/States/GameStates/PlayState'
require 'src/States/GameStates/TypeHighScoreState'
require 'src/States/GameStates/ShowHighScoreState'
require 'src/States/GameStates/GameOverState'

-- Entity State related src files
require 'src/States/EntityStates/WalkingState'
require 'src/States/EntityStates/PlayerStates/PlayerWalkingState'
require 'src/States/EntityStates/PlayerStates/PlayerIdleState'

-- World related src files
require 'src/world/Level'
require 'src/world/Map'
require 'src/world/LevelGenerator'
require 'src/world/DemoMap'

-- Other Game related src files --
require 'src/Animation'
require 'src/Entity'
require 'src/GameObject'
require 'src/Player'
require 'src/Hitbox'
require 'src/Flame'
require 'src/Hud'
require 'src/ScorePopUp'
require 'src/Exit'

gTextures = {
    ['tiles'] = love.graphics.newImage('sprites/tileSheet.png'),
    ['player'] = love.graphics.newImage('sprites/character_walk.png'),
    ['entities'] = love.graphics.newImage('sprites/entities.png'),
    ['objects'] = love.graphics.newImage('sprites/gameObjectSheet.png'),
    ['icons'] = love.graphics.newImage('sprites/iconSheet.png'),
    ['show-score'] = love.graphics.newImage('sprites/graybrickbackground.png') 
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'],16,16),
    ['player'] = GenerateQuads(gTextures['player'],16,32),
    ['entities'] = GenerateQuads(gTextures['entities'],16,16),
    ['objects'] = GenerateQuads(gTextures['objects'],16,16),
    ['icons'] = GenerateQuads(gTextures['icons'],16,16)
}

gFonts = {
    ['title'] = love.graphics.newFont('fonts/Gameplay.ttf', 32),
    ['toption'] = love.graphics.newFont('fonts/ArcadeClassic.ttf', 18),
    ['info'] =  love.graphics.newFont('fonts/Gameplay.ttf', 10),
    ['fade-anouncement'] = love.graphics.newFont('fonts/Gameplay.ttf', 24),
    ['final-score'] = love.graphics.newFont('fonts/Gameplay.ttf', 18)
}

gStageMusic = {
    [1] = love.audio.newSource('sounds/stageloop1f.mp3'),
    [2] = love.audio.newSource('sounds/stageloop2.wav'),
    [3] = love.audio.newSource('sounds/stageloop3.wav'),
}

gSounds = {
    ['exitReached'] = love.audio.newSource('sounds/exitReached.mp3'),
    ['gameover'] = love.audio.newSource('sounds/gameover.wav'),
    ['menuSelection'] = love.audio.newSource('sounds/menuSelection.wav'),
    ['newStage'] = love.audio.newSource('sounds/newStageAnnouncement.wav'),
    ['pickup'] = love.audio.newSource('sounds/pickup.wav'),
    ['putBomb'] = love.audio.newSource('sounds/putBomb.wav'),
    ['explosionBomb'] = love.audio.newSource('sounds/explosionBomb.wav'),
    ['oneUp'] = love.audio.newSource('sounds/oneUp.mp3'),
    ['exitTurnsOn'] = love.audio.newSource('sounds/exitTurnsOn.wav'),
    ['playerDies'] = love.audio.newSource('sounds/playerHurt.wav')
}

-- CREDITS --
-- 
-- Personal use, does not include assets from previous assignments, only from third party or done by myself.
-- 
-- Assets: 
-- 
-- 1)  Fonts
-- 
-- Gameplay by Geronimo Fonts:
-- URL: https://www.1001freefonts.com/gameplay.font
-- 
-- Arcade Classic by Pizzadude
-- URL: https://www.1001freefonts.com/arcade-classic.font
-- 
-- 2)  Images
-- 
-- “graybrickbackground.png”: GRAY BRICK WALL TEXTURE
-- URL: http://www.photos-public-domain.com/2012/05/18/gray-brick-wall-texture-2/
-- 
-- “tileSpriteSheet.png”: All sprites were made by myself. If you want to use it, just make sure to credit and for personal use only.
-- 
-- 3) Sounds
-- 
-- “oneUp.mp3”: achievment.mp3 by Kastenfrosch
-- URL: https://freesound.org/people/Kastenfrosch/sounds/162482/
-- 
-- “exitReached.mp3”: gotItem.mp3 by Kastenfrosch
-- URL: https://freesound.org/people/Kastenfrosch/sounds/162476/
-- 
-- “stageloop1f.mp3”: 8-bit loop.mp3 by DirtyJewbs
-- URL: https://freesound.org/people/DirtyJewbs/sounds/137227/
-- 
-- “exitTurnsOn.mp3”: Powerup/Sucess by GabrielAraujo
-- URL: https://freesound.org/people/GabrielAraujo/sounds/242501/
-- 
-- “stageloop2.wav”:  dash-runner-loop.wav by DL Sounds
-- URL: https://www.dl-sounds.com/royalty-free/dash-runner-loop/
-- 
-- “stageloop3.wav”:   8bit-harmony-lowcuff-envelope by DirtyJewbs
-- URL: https://freesound.org/people/DirtyJewbs/sounds/159392/
-- 
-- “menuSelection.wav”: Menu Selection Click by NenadSimic
-- URL: https://freesound.org/people/NenadSimic/sounds/171697/
-- 
-- “gameover.wav”: Game Over Arcade by myfox14
-- URL: https://freesound.org/people/myfox14/sounds/382310/
-- 
-- “newStageAnnouncement.wav”: 8bitSFX(only audio 1) bycelestialghost8
-- URL: https://opengameart.org/content/8bit-sfx
-- 
-- “playerHurt.wav”: Hit_Hurt39.wav by n_audioman
-- URL: https://freesound.org/people/n_audioman/sounds/273562/