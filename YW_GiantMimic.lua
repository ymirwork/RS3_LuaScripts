local API = require("api")

local startTime = os.time()
local player = API.GetLocalPlayerName()
local startTime, afk = os.time(), os.time()

local startCombat = false

local function setupBackground()
    

    IG_Back = API.CreateIG_answer();
    IG_Back.box_name = "back";
    IG_Back.box_start = FFPOINT.new(0, 0, 0)
    IG_Back.box_size = FFPOINT.new(440, 90, 0)
    IG_Back.colour = ImColor.new(0,0,0, 160)
    IG_Back.string_value = ""

    IG_Text = API.CreateIG_answer();
    IG_Text.box_start = FFPOINT.new(120, 5, 0)
    IG_Text.box_name = "TXT"
    IG_Text.colour = ImColor.new(255, 255, 255);
    IG_Text.string_value = "Mimic by JCurtis"

    API.DrawSquareFilled(IG_Back)
    API.DrawTextAt(IG_Text)
end

setupBackground()

local startTime = os.time()
local idleTimeThreshold = math.random(110, 180)

local function antiIdleTask()
  local currentTime = os.time()
  local elapsedTime = os.difftime(currentTime, startTime)
  if elapsedTime >= idleTimeThreshold then
    API.PIdle2()
    startTime = os.time()
    idleTimeThreshold = math.random(110, 180)
    print("Reset Timer & Threshhold")
  end
end

local initialAttack = false

local function findNpc(npcid, distance)
    local distance = distance or 20
    return API.GetAllObjArrayInteract({ npcid }, distance, 1)[1]
end

local function randomPositiveOrNegative(min, max)
    -- Generate a random number between 0 and 1
    local randomNumber = math.random()
    
    -- Determine whether to make it positive or negative
    if randomNumber < 0.5 then
        return -math.random(min, max) -- Return a negative random number
    else
        return math.random(min, max) -- Return a positive random number
    end
end

local function getCoinProjectile()
    local vec = API.ReadAllObjectsArray(false, 5);
    for i = 1, #vec do
        if vec[i].Id ~= 0 then
            if vec[i].Id == 6042 then
                return vec[i]
            end
        end
    end     
end

local function distance(tile)
    local player = API.PlayerCoord()
    local x = player.x - tile.x
    local y = player.y - tile.y
    return math.sqrt(x * x + y * y)
end

local function runFromProjectile()
     local coin = getCoinProjectile()

     if coin ~= nil then
        if distance({ x = coin.TileX / 512,  y = coin.TileY / 512 }) < 4 then
            API.DoAction_Tile(WPOINT.new((coin.TileX / 512) + randomPositiveOrNegative(7, 9), (coin.TileY / 512) + randomPositiveOrNegative(7, 9), 0))
            API.RandomSleep2(111, 111, 111)
         end    
     end
end

-- main loop
while API.Read_LoopyLoop() do
    API.SetDrawTrackedSkills(true)
    antiIdleTask()

    if API.LocalPlayer_IsInCombat_() then
        local coords = API.PlayerCoord()

        if not initialAttack then
            API.DoAction_NPC(0x21,3216,{ 22165 },50) -- attack mimic
            API.RandomSleep2(222, 222, 222)
            initialAttack = true
        end

        -- Dodge
        local npc = findNpc(22165, 20)

        if npc ~= nil then            
            if npc.Anim == 28071 then -- JUMP
                API.DoAction_Tile(WPOINT.new(coords.x + randomPositiveOrNegative(7, 9), coords.y + randomPositiveOrNegative(4, 4), 0))
                API.RandomSleep2(555, 555, 555)
                API.WaitUntilMovingEnds()
                API.RandomSleep2(111, 111, 111)
            elseif npc.Anim == 28080 then -- toss    
                API.DoAction_Tile(WPOINT.new((npc.TileX / 512) + randomPositiveOrNegative(7, 9), (npc.TileY / 512) + randomPositiveOrNegative(4, 4), 0))
                API.RandomSleep2(333, 333, 333)
            end
        end
    else
        -- Check if loot isn't on ground
        API.RandomSleep(1000,1000,1200)
        API.DoAction_G_Items1(0x2d,{ 36828 },50)
        API.WaitUntilMovingEnds()
        API.RandomSleep(2000,2000,2200)
        API.DoAction_G_Items1(0x2d,{ 36828 },50)
        API.RandomSleep(5000,5000,5200)

        API.DoAction_Ability("Mimic kill token", 1, 5392)
        API.RandomSleep2(1000,1000,1500)

        -- Opt 1 tp
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1188,8,-1,4512);
        API.RandomSleep2(2000,2000,2500)
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1188,8,-1,4512);
        API.RandomSleep2(7000,7000,7500)
        initialAttack = false
    end

    --print("Decor Count" .. #API.ReadAllObjectsArray(true, 4))
    --print("Highlight Count" .. #API.ReadAllObjectsArray(true, 12))

    API.RandomSleep2(222, 222, 222)
end
