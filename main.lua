--
-- Created by IntelliJ IDEA.
-- User: Giacomo
-- Date: 15/12/17
-- Time: 17:51
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- include the Corona "composer" module
local composer = require "composer"

local opt = {
    effect = "crossFade",
    time = 500
}
composer.gotoScene("menu", opt)

-----------------------------------------------------------------------------------------
------------ TODO
-- [x] exit button
-- [] implement sound (background, ontap, gameover)
-- [] blurried all on pause
-- [x] splash screen
-- []
-----------------------------------------------------------------------------------------
