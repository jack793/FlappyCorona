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

-- load menu screen
composer.gotoScene("menu")
