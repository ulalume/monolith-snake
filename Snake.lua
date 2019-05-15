local Colors = require "Colors"
local Direction = require "Direction"
local Cell = require "Cell"

local Snake = {}
function Snake:new(index, x,y,direction,color,handler,board, musicSystem)
  local t = {
    index = index,
    x=x, y=y,
    color=color,
    handler=handler,
    board=board,
    dying=false,
    died=false,
    length=15,
    moveCount = 0,
    direction=direction or Direction.direction.up,
    musicSystem = musicSystem,
    body={{x=x,y=y}}
  }

  board:setCell(x,y, Cell:new(color, t))
  return setmetatable(t, {__index=self})
end
function Snake:handleInput()
  local success, dir = self.handler:execute(self)
  if success then
    self.direction = dir
  end
end
function Snake:move()
  if self.died then return
  elseif self.dying then self:die(); return end

  self.board:setCell(self.x,self.y,Cell:new(self.color, 0))

  local pos = Direction.position[self.direction]
  self.x=self.x+pos[1]
  self.y=self.y+pos[2]

  if self.x > self.board.w or self.x < 1 or self.y > self.board.h or self.y < 1 then
    self.dying = true
    return
  end

  local cell = self.board:getCell(self.x, self.y)
  if cell == Cell.Feed then
    self.length = self.length + 10

    self.musicSystem:play(self.index, "feed")
  elseif cell ~= Cell.Empty then
    self.dying = true
    if type(cell.item) == "table" then
      cell.item.dying = true
    end

    return
  else
    self.moveCount = self.moveCount  + 1
    if self.moveCount % 5 == 0 then
      self.musicSystem:play(self.index, "move")
    end
  end

  table.insert(self.body,{x=self.x,y=self.y})
  self.board:setCell(self.x,self.y,Cell:new(self.color, self))

  while #self.body > self.length do
    local f = table.remove(self.body, 1)
    self.board:setCell(f.x,f.y,Cell.Empty)
  end
  self.handler:reset()
end


function Snake:die()
  self.died=true
  for _, pos in ipairs(self.body) do
    self.board:setCell(pos.x,pos.y,Cell.Feed)
  end
  if not( self.x > self.board.w or self.x < 1 or self.y > self.board.h or self.y < 1) then
      self.board:setCell(self.x,self.y,Cell.Feed)
  end
  self.musicSystem:play(self.index, "death")
end

return Snake
