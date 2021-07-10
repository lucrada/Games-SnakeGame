function love.load() 
    math.randomseed(os.time())
    love.window.setTitle('Snake Game')
    local ico = love.image.newImageData('img/icons/titleicon.png')
    love.window.setIcon(ico)

    gameState = {
        ['startScreen'] = true, 
        ['gamePlay'] = false,
    }

    fonts = {}
    fonts.large = love.graphics.newFont('fonts/score_font.TTF', 64)
    fonts.score = love.graphics.newFont('fonts/score_font.TTF', 32)

    images = {}
    images.background = love.graphics.newImage('img/background/background.png')
    images.splash = love.graphics.newImage('img/splash/splash.png')

    sounds = {}
    sounds.background = love.audio.newSource('sounds/background.mp3', 'static')
    sounds.eat = love.audio.newSource('sounds/eat.wav', 'static')
    sounds.gameover = love.audio.newSource('sounds/gameover.mp3', 'static')

    sounds.background:setLooping(true)
    sounds.background:play()

    player = {}
    player.head = {
        ['up'] = love.graphics.newImage('img/snake/head_up.png'),
        ['down'] = love.graphics.newImage('img/snake/head_down.png'),
        ['left'] = love.graphics.newImage('img/snake/head_left.png'),
        ['right'] = love.graphics.newImage('img/snake/head_right.png'),
    }
    player.body = love.graphics.newImage('img/snake/body.png')
    player.activeHead = player.head.up
    player.width = 20
    player.height = 20
    player.x  = love.graphics.getWidth()/2 - 20
    player.y = love.graphics.getHeight()/2 - 20
    player.speed = 20
    player.hit = false
    player.tail = {}
    player.tail[1] = {
        ['x'] = player.x,
        ['y'] = player.y,
        ['direction'] = 'up',
    }

    food = {}
    food.img = love.graphics.newImage('img/food/apple.png')
    food.x = math.floor(math.random(0, 39)) * 20
    food.y = math.floor(math.random(0, 29)) * 20
    food.width = food.img:getWidth()
    food.height = food.img:getHeight()

    lastKey = nil
    score = 0
end

function love.update(dt)
    if love.keyboard.isDown('escape') then 
        love.event.quit()
    end

    if gameState.startScreen then 
        if love.keyboard.isDown('return') then 
            gameState.startScreen = false 
            gameState.gamePlay = true
        end
    elseif gameState.gamePlay then 

        love.timer.sleep(0.05)

        if love.keyboard.isDown('right') and lastKey ~= 'left' then
            player.activeHead = player.head.right
            lastKey = 'right'
            player.tail[1].direction = 'right'
        elseif love.keyboard.isDown('left') and lastKey ~= 'right' then 
            player.activeHead = player.head.left
            lastKey = 'left'
            player.tail[1].direction = 'left'
        elseif love.keyboard.isDown('up') and lastKey ~= 'down' then 
            player.activeHead = player.head.up
            lastKey = 'up'
            player.tail[1].direction = 'up'
        elseif love.keyboard.isDown('down') and lastKey ~= 'up' then 
            player.activeHead = player.head.down
            lastKey = 'down'
            player.tail[1].direction = 'down'
        end

        for i=#player.tail, 2, -1 do 
            player.tail[i].x = player.tail[i-1].x
            player.tail[i].y = player.tail[i-1].y
            player.tail[i].direction = player.tail[i-1].direction
        end

        for i=4, #player.tail, 1 do 
            if player.x+player.width > player.tail[i].x and 
            player.y+player.height > player.tail[i].y and 
            player.x < player.tail[i].x+player.width and 
            player.y < player.tail[i].y+player.height then 
                player.hit = true
                break
            end
        end

        if player.hit then 
            sounds.gameover:play()
            for i=#player.tail, 2, -1 do 
                table.remove(player.tail, i)
            end
            score = 0
            player.hit = false
        end

        if lastKey then
            if lastKey == 'right' then 
                player.x = player.x + player.speed 
                player.tail[1].x = player.x
            elseif lastKey == 'left' then
                player.x = player.x - player.speed 
                player.tail[1].x = player.x
            elseif lastKey == 'up' then
                player.y = player.y - player.speed 
                player.tail[1].y = player.y
            elseif lastKey == 'down' then
                player.y = player.y + player.speed 
                player.tail[1].y = player.y
            end
        else
            player.y = player.y - player.speed 
            player.tail[1].y = player.y
        end

        if player.x+player.width > love.graphics.getWidth() then 
            player.x = 0
        elseif player.x+player.width < 0 then 
            player.x = love.graphics.getWidth() - player.width
        elseif player.y > love.graphics.getHeight() then 
            player.y = 0
        elseif player.y+player.height < 0 then 
            player.y = love.graphics.getHeight() - player.height
        end

        if player.x+player.width > food.x and 
        player.y+player.height > food.y and 
        player.x < food.x+food.width and 
        player.y < food.y+food.height then 
            sounds.eat:play()
            food.x = math.floor(math.random(0, 39)) * 20
            food.y = math.floor(math.random(0, 29)) * 20
            score = score + 1
            local dir = nil 
            local x = nil 
            local y = nil 
            if player.tail[#player.tail].direction == 'right' then 
                dir = 'right'
                x = player.tail[#player.tail].x - player.width 
                y = player.tail[#player.tail].y
            elseif player.tail[#player.tail].direction == 'left' then 
                dir = 'left'
                x = player.tail[#player.tail].x + player.width 
                y = player.tail[#player.tail].y
            elseif player.tail[#player.tail].direction == 'up' then 
                dir = 'up'
                x = player.tail[#player.tail].x 
                y = player.tail[#player.tail].y + player.height
            elseif player.tail[#player.tail].direction == 'down' then 
                dir = 'down'
                x = player.tail[#player.tail].x
                y = player.tail[#player.tail].y - player.height
            end
            table.insert(player.tail, {
                ['x'] = x,
                ['y'] = y, 
                ['direction'] = dir
            })
        end
    end
end

function love.draw() 
    love.graphics.draw(images.background, 0, 0)

    if gameState.startScreen then 
        love.graphics.draw(images.splash, love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 - 280)
        love.graphics.setFont(fonts.large)
        love.graphics.print('Press Enter', love.graphics.getWidth()/2 - fonts.large:getWidth('Press Enter')/2, love.graphics.getHeight()/2 + 100)
    end

    if gameState.gamePlay then 
        love.graphics.reset()
        
        love.graphics.draw(player.activeHead, player.x, player.y)
        for i=2, #player.tail, 1 do 
            love.graphics.draw(player.body, player.tail[i].x, player.tail[i].y)
        end

        love.graphics.draw(food.img, food.x, food.y)

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(fonts.score)
        love.graphics.print('Score '..score, 10, 10)
    end
end