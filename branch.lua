local blacklist = {'computercraft:turtle_normal','minecraft:stone','minecraft:diorite', 'minecraft:dirt', 'minecraft:cobblestone','minecraft:lava','minecraft:water','minecraft:gravel','minecraft:andesite', 'minecraft:granite','minecraft:obsidian'}

local Args = {...}

local lastslot = 16

local function contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
end

local function refuel()
    if turtle.getFuelLevel() <= 100 then
        local count = 0
        while true do
            if turtle.refuel() == false then
                if turtle.getSelectedSlot() == 16 then
                    turtle.select(1)
                else
                    turtle.select(turtle.getSelectedSlot()+1)
                end
                count = count + 1
            else
                print(turtle.getFuelLevel)
                break   
            end
            if count >= 16 then
                print("Out of Fuel")
                print(turtle.getFuelLevel())
                turtle.select(1)
                while turtle.getFuelLevel() <= 100 do
                    sleep(2)
                    turtle.refuel()
                end
                break
            end
        end
    end
end

local function checkFull()
    turtle.select(lastslot)
    if turtle.getItemCount >= 1 then
        --add
    end
end


local function smartDig(drec)
    if drec == 1 then
        while turtle.detectUp() do
            local bol, data = turtle.inspectUp()
            local count = 0
            while data.name == "computercraft:turtle_normal" do
                bol, data = turtle.inspectUp()
                print("MOVE")
                sleep(0.5)
                count = count + 1
                if count >= 10 then
                    turtle.digDown()
                    turtle.down()
                    sleep(2)
                    turtle.up()
                    count = 0
                end
            end
            turtle.digUp()
        end
    elseif drec == 2 then
        if turtle.detectDown() then
            local bol, data = turtle.inspectDown()
            while data.name == "computercraft:turtle_normal" do
                bol, data = turtle.inspectDown()
                print("MOVE")
                sleep(0.5)
            end
            turtle.digDown()
        end
    else
        while turtle.detect() do
            local bol, data = turtle.inspect()
            while data.name == "computercraft:turtle_normal" do
                bol, data = turtle.inspect()
                print("MOVE")
                sleep(0.5)
            end
            turtle.dig()
        end
    end
end

local function spin(drec)
    if drec == 3 then
        turtle.turnRight()
    elseif drec == 1 then
        turtle.turnLeft()
    else
        turtle.turnLeft()
        turtle.turnLeft()
    end
end

local function smartMove(drec)
    if drec == 1 then
        while turtle.up() == false do
            smartDig(1)
            turtle.attackUp()
            refuel()
        end
    elseif drec == 2 then
        while turtle.down() == false do
        smartDig(2)
        turtle.attackDown()
        refuel()
        end
    elseif drec == 3 then
        if turtle.back() == false then
            spin()
            smartDig()
            refuel()
            while turtle.forward() == false do 
                turtle.attack()
            end
            spin()
        end
    else
        while turtle.forward() == false do 
            smartDig()
            turtle.attack()
            refuel()
        end
    end
end

local function check(drec) 
    if drec == 1 then
        local success, data = turtle.inspectUp() 
        if success then
            if contains(blacklist, data.name) == false then
                smartDig(1)
                return true 
            end
        end
    elseif drec == 2 then
        local success, data = turtle.inspectDown() 
        if success then
            if contains(blacklist, data.name) == false then
                smartDig(2)
                return true
             end
        end

    else
        local success, data = turtle.inspect()
        if success then
            if contains(blacklist, data.name) == false then
                smartDig()
                return true
            end
        end
    end
end

local function selectBlock()
    local count = 0
    while count <= 16 do 
        local data = turtle.getItemDetail()
        if data == nil then
            if turtle.getSelectedSlot() == 16 then
                turtle.select(1)
            else
                turtle.select(turtle.getSelectedSlot()+1)
            end
            count = count + 1
        elseif contains(blacklist, data.name) == false then
            if turtle.getSelectedSlot() == 16 then
                turtle.select(1)
            else
                turtle.select(turtle.getSelectedSlot()+1)
            end
            count = count + 1
        else
            return true
        end
        if count == 16 then
            return false
        end
    end
end

local function checkX()
    local x = 0
    local xx = 0
    local z = 0
    while check() do
        smartMove()
        spin(1)
        while check() do
            smartMove()
            while check(1) do
                smartMove(1)
                z = z + 1
            end
            for i = 1, z do
                smartMove(2)
            end
            z = 0
            while check(2) do
                smartMove(2)
                z = z + 1
            end
            for i = 1, z do
                smartMove(1)
            end
            z = 0
            xx = xx + 1 
        end
        for i = 1, xx do
            smartMove(3)
        end
        xx = 0
        spin()
        while check() do
            smartMove()
            while check(1) do
                smartMove(1)
                z = z + 1
            end
            for i = 1, z do
                smartMove(2)
            end
            z = 0
            while check(2) do
                smartMove(2)
                z = z + 1
            end
            for i = 1, z do
                smartMove(1)
            end
            z = 0
            xx = xx + 1 
        end
        for i = 1, xx do
            smartMove(3)
        end
        xx = 0
        spin(1)
        x = x + 1
    end
    for i = 1, x do
        smartMove(3)
    end
    
    x = 0
end

local function checkY()
    spin(1)
   checkX()
   spin()
   checkX()
   spin(1)
end

local function checkZ()
    local z = 0
    while check(1) do
        smartMove(1)
        checkY()
        z = z + 1
    end
    for i = 1, z do
        smartMove(2)    
    end
    z = 0
    while check(2) do
        smartMove(2)
        checkY()
        z = z + 1
    end
    for i = 1, z do
        smartMove(1)    
    end
    z = 0
end

local function checkF()
    local x = 0
    while check() do
        smartMove()
        checkZ()
        checkY()
        x = x + 1
    end
    for i = 1, x do
        smartMove(3)
    end
    x = 0
    
end


for l = 1, Args[1] do
    smartDig()
    smartMove()
    checkZ()
    spin(1)
    checkF()
    smartDig(1)
    smartMove(1)
    checkZ()
    checkF()
    spin()
    checkF()
    smartMove(2)
    checkF()
    spin(1)
    if turtle.detectDown() then     
         if selectBlock() then
             turtle.placeDown()
         end
     end     
 end
 checkX()
 smartMove(3)
 checkX()
 smartMove()
 for l = 1, Args[1] do
     smartMove(3)
 end




