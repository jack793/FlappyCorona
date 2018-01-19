--
-- Created by IntelliJ IDEA.
-- User: Giacomo
-- Date: 19/01/18
-- Time: 13:00
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------------------------------------------------------
--
-- splash.lua
--
-----------------------------------------------------------------------------------------

-- include the Corona "composer" module
local composer = require "composer"
local scene = composer.newScene()

local splashScreen

------------------------------------ SPLASH FUNCTIONS ------------------------------------

local function toMenu()
    local opt = {
        effect = "crossFade",
        time = 1000
    }
    composer.gotoScene("menu", opt)
end


-------------------------------------- SPLASH EVENTS -------------------------------------

---- :CREATE
function scene:create(event)
    -- Initialize menuScene
    local splashScene = self.view

    -- splashScreen obj
    local w = display.viewableContentWidth
    local h = display.viewableContentHeight
    splashScreen = display.newImageRect("res/splashScreen.png",w,h)
    splashScreen.x = display.viewableContentWidth/2
    splashScreen.y = display.viewableContentHeight/2
    splashScene:insert(splashScreen)
end

---- :SHOW
function scene:show(event)
    timer.performWithDelay(2500, toMenu)
end

--- :HIDE
function scene:hide(event)
    print("exit splash")
    composer.removeScene("splash")
end

-------------------------------------- LISTENERS SETUP -----------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

-----------------------------------------------------------------------------------------


return scene