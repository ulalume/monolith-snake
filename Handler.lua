local Cell = require("Cell")

local Direction = require("Direction")

local calcDirection = require "util.calc_direction"


local names = Direction.names
local direction = Direction.direction
local position = Direction.position
local reverse = Direction.reverse
local rotate = Direction.rotate


local KeyHandler={}
function KeyHandler:new(user, monolith)
  return setmetatable({user=user, monolith=monolith, first=true},{__index=self})
end
function KeyHandler:execute(snake)
  if self.first then
    self.first = false
    self.dirReversed = reverse(snake.direction)
  end
  for dir,name in ipairs(names) do
    if self.monolith.input:getButtonDown(self.user, calcDirection(self.user, name)) then
      if dir ~= self.dirReversed then
        return true, dir
      end
    end
  end
  return false
end
function KeyHandler:reset()
  self.first = true
end

local DebugAIHandler={}
function DebugAIHandler:new()
  return setmetatable({executed=false},{__index=self})
end
function DebugAIHandler:reset()
  self.executed=false
end
function DebugAIHandler:execute(snake)
  if self.executed then return false end
  self.executed = true

  return true, snake.direction
end

local SimpleAIHandler={}
function SimpleAIHandler:new()
  return setmetatable({executed=false},{__index=self})
end
function SimpleAIHandler:reset()
  self.executed=false
end
function SimpleAIHandler:execute(snake)
  if self.executed then return false end
  self.executed = true

  if love.math.random() < 0.02 then
    return true, rotate(snake.direction,love.math.random()<0.5)
  end

  local x = snake.x
  local y = snake.y

  for i=0,2 do
    local pos = position[snake.direction]
    x=x+pos[1]
    y=y+pos[2]

    if x > snake.board.w or x < 1 or y > snake.board.h or y < 1 then
      return true, rotate(snake.direction,love.math.random()<0.5)
    end
    local cell = snake.board:getCell(x,y)
    if cell ~= Cell.Empty and cell ~= Cell.Feed then
      return true, rotate(snake.direction,love.math.random()<0.5)
    end
  end
  return false
end

return {
  Key=KeyHandler,
  AI=SimpleAIHandler,
  DebugAI=DebugAIHandler,
}
