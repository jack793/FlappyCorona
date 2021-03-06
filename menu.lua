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

-- set audio active channel and audio assets
local audioChannel = 1
local backgroundMusic = audio.loadStream("res/menu.wav")

------------------------------------ MENU FUNCTIONS -------------------------------------

-- startGame: after click start button, let's go to the game!
function startGame(event)
    if event.phase == "ended" then
        composer.gotoScene("game")
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


-- closeApp
function closeApp()
    -- detect os type
    if  system.getInfo("platformName")=="Android" then
        native.requestExit()
    else
        os.exit()
    end

end


-- rotation loop functions
-- TODO Refactor in 2 functions with input parameters
function rotationLoopPlayer()
    player.rotation = player.rotation + 10
end

function rotationLoopGear()
    big_gear.rotation = big_gear.rotation + 0.1
end

function rotationLoopSmallGear()
    small_gear.rotation = small_gear.rotation - 0.2
end

-------------------------------------- MENU EVENTS --------------------------------------

---- :CREATE
function scene:create(event)
    -- Initialize menuScene
    local menuScene = self.view

    -- Add object, listeners and interacions to menuScene

    -- Play the background music on channel 1, loop infinitely, and fade in over 5 seconds
    -- Free downloaded from 'playonloop.com'
    backgroundMusicChannel = audio.play( backgroundMusic, { channel=audioChannel, loops=-1, fadein=2000 } )

    -- Background
    background = display.newImageRect("res/menu_bckgrnd.png",900,1425)
    background.anchorX = 0.5
    background.anchorY = 1
    background.x = display.contentCenterX
    background.y = display.contentHeight
    menuScene:insert(background)

    -- Gears
    big_gear = display.newImageRect("res/bigGear.png",800,800)
    big_gear.anchorX = 0.5
    big_gear.anchorY = 0.5
    big_gear.x = display.contentCenterX - 200
    big_gear.y = display.contentCenterY + 200
    menuScene:insert(big_gear)

    small_gear = display.newImageRect("res/smallGear.png",500,500)
    small_gear.anchorX = 0.5
    small_gear.anchorY = 0.5
    small_gear.x = display.contentCenterX + 420
    small_gear.y = display.contentCenterY + 350
    menuScene:insert(small_gear)

    -- Title
    title = display.newImageRect("res/title.png",600,240)
    title.anchorX = 0.5
    title.anchorY = 0.5
    title.x = display.contentCenterX - 200
    title.y = display.contentCenterY - 50
    menuScene:insert(title)

    -- Ground
    ground = display.newImageRect('res/ground.png',900,162)
    ground.anchorX = 0
    ground.anchorY = 1
    ground.x = 0
    ground.y = display.contentHeight
    menuScene:insert(ground)

    -- platforms
    platform = display.newImageRect('res/platform.png',900,60)
    platform.anchorX = 0
    platform.anchorY = 1
    platform.x = 0
    platform.y = display.viewableContentHeight - 110
    physics.addBody(platform, "static", {density=.1, bounce=0.1, friction=.2})
    platform.speed = 4
    menuScene:insert(platform)

    platform2 = display.newImageRect('res/platform.png',900,60)
    platform2.anchorX = 0
    platform2.anchorY = 1
    platform2.x = platform2.width
    platform2.y = display.viewableContentHeight - 110
    physics.addBody(platform2, "static", {density=.1, bounce=0.1, friction=.2})
    platform2.speed = 4
    menuScene:insert(platform2)

    -- Start button
    start = display.newImageRect("res/start_btn.png",400,100)
    start.anchorX = 0.5
    start.anchorY = 1
    start.x = display.contentCenterX
    start.y = display.contentCenterY + 400
    menuScene:insert(start)

    -- Exit button
    exit = display.newImageRect("res/exit_btn.png",300,80)
    exit.anchorX = 0.5
    exit.anchorY = 1
    exit.x = display.contentCenterX
    exit.y = display.contentCenterY + 520
    menuScene:insert(exit)

    -- Player icon
    player = display.newImageRect("res/corona.png",128,128)
    player.anchorX = 0.5
    player.anchorY = 0.5
    player.x = display.contentCenterX + 170
    player.y = display.contentCenterY - 50
    menuScene:insert(player)

    -- -- Title group animation (title + player icon) -- --
    titleGroup = display.newGroup()
    -- titleGroup.anchorChildren = true <<<---- This line destroy layout, the cause is player animation
    titleGroup.anchorX = 0.5
    titleGroup.anchorY = 0.5
    titleGroup.x = display.contentCenterX - 260
    titleGroup.y = display.contentCenterY - 1050

    titleGroup:insert(title)
    titleGroup:insert(player)

    menuScene:insert(titleGroup)
    titleAnimation()
end

---- :SHOW
function scene:show(event)

    local menuScene = self.view
    local phase = event.phase

    if (phase == "will") then
        composer.removeScene("splash")
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif (phase == "did") then
        -- Called when the scene is now on screen.
        -- Insert code to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        composer.removeScene("scores")

        start:addEventListener("touch", startGame)
        exit:addEventListener("touch", closeApp)

        -- Gears animations
        Runtime:addEventListener("enterFrame", rotationLoopGear)
        Runtime:addEventListener("enterFrame", rotationLoopSmallGear)
    end

end

---- :HIDE
function scene:hide(event)

    local menuScene = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        start:removeEventListener("touch", startGame)
        exit:removeEventListener("touch", closeApp)

        -- Gears listeners
        Runtime:removeEventListener("enterFrame", rotationLoopGear)
        Runtime:removeEventListener("enterFrame", rotationLoopSmallGear)

        -- Ground listeners
        Runtime:removeEventListener("enterFrame", platform)
        Runtime:removeEventListener("enterFrame", platform2)
        transition.cancel(downTransition)
        transition.cancel(upTransition)
    elseif (phase == "did") then
        -- Stop background menu music
        audio.stop(audioChannel)
        -- audio.fadeOut({ channel=audioChannel, time=1000 } )
        --      fadeOut replacing .stop function don't work properly (cause a downvolume on other game sounds!)
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


-----------------------------------------------------------------------------------------


return scene