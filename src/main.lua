local player = require('player')
local inv = require('inventory')
local ghelp = require('ghelp')
local draw = require('draw')
local items = require('item')
local collision = require('collision')
local hooks = require('hooks')

local talkies = require('talkies')
local dialog = require('dialog')

local questsys = require('questsys')
local sti = require ("sti")

local constants = require('constants')

-- Either 0 or 1 depending if inventory or skill is chosen.
local tab_index = 2

local inv_selected = {}
inv_selected.hover = {}
inv_selected.clicked = false
inv_selected.x = 0
inv_selected.y = 0
inv_selected.slot = nil

local tick = require("tick")
local classic = require ("classic")
local camera = require("camera")

--https://github.com/rxi/tick
--https://github.com/rxi/classic
--https://github.com/adnzzzzZ/STALKER-X
--https://github.com/Karai17/Simple-Tiled-Implementation

local function setup_talkies()
    talkies.textSpeed = "medium"
    talkies.padding = 20
    talkies.font = love.graphics.newFont("assets/fonts/Pixel UniCode.ttf", 32)
    talkies.talkSound = love.audio.newSource("assets/sound/sfx/talk.wav", "static")
    talkies.typedNotTalked = false
    talkies.pitchValues = {0.70, 0.72, 0.74, 0.76, 0.78, 0.80}
    love.audio.newSource("assets/sound/record_scratch.mp3", "static")
    --talkies.say(dialog[1].title, dialog[1].text, {image = player.talksprite})
    --talkies.say(dialog[2].title, dialog[2].text, {image = player.talksprite})
end

local function fill_inventory()
    local hpimage = love.graphics.newImage("assets/images/healthpotion.png")
    local mpimage = love.graphics.newImage("assets/images/manapotion.png")
    local swordimg = love.graphics.newImage("assets/images/sword.png")
    for i=1,constants.inventory.size,1 do
        if i%3 == 0 then
            local hp = items.new("Health Potion", hpimage, function(player)
                if player.health + 20 > 100 then player.health = 100 return end
                player.health = player.health + 20 end)
            
            inv:add(hp, false)
        elseif i%3 == 1 then
            local sword = items.new("Sword", swordimg, function(player)
                return end)
            sword.is_wearable = true
            sword.type = "l_hand"
            player:equip(sword)
            inv:add(sword, false)
        else
            local mp = items.new("Mana Potion", mpimage, function(player)
                if player.mana + 20 > 100 then player.mana = 100 return end
                player.mana = player.mana + 20 end)
                
            inv:add(mp, false)
        end
    end
end

local function create_torches()
    for i, v in ipairs(torchesIdx) do
        ypos = (math.ceil(v / 100))*32
        xpos = (v % 100)*32

        table.insert(torchesPositions, {xpos, ypos})
    end
end

-- Load some default values for our game.
function love.load()
    map = sti("maps/overworld.lua")
    imgs = ghelp.preloadimgs()
    player.sprite = imgs.player
    player.talksprite = imgs.nigel
    camera = camera()
    camera:setFollowStyle("TOPDOWN")

    setup_talkies()
    fill_inventory()

    torchesIdx = collision.getAllTorches()
    torchesPositions = {}
    create_torches()

    psystem = draw.init_particles()
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    tick.update(dt)
    map:update(dt)

    local newX, newY, dir = move(dt)
    local tileOne, tileTwo

    if dir then
        local x, y
        if dir == "up" then
            -- upper left
            x, y = map:convertPixelToTile(newX, newY)
            tileOne = collision.getTileType(math.ceil(x), math.ceil(y))
            -- upper right
            x, y = map:convertPixelToTile(newX+player.width, newY)
            tileTwo = collision.getTileType(math.ceil(x), math.ceil(y))

        elseif dir == "down" then
            -- lower left
            x, y = map:convertPixelToTile(newX, newY+player.height)
            tileOne = collision.getTileType(math.ceil(x), math.ceil(y))
            -- lower right
            x, y = map:convertPixelToTile(newX+player.width, newY+player.height)
            tileTwo = collision.getTileType(math.ceil(x), math.ceil(y))

        elseif dir == "left" then
            -- upper left
            x, y = map:convertPixelToTile(newX, newY)
            tileOne = collision.getTileType(math.ceil(x), math.ceil(y))
            -- lower left
            x, y = map:convertPixelToTile(newX, newY+player.height)
            tileTwo = collision.getTileType(math.ceil(x), math.ceil(y))

        elseif dir == "right" then
            -- upper right
            x, y = map:convertPixelToTile(newX+player.width, newY)
            tileOne = collision.getTileType(math.ceil(x), math.ceil(y))
            -- lower right
            x, y = map:convertPixelToTile(newX+player.width, newY+player.height)
            tileTwo = collision.getTileType(math.ceil(x), math.ceil(y))
        end

        local walkableOne = collision.isWalkable(tileOne-1)
        local walkableTwo = collision.isWalkable(tileTwo-1)

        if walkableOne == true and walkableTwo == true then
            player.x, player.y = newX, newY
        end
    end

    camera:update(dt)
    camera:follow(player.x, player.y)
    talkies.update(dt)
    psystem:update(dt)

end

function love.draw()
    camera:attach()
    
    map:draw(camera:toCameraCoords(0, 0))
    love.graphics.draw(player.sprite, player.x, player.y)
    for i, v in ipairs(torchesPositions) do
        love.graphics.draw(psystem, v[1]-16, v[2]-22)
    end
    
    camera:detach()
    
    draw.tabs(tab_index, inv_selected, player, inv)
    draw.bars(player.health, player.mana)
    
    talkies.draw()
end

function move(dt)
    local dx, dy = 0, 0
    local dir

    if love.keyboard.isDown('w') then
        dy = -1
        dir = "up"
    end
    if love.keyboard.isDown('s') then
        dy = 1
        dir = "down"
    end
    if love.keyboard.isDown('a') then
        dx = -1
        dir = "left"
    end
    if love.keyboard.isDown('d') then
        dx = 1
        dir = "right"
    end

    length = math.sqrt(dx^2 + dy^2)

    if length == 0 then
        return player.x, player.y, dir
    end

    dx, dy = dx/length, dy/length

    local y = player.y + (player.attributes.speed * dt * dy)
    local x = player.x + (player.attributes.speed * dt * dx)

    return x, y, dir
end

function love.keypressed(key)
    if key == "space" then talkies.onAction()
    elseif key == "up" then talkies.prevOption()
    elseif key == "down" then talkies.nextOption()
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    inv_selected.hover[1] = false
    inv_selected.hover[2] = false
    inv_selected.hover[3] = false

    if inv_selected.clicked then
        if (inv_selected.mirror and x > inv_selected.x - 60 and x < inv_selected.x) or
            (not inv_selected.mirror and x > inv_selected.x and x < inv_selected.x + 60) then
            if y > inv_selected.y and y < inv_selected.y + 51 then
                inv_selected.hover[math.floor((y-inv_selected.y) / 17) + 1] = true
            end
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if inv_selected.clicked then
            if (inv_selected.mirror and x > inv_selected.x - 60 and x < inv_selected.x) or
                (not inv_selected.mirror and x > inv_selected.x and x < inv_selected.x + 60) then
                if y > inv_selected.y and y < inv_selected.y + 51 then
                    option = math.floor((y-inv_selected.y) / 17) + 1
                    -- Option 1: Use, Option 2: Drop, Option 3: Cancel
                    if option == 1 then
                        if tab_index == 0 then
                            inv:use(inv_selected.slot, player)
                        else
                            local item = inv:get(inv_selected.slot)
                            player:equip(item)
                        end
                    elseif option == 2 then
                        inv:drop(inv_selected.slot)
                    elseif option == 3 then
                        inv_selected.clicked = false
                    end
                end
            end
        --- Checks whether we clicked on the inventory/skills tab.
        elseif x > 785 and y > 280 and y < 320 then
            if x < 905 then
                tab_index = 0
            else
                tab_index = 1
            end
        end

        inv_selected.hover[1] = false
        inv_selected.hover[2] = false
        inv_selected.hover[3] = false

        inv_selected.clicked = false
        inv_selected.mirror = false
    end

    if button == 2 and tab_index == 0 then
        if x > 785 and y > 320 then
            inv_selected.clicked = true
            inv_selected.x = x
            inv_selected.y = y
            
            local slot_x, slot_y = math.floor((inv_selected.x - 785)/80), math.floor((inv_selected.y - 320)/80)
            local slot = 1 + slot_x + slot_y * 3
            inv_selected.slot = slot

            if x > 1024 - 60 then
                inv_selected.mirror = true
            else
                inv_selected.mirror = false
            end
        else
            inv_selected.clicked = false
            inv_selected.mirror = false
        end
    end
    
    if button == 2 and tab_index == 2 then
        if x > 785 and y > 320 then
            inv_selected.clicked = true
            inv_selected.x = x
            inv_selected.y = y
            
        end    
    end
end
