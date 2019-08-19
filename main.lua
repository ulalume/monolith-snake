package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local monolith = require "monolith.core".new({ledColorBits=2})

local Board = require "Board"
local Cell = require "Cell"

local Snake = require "Snake"
local Handler = require "Handler"

local Timer = require "util.timer"
local Colors = require "Colors"

local direction = require "Direction".direction

local shutdownkey = require "util.shutdownkey":new(monolith.input)

local resolution = { x = 128, y = 128 }

local board
local snakes

local feedTimer
local moveTimer
local speedTimer

local activeControllers
local musicSystem

function gameReset()
  local def_directions = {direction.up, direction.down, direction.left, direction.right}
  local def_positions = {
    {resolution.x / 2, resolution.y - 4},
    {resolution.x / 2, 4},
    {resolution.x - 4, resolution.y / 2},
    {4,                resolution.y / 2},
  }
  local def_colors = {{0,1,0}, {0,0,1}, {1,0,1}, {1,0,0}}

  snakes = {}
  for i, b in ipairs(activeControllers) do
    if b then
      table.insert(snakes, Snake:new(i,
        def_positions[i][1], def_positions[i][2],
        def_directions[i], def_colors[i],
        Handler.Key:new(i, monolith),
        board, musicSystem))
    end
  end

  feedTimer=Timer:new(0.7)
  moveTimer=Timer:new(0.12)
  speedTimer=Timer:new(1.0, 60)
end

function love.load(arg)
  if #arg ==0 then arg = {"-c", "1111"} end
  activeControllers = require "util.parse_arguments" (arg).activeControllers

  if require "util.osname" == "Linux" then
    for i,inp in ipairs(require "config.linux_input_settings") do monolith.input:setUserSetting(i, inp) end
  else
    for i,inp in ipairs(require "config.input_settings") do monolith.input:setUserSetting(i, inp) end
  end

  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')

  board = Board:new(resolution.x, resolution.y)

  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require("music.music_system"):new(activeControllers, devices, musicPathTable, priorityTable)

  love.timer.sleep(1.5)
  musicSystem:playAllPlayer("init")

  gameReset()
end

local quitTimer = Timer:new(2)
local allSnakeIsDied = false

function love.update(dt)
  musicSystem:update(dt)

  if allSnakeIsDied then
    if quitTimer:executable(dt) then
      love.event.quit()
    end
    return
  end

  if love.keyboard.isDown("0") then
    board:clearFeed()
  end

  local _allSnakeIsDied = true
  for _,snake in ipairs(snakes) do
    if snake.died == false then
      _allSnakeIsDied=false
    end
  end
  if _allSnakeIsDied then
    allSnakeIsDied = true
    return
  end

  for _,snake in ipairs(snakes) do
    snake:handleInput()
  end

  if moveTimer:executable(dt) then
    for _,snake in ipairs(snakes) do
      snake:move()
    end
  end

  if feedTimer:executable(dt) then
    local count = 10
    while count > 0 do
      local x = love.math.random(board.w)
      local y = love.math.random(board.h)
      if board:getCell(x,y) == Cell.Empty then
        board:setCell(x,y, Cell.Feed)
        break
      end
      count = count - 1
    end
  end

  if speedTimer:executable(dt) then
    moveTimer.time = moveTimer.time * 0.95
    feedTimer.time = feedTimer.time * 0.95
  end

  shutdownkey:update(dt)
end

function love.draw()

  monolith:beginDraw()
  board:draw()
  monolith:endDraw()

  love.graphics.print(love.timer.getFPS())
end

function love.quit()
  musicSystem:gc()
  require "util.open_launcher"()
end
