screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

default_block_size = 20

player_movement_speed = 100
player_body_gap = 1

high_score = 0

function love.load ()

  -- Inicializa a Cor do Cenário
  love.graphics.setBackgroundColor(255,255,255)

  -- Inicializa a Cor das Linhas de Demarcação do Cenário.
  love.graphics.setColor(0,0, 0)

  -- Define os limites do cenário na tela. ( Xi , Yi )
  scenarioLimits = {
    10,20,
    10,screenHeight-10,
    screenWidth-10,screenHeight-10,
    screenWidth-10,20,
    10,20
  }

  -- Iniciliza o Jogador.
  player = {
    pos = {
      current = {
        x = screenWidth/2,
        y = screenHeight/2
      },
      previous = {
        x = nil,
        y = nil
      }
    },
    direction = {
      x = 0,
      y = -1,
    },
    body = {
      size = 0,
      blocks = {}
    }
  }

  food = {
    pos = {
      x = nil,
      y = nil
    },
    isAlive = false
  }

  -- Inicializa dois blocos ao Jogador e Inicializa comida no cenário.
  playerAddBlock()
  respawnPlayerFood()

  accumulator = { current = 0; limit= 0.25; }

end

-- Aumenta o comprimento do Jogador.
function playerAddBlock(n)

  if (n == nil) then
    n = 1
  end

  -- Estrutura do Novo Bloco.
  new_block = {
    pos = {
      current = {
        x = nil,
        y = nil
      },
      previous = {
        x = nil,
        y = nil
      }
    },
    direction = {
      x = player.direction.x,
      y = player.direction.y
    }
  }

  for i=1,n do
    if (player.body.size == 0) then
      new_block.pos.current.x = player.pos.current.x + ( default_block_size * player.direction.x ) + player_body_gap
      new_block.pos.current.y = player.pos.current.y + ( default_block_size * player.direction.y ) + player_body_gap
    else
      new_block.pos.current.x = player.pos.current.x + ( ( default_block_size * player.direction.x) * (player.body.size + 1) ) + player_body_gap
      new_block.pos.current.y = player.pos.current.y + ( ( default_block_size * player.direction.y) * (player.body.size + 1) ) + player_body_gap
    end

    table.insert(player.body.blocks,1,new_block)

    player.body.size = player.body.size + 1

    print("Criei Corpo no Player! : ")
    print(player.body.size)

  end

end

function respawnPlayerFood()

  food.pos.x = love.math.random(10, screenWidth - 20)
  food.pos.y = love.math.random(10, screenHeight - 20)
  food.isAlive = true

  print(food.pos.y)
  print(food.pos.x)

end

function gameOver()
  love.load()
  return true
end

function updatescore()
  if(player.body.size > high_score) then
    high_score = player.body.size
  end
end

function love.keypressed (key)


  if key == 'left' or key == 'd' then
    if player.direction.x ~=1 and player.direction.y ~=0 then
      player.direction.x = -1
      player.direction.y = 0
    end
  elseif key == 'right' then
    if player.direction.x ~=-1 and player.direction.y ~=0 then
      player.direction.x = 1
      player.direction.y = 0
    end
  elseif key == 'up' then
    if player.direction.x ~= 0 and player.direction.y ~=1 then
      player.direction.x = 0
      player.direction.y = -1
    end
  elseif key == 'down' then
    if player.direction.x ~= 0 and player.direction.y ~=-1 then
      player.direction.y = 1
      player.direction.x = 0
    end
  elseif key == 'f' then
    playerAddBlock()
  elseif key == '2' then
    player_movement_speed = player_movement_speed + 50
  elseif key == '1' then
    player_movement_speed = player_movement_speed - 50
  end
end

-- Jogador colidindo com as paredes.
function playerWallCollision ()

  --[[print(screenWidth-10)
  print(screenHeight-10)
  print("x")
  print(player.pos.current.x)

  print("y")
  print(player.pos.current.y)]]
  if player.pos.current.x <= 10 or player.pos.current.x >= screenWidth-10 - default_block_size  or player.pos.current.y <= 20  or player.pos.current.y >= screenHeight-10 -default_block_size then
    print("x" .. tostring(player.pos.current.x))
    print("y" .. tostring(player.pos.current.y))
    gameOver()
  end
end

-- Jogador colidindo com a comida.
function playerFoodCollision (player, food)
  if ( player.pos.current.x + default_block_size >= food.pos.x ) and ( player.pos.current.x <= food.pos.x + default_block_size) and ( player.pos.current.y + default_block_size >= food.pos.y) and ( player.pos.current.y <= food.pos.y + default_block_size ) then
    playerAddBlock()
    respawnPlayerFood()
  end
end

-- Jogador colidindo com ele mesmo.
function playerBodyCollision (player)
  return true
end

function love.update (dt)


  accumulator.current = accumulator.current +dt;

  player.pos.previous.x = player.pos.current.x
  player.pos.previous.y = player.pos.current.y

  player.pos.current.x =  player.pos.current.x + player.direction.x * player_movement_speed * dt
  player.pos.current.y =  player.pos.current.y + player.direction.y * player_movement_speed * dt


  if (accumulator.current >= accumulator.limit) then

    accumulator.current = accumulator.current-accumulator.limit;

    for i,block in ipairs(player.body.blocks) do

      block.pos.previous.x = block.pos.current.x
      block.pos.previous.y = block.pos.current.y

      if (i <= 1) then
        block.pos.current.x = player.pos.previous.x - ( default_block_size * 2 ) * player.direction.x * dt
        block.pos.current.y = player.pos.previous.y - ( default_block_size * 2 ) * player.direction.y * dt
      else
        block.pos.current.x = player.body.blocks[i-1].pos.previous.x - ( default_block_size * 2 ) * player.direction.x * dt
        block.pos.current.y = player.body.blocks[i-1].pos.previous.y - ( default_block_size *2 ) * player.direction.y * dt
      end
    end
  end


  playerWallCollision()
  playerFoodCollision(player,food)

  updatescore()

end

function drawPlayer()

  love.graphics.setColor(255, 0, 0, 180)

  -- Desenho do Jogador. ( Cabeça )
  love.graphics.rectangle( "fill", player.pos.current.x, player.pos.current.y, default_block_size, default_block_size )

  love.graphics.setColor(0, 0, 0, 255)


  -- Desenho do Corpo.
  for i,block in ipairs(player.body.blocks) do
    love.graphics.rectangle( "fill", block.pos.current.x, block.pos.current.y, default_block_size, default_block_size )
  end

  --Desenho do status
  love.graphics.print("Body Size " .. tostring(player.body.size) , 5, 5)
  love.graphics.print("Speed " .. tostring(player_movement_speed) , 150, 5)
  love.graphics.print("High Score " .. tostring(high_score) , screenWidth-150, 5)

  love.graphics.print("x " .. tostring(player.pos.current.x) , screenWidth-150, 20)
  love.graphics.print("y " .. tostring(player.pos.current.y) , screenWidth-150, 30)
end

function love.draw()

  -- Desenho do Cenário.
  love.graphics.line(scenarioLimits)

  -- Desenha o Jogador.
  drawPlayer()

  -- Desenho da Comida.
  if (food.isAlive) then
    love.graphics.setColor(0,0,255)
    love.graphics.rectangle( "fill", food.pos.x, food.pos.y, default_block_size, default_block_size )
  end
end
