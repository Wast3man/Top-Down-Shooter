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