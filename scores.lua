--
-- Created by IntelliJ IDEA.
-- User: Giacomo
-- Date: 22/12/17
-- Time: 20:13
-- To change this template use File | Settings | File Templates.
--
-----------------------------------------------------------------------------------------
--
-- scores.lua
--
-----------------------------------------------------------------------------------------

-- include the Corona "composer" module and add this scene
local composer = require "composer"
local scene = composer.newScene()

-- include physics and data deps
local physics = require "physics"
physics.start()

-- Set gravity of the scene physics
physics.setGravity(0,100)

-- Initialize  DATA variables
local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

------------------------------------ SCORES FUNCTIONS -----------------------------------

-- loadScores: Read all contents from our persistent data file (decode json-->lua_table to read)
local function loadScores()

    -- Open the file handle
        -- mode: "w" = write mode (all file text is erased)
        -- mode: "a" = append mode (used for adding onto the end of the file)
        -- mode: "r" = read access only
    local file = io.open(filePath, "r")

    -- Decode json format data into lua tables for read it
    if file then
        local contents = file:read("*a") -- '*a' stay for read ALL contents
        io.close(file)
        scoresTable = json.decode(contents)
    else
        -- Error occurred; output the cause
        print( "File error:")
    end

    if (scoresTable == nil or #scoresTable == 0) then
        -- 10 scores
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end

    -- debugging..
    print("best score: " .. scoresTable[1])

end

-- saveScores: Write in the data file, always overwrite in 'w' mode (encode lua_table-->json after writing)
local function saveScores()

    -- Clear out any unneeded scores from scoresTable, because we only want to save the highest ten scores
    for i = #scoresTable, 11, -1 do
        table.remove(scoresTable, i)
    end

    local file = io.open(filePath, "w")

    -- Save scores data in json format
    if file then
        file:write(json.encode(scoresTable))
        io.close(file)
    end
end

-- showRestart: show restart btn with scores
function showRestart()
    menuTransition = transition.to(menu,{time=200, alpha=1})
    scoreTextTransition = transition.to(scoreText,{time=500, alpha=1})
    bestTextTransition = transition.to(bestscoreText,{time=500, alpha=1})
end

-- showScore: fadeIn scores calling showRestart() funct
function showScore()
    scoreTransition = transition.to(gameScores,{time=500, y=display.contentCenterY,onComplete=showRestart})
end

-- showGameOver: fadeIn 'gameover' image on the top of screen, it's the first thing to do..LOSEEER
function showGameOver()
    fadeTransition = transition.to(gameOver,{time=500, alpha=1,onComplete=showScore})
end

-- gotoMenu explain itself
function gotoMenu(event)
    if event.phase == "ended" then
        saveScores()
        composer.gotoScene("menu", {time=500, effect="fade"})
    end
end

-- restartGame: play again!
function restartGame(event)
    if event.phase == "ended" then
        saveScores()
        composer.gotoScene("game", {timer=1000})
    end
end

-- showNewBest: NEW BEST SCORE!!!
function showNewBest()
    newbestTransition = transition.to(bestCup,{timer=1000, alpha=1})
    -- TODO add victory sound
end

-------------------------------------- SCORES EVENTS -------------------------------------

---- :CREATE
function scene:create(event)

    local scoresScene = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Load the previous scores
    loadScores()

    -- Current best score is the first value of sorted table
    currentBest = scoresTable[1]

    -- Save this game score into local var
    finalScore = composer.getVariable("finalScore")
    -- Insert the saved score from the last game into the table
    table.insert(scoresTable, composer.getVariable("finalScore"))

    -- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end

    -- Return the bestscore
    bestscore = table.sort(scoresTable, compare)

    -- Reset current game score
    composer.setVariable("finalScore",0)


    -- With the table now sorted, let's save the data back out to scores.json by calling our saveScores() function
    saveScores()

    -- Background
    background = display.newImageRect("res/bckgrnd.png",900,1425)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = display.contentHeight
    background.speed = 4
    scoresScene:insert(background)

    -- GameOver image
    gameOver = display.newImageRect("res/gameOver.png",700,120)
    gameOver.anchorX = 0.5
    gameOver.anchorY = 0.5
    gameOver.x = display.contentCenterX
    gameOver.y = display.contentCenterY - 400
    gameOver.alpha = 0
    scoresScene:insert(gameOver)

    -- Rect with game scores
    gameScores = display.newImageRect("res/gameScores.png",480,393)
    gameScores.anchorX = 0.5
    gameScores.anchorY = 0.5
    gameScores.x = display.contentCenterX
    gameScores.y = display.contentHeight + 500
    scoresScene:insert(gameScores)

    -- Menu btn
    menu = display.newImageRect("res/menu_btn.png",400,100)
    menu.anchorX = 0.5
    menu.anchorY = 1
    menu.x = display.contentCenterX
    menu.y = display.contentCenterY + 400
    menu.alpha = 0
    scoresScene:insert(menu)

    -- Restart btn
    restart = display.newImageRect("res/restart_btn.png",200,200)
    restart.anchorX = 0.5
    restart.anchorY = 1
    restart.x = display.contentCenterX
    local bottomMarg = display.contentHeight - display.screenOriginY
    restart.y = bottomMarg - 50
    restart.alpha = 1
    scoresScene:insert(restart)

    -- Score of this game session
    scoreText = display.newText(finalScore,display.contentCenterX + 110,
        display.contentCenterY - 60, native.systemFont, 50)
    scoreText:setFillColor(0,0,0)
    scoreText.alpha = 0
    scoresScene:insert(scoreText)

    bestscoreText = display.newText(scoresTable[1],display.contentCenterX + 110,
        display.contentCenterY + 85, native.systemFont, 50)
    bestscoreText:setFillColor(0,0,0)
    bestscoreText.alpha = 0
    scoresScene:insert(bestscoreText)

    -- Cup for new best
    bestCup = display.newImageRect("res/bestCup.png",200,200)
    bestCup.anchorX = 0.5
    bestCup.anchorY = 1
    bestCup.x = display.contentCenterX - 90
    bestCup.y = display.contentCenterY + 90
    bestCup.alpha = 0
    scoresScene:insert(bestCup)

end

--- :SHOW
function scene:show( event )

    local scoresScene = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
        composer.removeScene("game")

        menu:addEventListener("touch", gotoMenu)
        restart:addEventListener("touch", restartGame)
        showGameOver()

        -- Updated table of scores
        loadScores()

        -- New record!!?
        if finalScore > currentBest then
            showNewBest()
            print("new_record!")
        end
    end
end

--- :HIDE
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        --
        menu:removeEventListener("touch", gotoMenu)
        restart:removeEventListener("touch", restartGame)
        transition.cancel(fadeTransition)
        transition.cancel(scoreTransition)
        transition.cancel(scoreTextTransition)
        transition.cancel(bestTextTransition)
        transition.cancel(menuTransition)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

--- :DESTROY
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

