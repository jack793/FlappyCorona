--
-- Created by IntelliJ IDEA.
-- User: Giacomo
-- Date: 15/12/17
-- Time: 18:23
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

-- include the Corona "composer" module and add this scene
local composer = require "composer"
local scene = composer.newScene()

-- include physics and data deps
local physics = require "physics"
physics.start()

------ Global useful vars -----
centerX = display.contentCenterX
centerY = display.contentCenterY
screenTop = display.screenOriginY
screenLeft = display.screenOriginX
bottomMarg = display.contentHeight - display.screenOriginY
rightMarg = display.contentWidth - display.screenOriginX

--//local mydata = require( "mydata" )

------------------------------------ MENU FUNCTIONS -------------------------------------

-- startGame: after click start button, let's go to the game!
function startGame(event)
    if event.phase == "ended" then
        composer.gotoScene("game")
    end
end

-- groundScroller: function for scroll the platform base to reproduce forward loop movement
function groundScroller(self,event)

    if self.x < (-900 + (self.speed*2)) then
        self.x = 900
    else
        self.x = self.x - self.speed
    end
end

-- Title animation: it's a compostition of 3 small functions that bounce the title group
function titleTransitionDown()
    downTransition = transition.to(titleGroup,{time=400, y=titleGroup.y+20,onComplete=titleTransitionUp})

end

function titleTransitionUp()
    upTransition = transition.to(titleGroup,{time=400, y=titleGroup.y-20, onComplete=titleTransitionDown})

end

function titleAnimation()
    titleTransitionDown()
end

-- loop: infinte rotation of corona player sheet
local function loop()
    player.rotation = player.rotation + 10
end

-------------------------------------- MENU EVENTS --------------------------------------

---- :CREATE
function scene:create(event)
    -- Initialize menuScene
    local menuScene = self.view

    -- Add object, listeners and interacions to menuScene

    -- Background
    background = display.newImageRect("res/bckgrnd.png",900,1425)
    background.anchorX = 0.5
    background.anchorY = 1
    background.x = display.contentCenterX
    background.y = display.contentHeight
    menuScene:insert(background)

    -- Title
    title = display.newImageRect("res/title.png",300,100)
    title.anchorX = 0.5
    title.anchorY = 0.5
    title.x = display.contentCenterX - 20
    title.y = display.contentCenterY
    menuScene:insert(title)

    -- Platform
    platform = display.newImageRect("res/platform.png",900,53)
    platform.anchorX = 0
    platform.anchorY = 1
    platform.x = 0
    platform.y = display.viewableContentHeight - 110
    physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
    platform.speed = 4
    menuScene:insert(platform)

    -- Start button
    start = display.newImageRect("res/start_btn.png",400,100)
    start.anchorX = 0.5
    start.anchorY = 1
    start.x = display.contentCenterX
    start.y = display.contentHeight - 400
    menuScene:insert(start)

    -- Player icon
    player = display.newImageRect("res/corona.png",128,128)
    player.anchorX = 0.5
    player.anchorY = 0.5
    player.x = display.contentCenterX + 240
    player.y = display.contentCenterY
    menuScene:insert(player)

    -- -- Title group animation (title + player icon) -- --
    titleGroup = display.newGroup()
    --titleGroup.anchorChildren = true
    titleGroup.anchorX = 0.5
    titleGroup.anchorY = 0.5
    titleGroup.x = centerX - 370
    titleGroup.y = screenTop - 300

    titleGroup:insert(title)
    titleGroup:insert(player)

    menuScene:insert(titleGroup)
    titleAnimation() -- bounce animation of the entire title --

end

---- :SHOW
function scene:show(event)

    local menuScene = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        composer.removeScene("restart")

        composer.removeScene("restart")
        start:addEventListener("touch", startGame)
    end

end

---- :HIDE
function scene:hide(event)

    local menuScene = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        start:removeEventListener("touch", startGame)
        Runtime:removeEventListener("enterFrame", platform)
        transition.cancel(downTransition)
        transition.cancel(upTransition)
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end

---- :DESTROY
function scene:destroy(event)

    local menuScene = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-------------------------------------- LISTENERS SETUP -----------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- player sheet rotation loop
Runtime:addEventListener( "enterFrame", loop )


-----------------------------------------------------------------------------------------


return scene