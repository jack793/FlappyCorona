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

local mydata = require( "mydata" )

------------------------------------ MENU FUNCTIONS -------------------------------------

-------------------------------------- MENU EVENTS --------------------------------------

function scene:create(event)
    -- Initialize menuScene
    local menuScene = self.view

    -- Add object, listeners and interacions to menuScene
    background = display.newImageRect("bckgr.png",900,1425)
    background.anchorX = 0.5
    background.anchorY = 1
end





