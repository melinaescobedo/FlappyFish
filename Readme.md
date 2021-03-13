# ·········································· Flappy Fish ·········································· #

### Michel Pellegrin Quiroz 162480 
### Melina Escobedo Zárate 164094 

***
In this 'readme.md' you will find a series of topics of utmost importance 
for the development of a video game based on "Flappy Bird" 
as well as some code snippets to exemplify important aspects and other 
related subtopics. 
***

[Link Flappy Fish code in GitHub](https://github.com/melinaescobedo/FlappyFish.git)

**Important things to consider:**

----------------------------------------------------------------------------------

_love.graphics.newImage(path)_

    This function led us load an image from graphics files (PNG,
    JPG, JPEG, GIF, etc.) from our disk, storing it and letting
    us use it as an object that we can draw into the screen.
    
---------------------------------------------------------------------------------- 

_Push Library_
    
    Since we are working with a virtual resolution, the use of 
    'push' library is extremely important. 
    
----------------------------------------------------------------------------------

_Parallax Scrolling_

    It refers to the illusion of movement given by two 
    different frames, where each one has a different speed of 
    movement, by using a sort of graphical illusion.

It is important to note the following, because this is going to have the 
effect of no x offset, which can be found in our 'main.lua':
    `local backgroundScroll = 0`
    `local groundScroll = 0`
    
----------------------------------------------------------------------------------  

_Background & Ground_

    The background needs to go at a slower rate than the ground 
    in order to get the parallax effect. All of this can be 
    obtained by separating the speed variables.
    
`local BACKGROUND_SCROLL_SPEED = 30`
`local GROUND_SCROLL_SPEED = 60`

    In order to add the effect of speed to our image we 
    should use:

`backgroundScroll = (backgroundScroll + 
    BACKGROUND_SCROLL_SPEED * dt )`
`groundScroll = (groundScroll + 
    GROUND_SCROLL_SPEED * dt )`

    and for reset it we use modulus.
    
----------------------------------------------------------------------------------

_Looping Point_
    
    Because the game is continuous (infinite) and the image 
    comes to an end, a looping point must be created, where the
    image goes through and immediately returns to continue 
    walking and creates the illusion of an infinite background. 
    To calculate our point, we must simply see within our 
    background image how many times the same pattern is 
    repeated, then in the first one we take the measurement in 
    pixels and that value becomes our looping point. 
    
---------------------------------------------------------------------------------- 

_Gravity_

    We want a velocity, a 'y' velocity, so that it's updating 
    our position in each frame, and it's going to make it feel
    like we're falling. So we're going to shoot up pretty fast, 
    but gravity is going to start taking hold immediately 
    after, and we're going to start getting the effect of our 
    object jumping.
 
 --------------------------------------------------------------------------------- 
 
 _Pipes_
 
    We know that the pipes only need to be repeated, since they 
    are only loaded once in the code. So we want them to look 
    like they're sticking out of the ground. Taking this, we
    know that what we want to do is to have a correct render
    layer, in which we draw the background first, then we draw 
    the pipes, and at the end we draw the floor. Then to create 
    this "effect" we must use the following loop, inside our 
    'love.draw()' function:
    
`for k, pipe in pairs(pipes) do`
    `pipe: render()`
`end`

    And this will have the effect of iterating through all the 
    pipes in our scene every draw call, and drawing them before
    it draws the ground, and before it draws the object. To create 
    the effect of two pipes, one at the top and one at the bottom, 
    inside our code 'PipePair.lua' we can add two braces inside our 
    table, where the top pipe should flip over to make sense.
    
----------------------------------------------------------------------------------

_Collisions_

    If the object hits any of the pipes the point of the game is 
    to end there, so it is important to define the collisions. 
    These we must indicate them so that they happen when the 
    pixels of the object and the pipe touch, nevertheless it 
    is given a few pixels of more so that visually it does not 
    seem an error. 
    The collision type to be used is 'Axis-aligned minimum 
    bounding box' or better known as 'AABB Collision', this is
    a spatial subdivision data structure and in turn is a set 
    of algorithms used mainly to perform intersections and
    calculate distances efficiently on geometric objects.    

----------------------------------------------------------------------------------

_State Machine_


    * * * * * * * * * * * *             * * * * * * * * * * * *
    *                     *             *                     *    
    *  TitleScreen State  * ----------> *   CountDown State   *
    *                     *             *                     *
    * * * * * * * * * * * *             * * * * * * * * * * * *
                                        ^          |
               ┌ ---------------------- ┘          |
               |                                   |
               |                                   v
    * * * * * * * * * * * *             * * * * * * * * * * * *
    *                     *             *                     *    
    *     Score State     * <---------- *      Play State     *
    *                     *             *                     *
    * * * * * * * * * * * *             * * * * * * * * * * * *

    The finite state machine serves perfectly to explain the 
    process or inner workings of the game. Because we start in 
    a state in which our background simply advances and the 
    title appears (represented by "TitleScreen State"), then 
    pressing "enter" makes a state change (represented by 
    'CountDown') and when this new state reaches 0 it advances 
    again to the next state (represented by 'Play State') and 
    to change state again our object must perform a collision 
    to move to another state (represented by 'Score State') 
    where it displays the count of points accumulated in 
    the game. Within the main code, a call or requirement is 
    made to each of the states separately.
 
    // This state machine was implemented based on: Flappy Bird - Lecture 1 - CS50's Introduction to Game Development 2018: https://www.youtube.com/watch?v=3IdOCxHGMIo
