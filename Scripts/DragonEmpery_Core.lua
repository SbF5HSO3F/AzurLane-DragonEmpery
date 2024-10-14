-- DragonEmpery_Core
-- Author: jjj
-- DateCreated: 2023/12/30 22:17:09
--------------------------------------------------------------
--||=====================Meta Table=======================||--

DragonCore = {}

--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function DragonCore.CheckLeaderMatched(playerID, LeaderTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == LeaderTpye
end

--Civilization type judgment. if macth, return true (GamePlay, UI)
function DragonCore.CheckCivMatched(playerID, CivTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == CivTpye
end

--process rounding (GamePlay, UI)
function DragonCore.Round(num)
    return math.floor((num + 0.05) * 10) / 10
end

--Game Speed Modifier. (GamePlay, UI)
function DragonCore:ModifyBySpeed(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then num = self.Round(num * gameSpeed.CostMultiplier / 100) end
    return num
end

--Random number generator [1,num+1] (GamePlay, UI)
function DragonCore.tableRandom(num)
    return Game.GetRandNum and (Game.GetRandNum(num) + 1) or 1
end

--like Array.include() (GamePlay, UI)
function DragonCore.include(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

--Check the tech or civic has boost (GamePlay, UI)
function DragonCore.HasBoost(techOrCivic)
    for boost in GameInfo.Boosts() do
        if techOrCivic == boost.TechnologyType or techOrCivic == boost.CivicType then
            return true
        end
    end
    return false
end

--get the player game progress (GamePlay, UI)
function DragonCore:GetPlayerProgress(playerID)
    local pPlayer = Players[playerID]
    if pPlayer == nil then return 0 end
    local playerTech = pPlayer:GetTechs()
    local techNum, techedNum = 0, 0
    for row in GameInfo.Technologies() do
        techNum = techNum + 1
        if playerTech:HasTech(row.Index) then
            techedNum = (techedNum or 0) + 1
        end
    end
    local playerCulture = pPlayer:GetCulture()
    local civicNum, civicedNum = 0, 0
    for row in GameInfo.Civics() do
        civicNum = civicNum + 1
        if playerCulture:HasCivic(row.Index) then
            civicedNum = (civicedNum or 0) + 1
        end
    end
    local civicProgress = civicNum ~= 0 and civicedNum / civicNum or 0
    local techProgress = techNum ~= 0 and techedNum / techNum or 0
    return self.Round(100 * math.max(techProgress, civicProgress))
end

--Manhattan algorithm (GamePlay, UI)
function DragonCore.GetDistance(object_1, object_2)
    local result = 0
    if object_1 and object_2 then
        result = Map.GetPlotDistance(
            object_1:GetX(), object_1:GetY(),
            object_2:GetX(), object_2:GetY()
        )
    end; return result
end

--||=====================GamePlay=======================||--

--Random get Technology Boost (GamePlay)
function DragonCore:GetRandomTechBoosts(playerID, iSource, num)
    local pPlayer = Players[playerID]
    local EraIndex = 1
    local playerTech = pPlayer:GetTechs()
    local limit = num or 1
    while limit > 0 do
        local EraType = nil
        for era in GameInfo.Eras() do
            if era.ChronologyIndex == EraIndex then
                EraType = era.EraType
                break
            end
        end
        if EraType then
            local techlist = {}
            for row in GameInfo.Technologies() do
                if not (playerTech:HasTech(row.Index) or
                        playerTech:HasBoostBeenTriggered(row.Index) or
                        not self.HasBoost(row.TechnologyType))
                    and row.EraType == EraType then
                    table.insert(techlist, row.Index)
                end
            end
            if #techlist > 0 then
                local iTech = techlist[self.tableRandom(#techlist)]
                playerTech:TriggerBoost(iTech, iSource)
                limit = limit - 1
            else
                EraIndex = (EraIndex or 0) + 1
            end
        else
            break
        end
    end
end

--Random get Civic Boost (GamePlay)
function DragonCore:GetRandomCivicBoosts(playerID, iSource, num)
    local pPlayer = Players[playerID]
    local EraIndex = 1
    local playerCulture = pPlayer:GetCulture()
    local limit = num or 1
    while limit > 0 do
        local EraType = nil
        for era in GameInfo.Eras() do
            if era.ChronologyIndex == EraIndex then
                EraType = era.EraType
                break
            end
        end
        if EraType then
            local civiclist = {}
            for row in GameInfo.Civics() do
                if not (playerCulture:HasCivic(row.Index) or
                        playerCulture:HasBoostBeenTriggered(row.Index) or
                        not self.HasBoost(row.CivicType))
                    and row.EraType == EraType then
                    table.insert(civiclist, row.Index)
                end
            end
            if #civiclist > 0 then
                local iCivic = civiclist[self.tableRandom(#civiclist)]
                playerCulture:TriggerBoost(iCivic, iSource)
                limit = limit - 1
            else
                EraIndex = (EraIndex or 0) + 1
            end
        else
            break
        end
    end
end

--||=========================UI=========================||--

--mouse enter the button
function DragonEmperyEnter()
    UI.PlaySound("Main_Menu_Mouse_Over")
end

--Reset UnitBaseContainer (UI)
function DragonEmperyResetUnitBaseContainer()
    local ActionsStack = ContextPtr:LookUpControl("/InGame/UnitPanel/ActionsStack")
    local UnitPanelBaseContainer = ContextPtr:LookUpControl("/InGame/UnitPanel/UnitPanelBaseContainer")
    if ActionsStack and UnitPanelBaseContainer then
        ActionsStack:CalculateSize()
        local SizeX = ActionsStack:GetSizeX()
        if SizeX > UnitPanelBaseContainer:GetSizeX() then
            UnitPanelBaseContainer:SetSizeX(SizeX + 18);
        end
    end
end

--||========================Test========================||--

--test function
function DragonEmperyPrintTable(t, indent)
    indent = indent or 0

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.rep(" ", indent) .. k .. ": {")
            DragonEmperyPrintTable(v, indent + 4)
            print(string.rep(" ", indent) .. "}")
        else
            print(string.rep(" ", indent) .. k .. ": " .. tostring(v))
        end
    end
end
