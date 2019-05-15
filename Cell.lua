local Colors = require "Colors"
local Cell={}


function Cell:new(color,item)
  return setmetatable({item=item,color=color},{__index=self})
end
function Cell:isEmpty()
  return self.item == nil
end
Cell.Empty = Cell:new(Colors.empty)
Cell.Feed = Cell:new(Colors.feed, 0)

return Cell
