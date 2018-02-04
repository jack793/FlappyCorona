--
-- Created by IntelliJ IDEA.
-- User: Giacomo
-- Date: 18/12/17
-- Time: 11:39
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

--- GAME SETTINGS ---

-- include the Corona "composer" module and add this scene
local composer = require "composer"
local scene = composer.newScene()

-- include physics and data deps
local physics = require "physics"
physics.start()

-- Set gravity of the scene physics
physics.setGravity(0,100)

-- Initialize local svariables
local score = 0
local gameStarted = false
local paused = false
-- Audio
local audioChannel = 2
local gameOverHit = audio.loadStream("res/hit.wav")
local sheetTap = audio.loadStream("res/tap.wav")

------------------------------------ GAME FUNCTIONS -------------------------------------

-- ||| getThisGameScore: debugging |||
function getThisGameScore()
    print("final score: " .. score)
end


-- endGame: game over function callback
function endGame(event)
    if (event.phase == "began") then

        -- Play the hit gameover sound
        audio.play(gameOverHit, {audioChannel=audioChannel})

        getThisGameScore() -- console log
        pause_btn.alpha = 0

        -- SET A GLOBAL COMPOSER VARIABLE, VISIBLE AND USABLE TO ALL SCENES TROUGHT COMPOSER, CALLED 'finalscore'
        composer.setVariable("finalScore", score)

        -- Finally, go to the gameover scene
        composer.gotoScene("scores", {time=500, effect="fade"})
    end
end

-- pixelateOnPause and removePixelate: add and remove cool pixelate effect on pause and resume the game
function pixelateOnPause()
    -- Transition the filter of 100 milliseconds
    transition.to(player.fill.effect, { time=50, numPixels=20 })
    transition.to(platform.fill.effect, { time=50, numPixels=20 })
    transition.to(platform2.fill.effect, { time=50, numPixels=20 })
    --transition.to(columns.fill.effect, { time=50, numPixels=20 })
end

function removePixelate()
    -- Trick to remove filter effect
    transition.to(player.fill.effect, { timer=50, numPixels=.1 })
    transition.to(platform.fill.effect, { time=50, numPixels=.1 })
    transition.to(platform2.fill.effect, { time=50, numPixels=.1 })
    transition.to(columns.fill.effect, { time=50, numPixels=.1 })
end


-- pauseGame: Pause the game
function pauseGame(event)
    if event.phase == "began" then
        if paused == false then

            -- Manage graphics elements on pause
            pause_tb.alpha = 1
            tb.alpha = 0
            pause_btn.alpha = 0
            pause_overlay.alpha = 1

            -- Add pixelate effects
            pixelateOnPause()

            Runtime:removeEventListener("touch", flyUpCorona)
            Runtime:removeEventListener("enterFrame", rotationLoop)

            -- Remove platforms listeners
            Runtime:removeEventListener("enterFrame", platform)
            Runtime:removeEventListener("enterFrame", platform2)

            Runtime:removeEventListener("collision", endGame)

            -- Reset timers
            timer.cancel(addColumnTimer)
            timer.cancel(moveColumnTimer)
            physics.pause()
            paused = true
        end
    end
end

-- resumeGame: Resume the game, timers and physics
function resumeGame(event)
    if event.phase == "began" then
        if paused == true then

            -- Manage graphics elements on pause
            pause_tb.alpha = 0
            tb.alpha = 1
            pause_btn.alpha = 1
            pause_overlay.alpha = 0

            -- Remove pixelate effects on game elements
            removePixelate()

            Runtime:addEventListener("touch", flyUpCorona)
            Runtime:addEventListener("enterFrame", rotationLoop)

            -- Remove platforms listeners
            Runtime:addEventListener("enterFrame", platform)
            Runtime:addEventListener("enterFrame", platform2)

            Runtime:addEventListener("collision", endGame)

            -- Reset timers
            addColumnTimer = timer.performWithDelay(1000, addColumns, -1)
            moveColumnTimer = timer.performWithDelay(2, moveColumns, -1)
            physics.start()
            paused = false
        end
    end
end


-- platfromScoller: function for scroll platform over the ground
function platformScroller(self)

    if self.x < (-900 + (self.speed*2)) then
        self.x = 900
    else
        self.x = self.x - self.speed
    end

end

-- flyUpCorona: function to give force to jump up when corona sheet is tapped
function flyUpCorona(event)
    if event.phase == "began" then
        if gameStarted == false then
            player.bodyType = "dynamic"
            instructions.alpha = 0
            tb.alpha = 1
            pause_btn.alpha = 1
            addColumnTimer = timer.performWithDelay(1000, addColumns, -1)
            moveColumnTimer = timer.performWithDelay(2, moveColumns, -1)
            gameStarted = true
            player:applyForce(0, -650, player.x, player.y)
            audio.play(sheetTap)
        else
            player:applyForce(0, -1300, player.x, player.y)
            audio.play(sheetTap)
        end
    end
end

-- moveColumns: using for columns movement and score increment
function moveColumns()
    for a = columns.numChildren,1,-1  do
        -- Right space calculated between player sheet and columns positions
        if(columns[a].x < display.contentCenterX - 170) then
            if columns[a].scoreAdded == false then
                score = score + 1
                tb.text = score
                columns[a].scoreAdded = true
            end
        end
        if(columns[a].x > -100) then
            columns[a].x = columns[a].x - 12
        else
            columns:remove(columns[a])
        end
    end
end

-- addColumns: function that randomly generate the columns witch appears during game
function addColumns()

    height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

    topColumn = display.newImageRect('res/topColumn.png',100,714)
    topColumn.anchorX = 0.5
    topColumn.anchorY = 1
    topColumn.x = display.contentWidth + 100
    topColumn.y = height - 170
    topColumn.scoreAdded = false
    physics.addBody(topColumn, "static", {density=1, bounce=0.1, friction=.2})
    columns:insert(topColumn)

    bottomColumn = display.newImageRect('res/bottomColumn.png',100,714)
    bottomColumn.anchorX = 0.5
    bottomColumn.anchorY = 0
    bottomColumn.x = display.contentWidth + 100
    bottomColumn.y = height + 170
    physics.addBody(bottomColumn, "static", {density=1, bounce=0.1, friction=.2})
    columns:insert(bottomColumn)

end

-- loop: infinte rotation of corona player sheet
function rotationLoop()
    player.rotation = player.rotation + 10
end

--------- PERFORMANCE DEBUGGING ---------

local function checkMemory()
    collectgarbage( "collect" )
    local memUsage_str = string.format("MEMORY = %.3f KB", collectgarbage("count"))
    print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024)))
end

-------------------------------------- GAME EVENTS --------------------------------------

---- :CREATE
function scene:create(event)

    -- Initialize gameScene
    local gameScene = self.view

    gameStarted = false

    -- Add object, listeners and interacions to gameScene

    -- Static Wall
    local wall = display.newImage("res/bckgrnd.png")
    gameScene:insert(wall)

    -- Background
    background = display.newImageRect("res/bckgrnd.png",900,1425)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = display.contentHeight
    background.speed = 4
    gameScene:insert(background)

    -- Graphic group used for moving and calculate scores w/ columns
    columns = display.newGroup()
    --elements.anchorChildren = true
    columns.anchorX = 0
    columns.anchorY = 1
    columns.x = 0
    columns.y = 0
    gameScene:insert(columns)

    pause_btn = display.newImageRect("res/pause_btn.png", 100,100)
    pause_btn.x = 50
    pause_btn.y = 50
    pause_btn.alpha = 0
    gameScene:insert(pause_btn)

    -- Ground
    ground = display.newImageRect('res/ground.png',900,162)
    ground.anchorX = 0
    ground.anchorY = 1
    ground.x = 0
    ground.y = display.contentHeight
    gameScene:insert(ground)

    -- Platforms
    platform = display.newImageRect('res/platform.png',900,53)
    platform.anchorX = 0
    platform.anchorY = 1
    platform.x = 0
    platform.y = display.viewableContentHeight - 110
    physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
    platform.speed = 10
    platform.fill.effect="filter.pixelate"
    gameScene:insert(platform)

    platform2 = display.newImageRect('res/platform.png',900,53)
    platform2.anchorX = 0
    platform2.anchorY = 1
    platform2.x = platform2.width
    platform2.y = display.viewableContentHeight - 110
    physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
    platform2.speed = 10
    platform2.fill.effect="filter.pixelate"
    gameScene:insert(platform2)

    -- Player icon
    player = display.newImageRect("res/corona.png",100,100)
    player.anchorX = 0.5
    player.anchorY = 0.5
    player.x = display.contentCenterX - 150
    player.y = display.contentCenterY
    -- Set a "pixelate" filter
    player.fill.effect = "filter.pixelate"
    physics.addBody(player, "static", {density=.1, bounce=0.1, friction=1})
    player:applyForce(0, -300, player.x, player.y)
    gameScene:insert(player)

    -- Score table
    tb = display.newText(score,display.contentCenterX, 150, "Arial", 58)
    tb:setFillColor(0,0,0)
    tb.alpha = 0
    gameScene:insert(tb)

    -- Istructions
    instructions = display.newImageRect("res/instructions.png",200,300)
    instructions.anchorX = 0.5
    instructions.anchorY = 0.5
    instructions.x = display.contentCenterX
    instructions.y = display.contentCenterY
    gameScene:insert(instructions)

    -- Pause table
    pause_tb = display.newImageRect("res/pause_tb.png",600,300)
    pause_tb.anchorX = 0.5
    pause_tb.anchorY = 0.5
    pause_tb.x = display.contentCenterX
    pause_tb.y = display.contentCenterY - 400
    pause_tb.alpha = 0
    gameScene:insert(pause_btn)

    -- Pause Overlay
    pause_overlay = display.newRect(display.contentCenterX,display.contentCenterY,display.viewableContentWidth,display.viewableContentHeight)
    pause_overlay:setFillColor(0,0,0,0.3)
    pause_overlay.alpha = 0
    gameScene:insert(pause_overlay)

end

---- :SHOW
function scene:show(event)

    local gameScene = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        composer.removeScene("menu")
        composer.removeScene("scores")

        Runtime:addEventListener("touch", flyUpCorona)

        Runtime:addEventListener("enterFrame", rotationLoop)

        pause_btn:addEventListener("touch", pauseGame)
        pause_overlay:addEventListener("touch", resumeGame)

        platform.enterFrame = platformScroller
        Runtime:addEventListener("enterFrame", platform)

        platform2.enterFrame = platformScroller
        Runtime:addEventListener("enterFrame", platform2)

        Runtime:addEventListener("collision", endGame)

        memTimer = timer.performWithDelay( 2000, checkMemory, 0 ) -- memory and performance check

    end
end

---- :HIDE
function scene:hide(event)

    local gameScene = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        Runtime:removeEventListener("touch", flyUpCorona)
        Runtime:removeEventListener("enterFrame", rotationLoop)

        -- Pause btn
        pause_btn:removeEventListener("touch", pauseGame)
        pause_overlay:removeEventListener("touch", resumeGame)

        -- Remove platforms listeners
        Runtime:removeEventListener("enterFrame", platform)
        Runtime:removeEventListener("enterFrame", platform2)

        Runtime:removeEventListener("collision", endGame)

        -- Reset timers
        timer.cancel(addColumnTimer)
        timer.cancel(moveColumnTimer)
        timer.cancel(memTimer)

    elseif (phase == "did") then
        -- Called immediately after scene goes off screen.
    end
end

---- :DESTROY
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

---------------------------------------------------------------------------------

return scene


