require("player")
require("enemies")

-------------------------------------------------------------------------------
-- Main callbacks 
-------------------------------------------------------------------------------
function love.load()
 -- Create world and set callbacks for it
 world = love.physics.newWorld(0, 0, true)
 world:setCallbacks(beginContact, endContact, preSolve, postSolve)
 
 cursor = love.mouse.newCursor("crosshair.png", 5, 5)
 love.mouse.setCursor(cursor)
 
 -- Load background
 backgroundImage = love.graphics.newImage("background.png")
 
 -- Create player
 player.create()
 
 -- Load and play ambient music
 music = love.audio.newSource("ambient.mp3", "static")
 
    music:setLooping(true)
    music:play()

 -- Time for calculating delay betweeb enemies creation
 -- We will create new enemy per 5 seconds
 time = love.timer.getTime()

 -- Killed enemies
 killed = 0
end

function love.update(dt)
 -- Update world
 world:update(dt)

 -- Update player
 player.update(dt)

 -- Create new enemy per 5 seconds
 if math.floor(love.timer.getTime() - time) >= 4 then
  -- Add enemy to enimes table with index = table length + 1
  enemies[#enemies + 1] = EnemyClass:new()
  -- Once enemy added to table he has last index in table = table length
  enemies[#enemies]:create()
  -- Update time for calculation new 5 seconds delay
  time = love.timer.getTime()
 end

 -- Update enemies
 for _, enemy in pairs(enemies) do
  enemy:update(dt)
 end

 -- Update bullets
 for _, bullet in pairs(bullets) do
  bullet:update(dt)
 end
end

function love.draw()
 --Draw background
 love.graphics.draw(backgroundImage, 0, 0)
 
 -- Draw player
 player.draw()

 -- Draw enemies
 for _, enemy in pairs(enemies) do
  enemy:draw()
 end
 -- Draw bullets 
 for _, bullet in pairs(bullets) do
  bullet:draw()
 end


 function love.keyboard.keyPressed(key)
    if key == 'escape' then 
        love.event.quit()
    end 
end


 -- Print how much enemies were killed
 love.graphics.print("Killed: "..killed, 30, 30)
end

-------------------------------------------------------------------------------
-- Physics world callbacks
-------------------------------------------------------------------------------
function beginContact(a, b, coll)

 local enemy, bullet

 -- Check what objects colliding
 if a:getUserData() == "enemy" then
  enemy = a
 elseif b:getUserData() == "enemy" then
  enemy = b
 end

 if a:getUserData() == "bullet" then
  bullet = a
 elseif b:getUserData() == "bullet" then
  bullet = b
 end

 -- If enemy collides with bullet
 if bullet and enemy then
  -- Set false to both userDatas. That will execute self:destroy() in
  -- bullet object and set animation to self.anm_death in enemy object, 
  -- after animation playing end will executed self.destroy() for enemy
  bullet:setUserData(false)
  enemy:setUserData(false)
  killed = killed + 1
 end
 -- Else one of variables will nil and colliding will not processed
end

function endContact(a, b, coll)
    --
end

function preSolve(a, b, coll)
    --
end

function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
    --
end

