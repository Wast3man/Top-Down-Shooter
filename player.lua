
player = {}
bullets = {}

gunshot = love.audio.newSource("boom.mp3", "static")

-- Create player
function player.create()
 -- Sprite with player
 player.img = love.graphics.newImage("player.png")

 -- Coordinates X & Y - center of screen
 local x, y = love.graphics.getDimensions()
 x = x / 2
 y = y /2

 -- Shape & body
 player.shape = love.physics.newCircleShape(24)  -- circle with radius 24
 player.body = love.physics.newBody(world, x, y, "kinematic")

 -- Fixture shape with body and set mass 5
 player.fix = love.physics.newFixture(player.body, player.shape, 5)

 -- This time will be used for delay between shots 
 player.shoot_time = love.timer.getTime()
end

-- Draw player, this function will be called from love.draw()
function player.draw()
 -- Local image point 0,0 is in left-top corner, 
 -- that mean it's need to move image left to 1/4 width and move down to 1/2 
 -- height. In this way center of human on image will be at center of player 
 -- body. 
 local draw_x, draw_y = player.body:getWorldPoint(-21.25, -26.5)
 -- When drawing angle image like body's angle
 love.graphics.draw(player.img, draw_x, draw_y, player.body:getAngle())
end

-- Shooting
function player.shoot()
 -- Man on player sprite angle to right. 
 -- Get point that will be little right and below man's center
 local x, y = player.body:getWorldPoint(65, 5)

 -- Bullet's direction vector coordinates
 local lx, ly = player.body:getWorldVector(400, 0)

 -- Index for new bullet in bullets table
 local i = #bullets + 1

 -- Create bullet
 bullets[i] = BulletClass:new(x, y, lx, ly)
 bullets[i]:create()
end

-- Update player, function will be called from love.update(dt)
function player.update(dt)
 
 -- Local vars for easy access to functions
 local is_down_kb = love.keyboard.isDown
 local is_down_m = love.mouse.isDown

 -- Get current player's position
 local x, y = player.body:getPosition()

 -- Moving
 -- Because local center of player placed in center of player's body,
 -- limit for moving by X are (0 + player's width/2) and 
 -- (screen's width - player's width / 2)
 if is_down_kb("a") and (x > 26) then
  x = x - 100*dt  -- left
 elseif is_down_kb("d") and (x < love.graphics.getWidth() - 26) then
  x = x + 100*dt  -- right
 end

 if is_down_kb("w") and (y > 42) then
  y = y - 100*dt  -- up
 elseif is_down_kb("s") and (y < love.graphics.getHeight() - 42) then
  y = y + 100*dt  -- down
 end

 -- Update position
 player.body:setPosition(x, y)

 -- Angle player to mouse cursor position
 local direction = math.atan2(love.mouse.getY() - y, love.mouse.getX() - x)
 player.body:setAngle(direction)

 -- Shooting
 if is_down_m(1) then
  -- If last show was second ago or more then shoot
  if math.floor(love.timer.getTime() - player.shoot_time) >= 1 then
   player.shoot()
   player.shoot_time = love.timer.getTime()
   pitchMod = 0.8 + love.math.random(0, 10)/25
   gunshot:setPitch(pitchMod)
   gunshot:play()
  end
 end
end

-- Bullet
BulletClass = {}
-- At object creating it got attributes x & y with position and attributes
-- lx & ly with coordinates for vector of bullet's moving direction 
function BulletClass:new(x, y, lx, ly)
 local new_obj = {x = x, y = y, lx = lx, ly = ly}
 self.__index = self
 return setmetatable(new_obj, self) 
end

-- In this method creates body, shape and fixture
function BulletClass:create()
 -- Body
 self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
 self.body:setBullet(true)  -- mark that is's bullet

 -- Shape
 self.shape = love.physics.newCircleShape(5)

 -- Fixture body with shape and set mass 0.1 
 self.fix = love.physics.newFixture(self.body, self.shape, 0.1)
 -- Set fixture's user data "bullet"
 self.fix:setUserData("bullet")

 -- Start bullet's moving by setting it's linear velocity
 self.body:setLinearVelocity(self.lx, self.ly)
end

-- This method will be called from love.update()
function BulletClass:update(dt)

 -- Bullet position
 local x, y = self.body:getPosition()

 -- If bullet leave screen or collides with other body, delete it

 -- Because bullet's local point 0,0 in center of body, in 0,0 point half of 
 -- bullet will be still on screen. Bullet fully leave screen
 -- at -(bullet's radius) or (screen width/height + bullet's radius) point,
 -- bullet's radius is 5. 
 if x < - 5 or x > (love.graphics.getWidth() + 5) or 
  y < -5 or y > (love.graphics.getHeight() + 5) or
  not self.fix:getUserData() then
   self:destroy()
 end

end

-- This method will be called from love.draw()
function BulletClass:draw()
 -- Draw filled circle
 love.graphics.circle("fill", self.body:getX(), self.body:getY(), 
                         self.shape:getRadius())
end

-- Destroy bullet
function BulletClass:destroy()
 -- Make object = nil will destroy object
 -- Using "for" loop with step = 1, because it's work faster then ipairs
 for i = 1, #bullets, 1 do
  if self == bullets[i] then
   bullets[i] = nil
  end
 end
end