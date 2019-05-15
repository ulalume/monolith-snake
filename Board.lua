local Cell = require "Cell"
local Board = {}

function Board:new(w,h)
  local data = {}
  for y=1, h do
    data[y] = {}
    for x=1, w do
      if love.math.random() < 0.001 then
        data[y][x]=Cell.Feed
      else
        data[y][x]=Cell.Empty
      end
    end
  end
  return setmetatable({
      data=data,w=w,h=h},
    {__index=self})
end
function Board:setCell(x,y,floor)
  self.data[y][x] = floor
end
function Board:getCell(x,y)
  return self.data[y][x]
end
function Board:draw()
  for y=1, self.h do
    for x=1, self.w do
      local cell = self:getCell(x,y)
      if Cell.Empty ~= cell then
        love.graphics.setColor(unpack(cell.color))
        love.graphics.points(x,y)
      end
    end
  end
end

function Board:clearFeed()
  for y=1, self.h do
    for x=1, self.w do
      local cell = self:getCell(x,y)
      if cell == Cell.Feed then
        self:setCell(x,y,Cell.Empty)
      end
    end
  end
end
return Board
