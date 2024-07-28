-- DragonEmpery_Core
-- Author: jjj
-- DateCreated: 2023/12/30 22:17:09
--------------------------------------------------------------
--||=====================Meta Table=======================||--


--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function DragonEmperyLeaderTypeMatched(playerID, LeaderTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == LeaderTpye
end

--Civilization type judgment. if macth, return true (GamePlay, UI)
function DragonEmperyCivTypeMatched(playerID, CivTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == CivTpye
end

--process rounding (GamePlay, UI)
function DragonEmperyNumRound(num)
    return math.floor((num + 0.05) * 10) / 10
end

--Game Speed Modifier. If reset is true, eliminate the impact of game speed; otherwise, apply the impact of game speed. (GamePlay, UI)
function DragonEmperySpeedModifier(num, reset)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then
        if reset then
            num = DragonEmperyNumRound(num * 100 / gameSpeed.CostMultiplier)
        else
            num = DragonEmperyNumRound(num * gameSpeed.CostMultiplier / 100)
        end
    end
    return num
end

--Random number generator [1,num+1] (GamePlay, UI)
function DragonEmperyGetRandNum(num)
    return Game.GetRandNum and (Game.GetRandNum(num) + 1) or 1
end

--like Array.include() (GamePlay, UI)
function DragonEmperyContains(table, element)
    local included = false
    if table then
        for _, value in ipairs(table) do
            if value == element then
                included = true
                break
            end
        end
    end; return included
end

--Check the No Boost Tech (GamePlay, UI)
function DragonEmperyTechIsNoBoost(type)
    local NoBoost, result = DB.Query([[
        SELECT TechnologyType
        FROM Technologies
        WHERE TechnologyType NOT IN (
            SELECT TechnologyType
            FROM Boosts
            WHERE TechnologyType IS NOT NULL
        )
    ]]), false
    for _, row in ipairs(NoBoost) do
        if type == row['TechnologyType'] then
            result = true
            break
        end
    end
    return result
end

--Check the No Boost Civic (GamePlay, UI)
function DragonEmperyCivicIsNoBoost(type)
    local NoBoost, result = DB.Query([[
        SELECT CivicType
        FROM Civics
        WHERE CivicType NOT IN (
            SELECT CivicType
            FROM Boosts
            WHERE CivicType IS NOT NULL
        )
    ]]), false
    for _, row in ipairs(NoBoost) do
        if type == row['CivicType'] then
            result = true
            break
        end
    end
    return result
end

--get the player game progress (GamePlay, UI)
function DragonEmperyPlayerGameProgress(playerID)
    local pPlayer = Players[playerID]
    if pPlayer == nil then return 0 end
    local playerTech = pPlayer:GetTechs()
    local techNum, techedNum = 0, 0
    for row in GameInfo.Technologies() do
        techNum = (techNum or 0) + 1
        if playerTech:HasTech(row.Index) then
            techedNum = (techedNum or 0) + 1
        end
    end
    local playerCulture = pPlayer:GetCulture()
    local civicNum, civicedNum = 0, 0
    for row in GameInfo.Civics() do
        civicNum = (civicNum or 0) + 1
        if playerCulture:HasCivic(row.Index) then
            civicedNum = (civicedNum or 0) + 1
        end
    end
    local civicProgress = civicNum ~= 0 and civicedNum / civicNum or 0
    local techProgress = techNum ~= 0 and techedNum / techNum or 0
    return math.floor(100 * math.max(techProgress, civicProgress))
end

--Manhattan algorithm (GamePlay, UI)
function DragonEmperyManhattan(pPlot_1, pPlot_2)
    local result = 0
    if pPlot_1 and pPlot_2 then
        local y1, y2 = pPlot_1:GetY(), pPlot_2:GetY()
        local x1 = pPlot_1:GetX() - math.floor(y1 / 2)
        local x2 = pPlot_2:GetX() - math.floor(y2 / 2)
        local z1, z2 = -x1 - y1, -x2 - y2
        result = math.max(math.abs(x1 - x2), math.abs(y1 - y2), math.abs(z1 - z2))
    end; return result
end

--quick sort, Main function (GamePlay, UI)
function DragonEmperyQuickMianSort(arr, left, right)
    if left >= right then return end
    local i, j = left, right
    local temp = arr[left]

    while i < j do
        while temp >= arr[i] and i < j do
            j = j - 1
        end
        while temp <= arr[i] and i < j do
            i = i + 1
        end
        if i < j then
            arr[i], arr[j] = arr[j], arr[i]
        end
    end

    arr[left] = arr[i]
    arr[i] = temp

    DragonEmperyQuickMianSort(arr, left, i - 1)
    DragonEmperyQuickMianSort(arr, i + 1, right)
end

--quick sort (GamePlay, UI)
function DragonEmperyQuickSort(arr)
    DragonEmperyQuickMianSort(arr, 1, #arr)
end


--||=====================GamePlay=======================||--

--Random get Technology Boost (GamePlay)
function DragonEmperyRandomTechBoost(pPlayer, iSource, num)
    local EraIndex, playerTech, limit = 1, pPlayer:GetTechs(), num or 1
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
                        DragonEmperyTechIsNoBoost(row.TechnologyType))
                    and row.EraType == EraType then
                    table.insert(techlist, row.Index)
                end
            end
            if #techlist > 0 then
                local iTech = techlist[DragonEmperyGetRandNum(#techlist)]
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
function DragonEmperyRandomCivicBoost(pPlayer, iSource, num)
    local EraIndex, playerCulture, limit = 1, pPlayer:GetCulture(), num or 1
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
                        DragonEmperyCivicIsNoBoost(row.CivicType))
                    and row.EraType == EraType then
                    table.insert(civiclist, row.Index)
                end
            end
            if #civiclist > 0 then
                local iCivic = civiclist[DragonEmperyGetRandNum(#civiclist)]
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
