-- Welcome to Crazy WallBouce!
--Only have basic and portal ball movement
--keep audio to 0.05
push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
     love.graphics.setDefaultFilter('nearest', 'nearest')

     love.window.setTitle('Wall Bounce')

     math.randomseed(os.time())                                  

     smallFont = love.graphics.newFont('font.ttf', 8) --size 8

     scoreFont = love.graphics.newFont('font.ttf', 24) --size 24

     largeFont = love.graphics.newFont('font.ttf', 40)

     sounds = {
          ['paddle_hit'] = love.audio.newSource('sounds/paddlhit.wav', 'static'),
          ['score'] = love.audio.newSource('sounds/scor3.wav', 'static'),
          ['wall_hit'] = love.audio.newSource('sounds/wallhit.wav', 'static'),
          ['teleport'] = love.audio.newSource('sounds/teleport.wav', 'static')
     }

     push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
          fullscreen = false,
          resizeable = true,
          vsync = true,
     })

     playerScore = 0

     servingPlayer = 1

--intialize player paddles using the class
     player = Paddle(10, 30, 5, 20)
     

--initialize ball using the class
     ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

     gameState = 'start'

     ballState = 'basic'
end

function love.resize(w, h)
     push:resize(w, h)
end

function love.update(dt)
     if gameState == 'serve' then
          ball.dy = math.random(-50, 50)
          if servingPlayer == 1 then 
               ball.dx = math.random(140, 200)
     
          else
               ball.dx = -math.random(140, 200)
          end
     
     elseif gameState == 'play' then
          if ball:collides(player) then
               ball.dx = -ball.dx * 1.02
               --the 5 is necessary so that it will take the ball outside of the collision box of the paddle
               ball.x = player.x + 5

               --keep velocity moving in the same direction but randomize in
               if ball.dy < 0 then
                    --ensures that if the y velocity is hittin the paddle at a negative direction it will bounce off in a negative direction
                    ball.dy = -math.random(10, 150)
               else
                    --same applies here for if it hits in a positive direction
                    ball.dy = math.random(10, 150)
               end
               playerScore = playerScore + 1

               sounds['paddle_hit']:play()
          end

          if ballState == 'basic' then 
               --when ball hits top of screen
               if ball.y <= 0 then
                    ball.y = 0
                    ball.dy = -ball.dy
                    sounds['wall_hit']:play()
               end
               --when ball hits bottom of screen
               if ball.y >= VIRTUAL_HEIGHT -4 then
                    ball.y = VIRTUAL_HEIGHT -4
                    ball.dy = -ball.dy
                    sounds['wall_hit']:play()
               end
          end

          if playerScore%2 == 1  then
               ballState = 'portal'
          else
               ballState = 'basic'
          end

          if ballState == 'portal' then
               --when ball hits top of screen
               if ball.y <= 0 then
                   ball.y = VIRTUAL_HEIGHT - 5
                   sounds['teleport']:play()
              end
              --when ball hits bottom of screen
              if ball.y >= VIRTUAL_HEIGHT -4 then
                   ball.y = 0
                   sounds['teleport']:play()
              end
         end

          --when ball hits right wall
          if ball.x >= VIRTUAL_WIDTH -4 then
               ball.dx = -ball.dx * 1.05
               --the 5 is necessary so that it will take the ball outside of the collision box of the paddle
               --ball.x = player.x -4

               if ball.dy < 0 then
                    --ensures that if the y velocity is hittin the paddle at a negative direction it will bounce off in a negative direction
                    ball.dy = -math.random(10, 150)
               else
                    --same applies here for if it hits in a positive direction
                    ball.dy = math.random(10, 150)
               end

               sounds['paddle_hit']:play()
          end

          --when ball hits left wall
          if ball.x <= 0 then
               gameState = 'done'
          end
     end

     --player movement
     if love.keyboard.isDown('w') then
          player.dy = -PADDLE_SPEED
     elseif love.keyboard.isDown('s') then
          player.dy = PADDLE_SPEED
     else
     --so that the paddle stops moving
          player.dy = 0
     end
               
     if gameState == 'play' then
          ball:update(dt)
     end

     player:update(dt)
          
end

function love.keypressed(key) 
     if key == 'escape' then
          love.event.quit()
     elseif key == 'enter' or key == 'return' then
          if gameState == 'start' then
               gameState = 'serve'
          elseif gameState == 'serve' then 
               gameState = 'play'
                    
          elseif gameState == 'done' then
               gameState = 'serve'
               ballState = 'basic'

               ball:reset()

               playerScore = 0
          end
     end
end

function love.draw()
     push:apply('start')

     love.graphics.clear(40/255, 45/255, 52/255, 255/255) -- (r, g, b, opacity)

     love.graphics.setFont(smallFont)

    

     if gameState == 'start' then 
          love.graphics.setFont(smallFont)
          love.graphics.printf('Welcome to Crazy WallBouce!', 0, 10, VIRTUAL_WIDTH, 'center')  --center aligned
          love.graphics.printf("Press Enter to start!", 0, 20, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'play' then
          displayPlayerScore()
     elseif gameState == 'serve' then
          love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'done' then
          love.graphics.setFont(smallFont)
          love.graphics.printf('Longest Streak was '.. tostring(playerScore) .. "!", 0, 10, VIRTUAL_WIDTH, 'center')
          love.graphics.setFont(smallFont)
          love.graphics.printf("Press Enter to Restart!", 0, 20, VIRTUAL_WIDTH, 'center')
     end

--render paddle
     player:render()

--render ball (center)
     ball:render()
--love.graphics.rectangle('fill', VIRTUAL_WIDTH/2-2, 10, 20, 5)
     displayFPS()
     displayballState()

     push:apply('end')
end

function displayFPS()
     love.graphics.setFont(smallFont)
     love.graphics.setColor(0, 255, 0, 255)
-- .. operator is used to concatenate in lua
     love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)

end

function displayPlayerScore()
     love.graphics.setFont(scoreFont)
     love.graphics.print(tostring(playerScore), VIRTUAL_WIDTH-20, 10)
end

function displayballState()
     love.graphics.setFont(smallFont)
     love.graphics.print('Ball Behavior: ' .. ballState, 20, 20)
end
