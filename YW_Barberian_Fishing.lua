--[[
Script Name: YW Barberian Fishing
Arthur: YmirWork
Version: 1.0


Changelog history:
Added 0.5 : 
Added ProgressBar

Added 1.0 :
Added ID Urns
Added Using URNS if have in inventory.

Special Thanks:
Chad from Orgial scripts come from
]]


local API = require("api")

local startXp = API.GetSkillXP("FISHING")
startTime, afk = os.time(), os.time()


-- Rounds a number to the nearest integer or to a specified number of decimal places.
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
    local skill = "FISHING"
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
    IGP.string_value = "Loading YW_Fishing_Barberian..."
end

function drawGUI()
    DrawProgressBar(IGP)
end
-- FUNCTIONS_END

setupGUI()

ID_FISHING_SPOT = {
    CATCH = 328,
    RAW_CRAY = 14907
  }

ID_URN = {
    PLAIN_FISHING_URN = 20336
  }

local function catchFish()
    if playerAnimation == 24928 then
        return
    end
    API.DoAction_NPC(0x3c,1488,{ ID_FISHING_SPOT.CATCH },50);
    API.RandomSleep2(2000, 300, 600)    
end

local function isInventoryFull()
	return API.InvFull_()
end

local function getPlayerAnimation()
    return API.GetPlayerAnimation_(API.GetLocalPlayerName())
end

local function playerIdle()
    return getPlayerAnimation() == -1
end

--Exported function list is in API
--main loop
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------
    drawGUI()
    
    if playerIdle() and not isInventoryFull() then
        catchFish()
    end
    if isInventoryFull() then
        repeat
            API.KeyboardPress("-", 50, 70)
            API.KeyboardPress("=", 50, 70)
        until API.Invfreecount_() > 23
    end
    if API.InvItemcount_2(ID_URN.PLAIN_FISHING_URN) >= 1 then
        API.KeyboardPress('E',200,300)
    end

    printProgressReport()
    API.RandomSleep2(100, 100, 100)
end----------------------------------------------------------------------------------
