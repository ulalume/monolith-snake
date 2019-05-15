local Direction = {right=1,up=2,left=3,down=4}
local DirectionPos = {
  {1,0},
  {0,-1},
  {-1,0},
  {0,1}
}
local function reverse (d)
  d = d + 2
  if d > 4 then d = d - 4 end
  return d
end
local function rotate(d, clock)
  clock = clock or true
  if clock then
    d=d-1
  else
    d=d+1
  end
  if d > 4 then d = d - 4 end
  if d < 1 then d = d + 4 end
  return d
end

return {
  names={"right","up","left","down"},
  direction=Direction,
  position=DirectionPos,
  reverse=reverse,
  rotate=rotate,
}
