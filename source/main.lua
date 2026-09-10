import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics
local math = math

-- Game constants
local SCREEN_WIDTH = 400
local SCREEN_HEIGHT = 240
local CONVEYOR_HEIGHT = 50
local CONVEYOR_Y = SCREEN_HEIGHT - CONVEYOR_HEIGHT
local SUSHI_WIDTH = 30
local SUSHI_HEIGHT = 20
local OBSTACLE_WIDTH = 25
local OBSTACLE_HEIGHT = 25

-- Obstacle types
local OBSTACLES = {
    soy_sauce = 1,
    chopsticks = 2,
    bowl = 3,
    plate = 4,
    ginger = 5,
    wasabi = 6
}

local OBSTACLE_NAMES = {
    [1] = "Soy Sauce",
    [2] = "Chopsticks",
    [3] = "Bowl",
    [4] = "Plate",
    [5] = "Ginger",
    [6] = "Wasabi"
}

-- Game state
local sushi = {
    x = SCREEN_WIDTH / 2 - SUSHI_WIDTH / 2,
    y = CONVEYOR_Y + (CONVEYOR_HEIGHT - SUSHI_HEIGHT) / 2,
    width = SUSHI_WIDTH,
    height = SUSHI_HEIGHT,
    speed = 6
}

local obstacles = {}
local score = 0
local gameRunning = true
local gameSpeed = 3
local maxGameSpeed = 8
local speedIncreaseThreshold = 500
local lastSpeedIncrease = 0
local spawnRate = 60
local minSpawnRate = 20

function init()
    playdate.display.setRefreshRate(30)
    math.randomseed(playdate.getSecondsSinceEpoch())
    
    sushi.x = SCREEN_WIDTH / 2 - SUSHI_WIDTH / 2
    score = 0
    gameSpeed = 3
    spawnRate = 60
end

function spawnObstacle()
    local obstacle = {
        x = SCREEN_WIDTH,
        y = CONVEYOR_Y + (CONVEYOR_HEIGHT - OBSTACLE_HEIGHT) / 2,
        width = OBSTACLE_WIDTH,
        height = OBSTACLE_HEIGHT,
        speed = gameSpeed,
        type = math.random(1, 6)
    }
    table.insert(obstacles, obstacle)
end

function checkCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

function update()
    if not gameRunning then return end
    
    -- Crank control for sushi movement
    local crankChange = playdate.getCrankChange()
    if crankChange ~= 0 then
        sushi.x = sushi.x + crankChange * 0.6
        
        -- Boundary checking
        if sushi.x < 0 then
            sushi.x = 0
        elseif sushi.x + sushi.width > SCREEN_WIDTH then
            sushi.x = SCREEN_WIDTH - sushi.width
        end
    end
    
    -- Increase game speed based on score
    if score - lastSpeedIncrease >= speedIncreaseThreshold and gameSpeed < maxGameSpeed then
        gameSpeed = gameSpeed + 0.5
        spawnRate = math.max(minSpawnRate, spawnRate - 2)
        lastSpeedIncrease = score
    end
    
    -- Update obstacles
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x = obs.x - obs.speed
        
        -- Check collision with sushi
        if checkCollision(sushi, obs) then
            gameRunning = false
        end
        
        -- Remove off-screen obstacles and increment score
        if obs.x + obs.width < 0 then
            table.remove(obstacles, i)
            score = score + 1
        end
    end
    
    -- Spawn new obstacles
    if math.random(1, spawnRate) == 1 then
        spawnObstacle()
    end
end

function draw()
    gfx.clear()
    
    -- Draw conveyor belt
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, CONVEYOR_Y, SCREEN_WIDTH, CONVEYOR_HEIGHT)
    
    -- Draw conveyor belt pattern
    gfx.setColor(gfx.kColorWhite)
    for i = 0, SCREEN_WIDTH, 40 do
        gfx.drawLine(i, CONVEYOR_Y, i, CONVEYOR_Y + CONVEYOR_HEIGHT)
    end
    
    -- Draw sushi (simple rectangle for now)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(sushi.x, sushi.y, sushi.width, sushi.height)
    
    -- Draw sushi details (rice texture)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(sushi.x + 2, sushi.y + 2, sushi.width - 4, sushi.height - 4)
    
    -- Draw obstacles
    for i, obs in ipairs(obstacles) do
        drawObstacle(obs)
    end
    
    -- Draw UI
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText("Score: " .. score, 10, 10)
    gfx.drawText("Speed: " .. string.format("%.1f", gameSpeed), 10, 25)
    
    -- Draw game over screen
    if not gameRunning then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        
        gfx.setColor(gfx.kColorWhite)
        gfx.drawText("GAME OVER", SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2 - 40)
        gfx.drawText("Final Score: " .. score, SCREEN_WIDTH / 2 - 55, SCREEN_HEIGHT / 2 - 10)
        gfx.drawText("Press B to Restart", SCREEN_WIDTH / 2 - 75, SCREEN_HEIGHT / 2 + 20)
    end
end

function drawObstacle(obs)
    gfx.setColor(gfx.kColorBlack)
    
    if obs.type == OBSTACLES.soy_sauce then
        -- Draw soy sauce bottle
        gfx.fillRect(obs.x + 5, obs.y, obs.width - 10, obs.height)
        gfx.fillRect(obs.x + 8, obs.y - 3, obs.width - 16, 3)
    elseif obs.type == OBSTACLES.chopsticks then
        -- Draw chopsticks
        gfx.drawLine(obs.x + 5, obs.y, obs.x + 8, obs.y + obs.height)
        gfx.drawLine(obs.x + 15, obs.y, obs.x + 18, obs.y + obs.height)
    elseif obs.type == OBSTACLES.bowl then
        -- Draw bowl
        gfx.drawRect(obs.x + 2, obs.y + 5, obs.width - 4, obs.height - 8)
        gfx.drawLine(obs.x + 5, obs.y + 5, obs.x + obs.width - 5, obs.y + 5)
    elseif obs.type == OBSTACLES.plate then
        -- Draw plate (circle)
        gfx.drawCircle(obs.x + obs.width / 2, obs.y + obs.height / 2, obs.width / 2)
    elseif obs.type == OBSTACLES.ginger then
        -- Draw ginger (wavy shape)
        gfx.fillRect(obs.x + 3, obs.y + 5, obs.width - 6, obs.height - 10)
        gfx.fillRect(obs.x + 2, obs.y + 10, obs.width - 4, 3)
    elseif obs.type == OBSTACLES.wasabi then
        -- Draw wasabi (triangle-like)
        gfx.fillTriangle(obs.x + obs.width / 2, obs.y, obs.x, obs.y + obs.height, obs.x + obs.width, obs.y + obs.height)
    end
end

function playdate.update()
    if not gameRunning then
        if playdate.buttonJustPressed(playdate.kButtonB) then
            init()
            obstacles = {}
            gameRunning = true
        end
    else
        update()
    end
    
    draw()
end

init()
