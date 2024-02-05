local API = require("api")
local startXp = API.GetSkillXP("THIEVING")
startTime, afk = os.time(), os.time()

-- Rounds a number to the nearest integer or to a specified number of decimal places.

-- DATA_START
ID = {
    VEG_STALLS = 66696
  }
  -- DATA_END

-- FUNCTIONS_START

local function isInventoryFull()
	return API.InvFull_()
end

local function getPlayerAnimation()
    return API.GetPlayerAnimation_(API.GetLocalPlayerName())
end

local function playerIdle()
    return getPlayerAnimation() == -1
end

local function bank()
   -- print("Open Bank")
    API.DoAction_Object1(0x2e,80,{ 79036 },50); --Lumbridge bank chest
   -- print("Sleep")
    API.RandomSleep2(300, 800, 800)
    API.WaitUntilMovingEnds()
    --print("Key Press 3")
    API.KeyboardPress('3',200,300) --Deposit ALl
   -- print("Sleep")
    API.RandomSleep2(900, 1200, 1200)
end

local function thieving_veggie()
    if playerAnimation == 832 then
        return
    end  
    API.DoAction_Object1(0x29,80,{ ID.VEG_STALLS },50);
    API.RandomSleep2(2000, 300, 600)
end


local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function calcProgressPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local function printProgressReport(final)
    local skill = "THIEVING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    local xplvlup = API.XPForLevel(currentLevel +1)
    local xp99 = API.XPForLevel(99)
    local timeNeeded = round(((xplvlup - currentXp) / xpPH)*60)
    local timeneededfor99 = round(((xp99 - currentXp) / xpPH)*60)     
    IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
    IGP.string_value = time ..
    " | " ..
    string.lower(skill):gsub("^%l", string.upper) ..
    ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)  .. " | TTL: " .. formatNumber(timeNeeded) .. " minut" .. " | TTL99: " .. formatNumber(timeneededfor99) .. " minut"
end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(54,57,62);
    IGP.string_value = "Loading YW_TV..."
end

function drawGUI()
    DrawProgressBar(IGP)
end

-- FUNCTIONS_END

setupGUI()

--main loop
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------
    drawGUI()
    if playerIdle() and not isInventoryFull() then
        thieving_veggie()
    end
    if isInventoryFull() then
        bank()
    end

    printProgressReport()
    API.RandomSleep2(100, 100, 100)
end----------------------------------------------------------------------------------
