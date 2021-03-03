--[[
    GD50 2018
    Flappy Bird Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
    What is Flappy According to the author? (Context)
    A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple 
    but effective gameplay mechanic of avoiding pipes indefinitely by just tapping 
    the screen, making the player's bird avatar flap its wings and move upwards slightly. 
    A variant of popular games like "Helicopter Game" that floated around the internet
    for years prior. Illustrates some of the most basic procedural generation of game
    levels possible as by having pipes stick out of the ground by varying amounts, acting
    as an infinitely generated obstacle course for the player.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic, we can find this at: https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods, we can find this at https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

--Requiring the class for ou game
-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'StateMachine'

require 'states/BaseState' --Base class of our states, define empty methods 
require 'states/CountdownState' -- Class for the countdown state, it change from countdown to play state.
require 'states/PlayState' -- Use a new class of the playing state. All the code that was in the main now is at this class
require 'states/ScoreState' -- Class that show the final score after you lost. And can change from score state to countdown state.
require 'states/TitleScreenState' -- Class that give the "welcome" to the flappy fish.

--Require more class to creat objects of Bird, Pipe, and PipePair classes.
require 'Bird'
require 'Pipe'
require 'PipePair'

--good measure according to the author of the code.
-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

--Load the image of the background
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0 -- declare this variable to move the background

--Load the image of the ground 
local ground = love.graphics.newImage('ground.png')
local groundScroll = 0 -- declare this variable to move the ground

--Speed at which the ground and background will be moving.
--The background must go slower than the ground. 
--Same effect as in the highway, things that are closer move faster.
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

--point at which the backgorund start repeating 
local BACKGROUND_LOOPING_POINT = 540

-- global variable we can use to scroll the map
--if its true we will scroll, when the game is paused it will be paused as well as the background.
scrolling = true

function love.load()
    -- initialize our nearest-neighbor filter
    --love.graphics.setDefaultFilter('nearest', 'nearest')
    
    -- seed the RNG
    --To generate random numbers according to the time.
    math.randomseed(os.time())

    -- app window title
    love.window.setTitle('Flappy Fish')

    -- initialize our text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initialize our table of sounds
    sounds = {
        ['jump'] = love.audio.newSource('burbujas.mp3', 'static'),
        ['explosion'] = love.audio.newSource('SantaMedusa.mp3', 'static'), --combine this sound with hurt to create a better special effect.
        ['hurt'] = love.audio.newSource('choque.mp3', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['music'] = love.audio.newSource('sirenita.mp3', 'static')
    }

    -- kick off music
    sounds['music']:setLooping(true) --to repeat the audio when it has finish, so it will always have the backgorund music of little mermaid
    sounds['music']:play() --play the music when we run the game.

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true -- need to have the function resize that we call from push.lua
    })

    -- initialize state machine with all state-returning functions
    --Table of our State Machine to for called them in the main.lua
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')--Start at the title screen state when running the game.

    --Remember that when we have {} it means that is a table, because lua works with tables.
    -- initialize input table
    love.keyboard.keysPressed = {}

    -- initialize mouse input table
    love.mouse.buttonsPressed = {}

end --end of load function

--function to resize the window
function love.resize(w, h)
    push:resize(w, h) --resixe according to the new width and height. 
end

--function to see what key is being pressed so and action will happen.
function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    --condition to quit 
    if key == 'escape' then
        love.event.quit()
    end
end

--[[
    LÖVE2D callback fired each time a mouse button is pressed; gives us the
    X and Y of the mouse, as well as the button in question.
]]
--To be able to play also with the mouse and not just the keyboard.
function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

--[[
    Equivalent to our keyboard function from before, but for the mouse buttons.
]]
function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

--function to update the scrolling and the state during the game
function love.update(dt)
    --remember that scrolling is true until you collided with a pipe
    --the title screen state and the play state will have the background scrolling=true
    --, and also the countdown state in the first time.
    if scrolling then
        --the background will move slower than the ground because of the velocities that we have declare before.
        --the background will move according to the looping point of it. If this looping point is incorrect or not very precise
        --the background won't move continusly, and will have some errors.
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        -- the ground scrolls according to the virtual width, because the author thinks is a good reference for moving the ground
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end

    --Variables that start with g, means that they are global variables.
    gStateMachine:update(dt)--update de state machine according to time.

    --keep track of the inputs 
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

--function to draw all elements on screen
function love.draw()
   --called push because that program is to initialize the window 
    push:start()

    -- scroll the backgorund in a position given 
    love.graphics.draw(background, -backgroundScroll, 0)
    --render all the other elements by using the state machin global variable
    gStateMachine:render()
    -- scroll the gorund in a position given 
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    
    push:finish()
end