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

local gameStarted = false

local mydata = require("mydata")

------ Global useful vars -----
centerX = display.contentCenterX
centerY = display.contentCenterY
screenTop = display.screenOriginY
screenLeft = display.screenOriginX
bottomMarg = display.contentHeight - display.screenOriginY
rightMarg = display.contentWidth - display.screenOriginX

------------------------------------ GAME FUNCTIONS -------------------------------------

-- onCollision: function for trigger LOSER PLAYER =((
function onCollision(event)
    if (event.phase == "began") then
        composer.gotoScene("restart")
    end
end

function flyUpCorona(event)

    if event.phase == "began" then

        if gameStarted == false then
            player.bodyType = "dynamic"
            instructions.alpha = 0
            tb.alpha = 1
            addColumnTimer = timer.performWithDelay(1000, addColumns, -1)
            moveColumnTimer = timer.performWithDelay(2, moveColumns, -1)
            gameStarted = true
            player:applyForce(0, -300, player.x, player.y)
        else

            player:applyForce(0, -600, player.x, player.y)

        end
    end
end

function moveColumns()
    for a = elements.numChildren,1,-1  do
        if(elements[a].x < display.contentCenterX - 170) then
            if elements[a].scoreAdded == false then
                mydata.score = mydata.score + 1
                tb.text = mydata.score
                elements[a].scoreAdded = true
            end
        end
        if(elements[a].x > -100) then
            elements[a].x = elements[a].x - 12
        else
            elements:remove(elements[a])
        end
    end
end

function addColumns()

    height = math.random(display.contentCenterY - 200, display.contentCenterY + 200)

    topColumn = display.newImageRect('topColumn.png',100,714)
    topColumn.anchorX = 0.5
    topColumn.anchorY = 1
    topColumn.x = display.contentWidth + 100
    topColumn.y = height - 160
    topColumn.scoreAdded = false
    physics.addBody(topColumn, "static", {density=1, bounce=0.1, friction=.2})
    elements:insert(topColumn)

    bottomColumn = display.newImageRect('bottomColumn.png',100,714)
    bottomColumn.anchorX = 0.5
    bottomColumn.anchorY = 0
    bottomColumn.x = display.contentWidth + 100
    bottomColumn.y = height + 160
    physics.addBody(bottomColumn, "static", {density=1, bounce=0.1, friction=.2})
    elements:insert(bottomColumn)

end

local function checkMemory()
    collectgarbage( "collect" )
    local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
    --print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end

-- groundScroller: function for scroll the platform base to reproduce forward loop movement
function groundScroller(self,event)

    if self.x < (-900 + (self.speed*2)) then
        self.x = 900
    else
        self.x = self.x - self.speed
    end
end

-- loop: infinte rotation of corona player sheet
local function rotationLoop()
    player.rotation = player.rotation + 10
end

-- acceleration: function that accelerate the rotation, called when player sheet is tapped
local function acceleration()
    player.rotation = player.rotation + 10
end


-------------------------------------- GAME EVENTS --------------------------------------

---- :CREATE
function scene:create(event)

    -- Initialize gameScene
    local gameScene = self.view

    gameStarted = false
    mydata.score = 0

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

    -- TODO ?????
    elements = display.newGroup()
    elements.anchorChildren = true
    elements.anchorX = 0
    elements.anchorY = 1
    elements.x = 0
    elements.y = 0
    gameScene:insert(elements)

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
    platform.speed = 4
    gameScene:insert(platform)

    platform2 = display.newImageRect('res/platform.png',900,53)
    platform2.anchorX = 0
    platform2.anchorY = 1
    platform2.x = platform2.width
    platform2.y = display.viewableContentHeight - 110
    physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
    platform2.speed = 4
    gameScene:insert(platform2)

    -- Player icon
    player = display.newImageRect("res/corona.png",64,64)
    player.anchorX = 0.5
    player.anchorY = 0.5
    player.x = display.contentCenterX + 70
    player.y = display.contentCenterY - 200
    gameScene:insert(player)

    -- Score table
    tb = display.newText(mydata.score,display.contentCenterX,
        150, "pixelmix", 58)
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

        composer.removeScene("start")
        Runtime:addEventListener("touch", flyUpCorona)

        platform.enterFrame = platformScroller
        Runtime:addEventListener("enterFrame", platform)

        platform2.enterFrame = platformScroller
        Runtime:addEventListener("enterFrame", platform2)

        Runtime:addEventListener("collision", onCollision)

        memTimer = timer.performWithDelay( 1000, checkMemory, 0 ) -- looppalo

    end
end

---- :HIDE
function scene:hide(event)

    local gameScene = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        Runtime:removeEventListener("touch", flyUp)
        Runtime:removeEventListener("enterFrame", platform)
        Runtime:removeEventListener("enterFrame", platform2)
        Runtime:removeEventListener("collision", onCollision)
        timer.cancel(addColumnTimer)
        timer.cancel(moveColumnTimer)
        timer.cancel(memTimer)


    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene

