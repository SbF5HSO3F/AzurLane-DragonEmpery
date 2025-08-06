-- DragonCore
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/30 22:17:09
--------------------------------------------------------------
--||=====================Meta Table=======================||--

DragonCore = {}

--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function DragonCore.CheckLeaderMatched(playerID, Leadertype)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == Leadertype
end

--Civilization type judgment. if macth, return true (GamePlay, UI)
function DragonCore.CheckCivMatched(playerID, Civtype)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == Civtype
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

--Percent Modifier. (GamePlay, UI)
function DragonCore:ModifyByPercent(num, percent, effect)
    return self.Round(num * (effect and percent or (100 + percent)) / 100)
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

--get the city production detail (UI)
function DragonCore.GetProductionDetail(city)
    local details = { --the production detail
        --city production
        Producting = false,
        IsBuilding = false,
        IsWonder   = false,
        IsDistrict = false,
        IsUnit     = false,
        IsProject  = false,
        --production detail
        ItemType   = 'NONE',
        ItemName   = 'NONE',
        ItemIndex  = -1,
        --about the progress detail
        Progress   = 0,
        TotalCost  = 0,
    }; if not city then return details end
    --the city has the production?
    local cityBuildQueue = city:GetBuildQueue()
    local productionHash = cityBuildQueue:GetCurrentProductionTypeHash()
    if productionHash ~= 0 then
        details.Producting = true
        --building district unit project
        local pBuildingDef = GameInfo.Buildings[productionHash]
        local pDistrictDef = GameInfo.Districts[productionHash]
        local pUnitDef     = GameInfo.Units[productionHash]
        local pProjectDef  = GameInfo.Projects[productionHash]
        --judge the currently building
        if pBuildingDef ~= nil then
            --get the index to get production detail
            local index = pBuildingDef.Index
            --set the production detail
            details.IsBuilding = true
            details.IsWonder = pBuildingDef.IsWonder
            details.ItemType = pBuildingDef.BuildingType
            details.ItemName = Locale.Lookup(pBuildingDef.Name)
            details.ItemIndex = index
            details.Progress = cityBuildQueue:GetBuildingProgress(index)
            details.TotalCost = cityBuildQueue:GetBuildingCost(index)
        elseif pDistrictDef ~= nil then
            --get the index to get production detail
            local index = pDistrictDef.Index
            --set the production detail
            details.IsDistrict = true
            details.ItemType = pDistrictDef.DistrictType
            details.ItemName = Locale.Lookup(pDistrictDef.Name)
            details.ItemIndex = index
            details.Progress = cityBuildQueue:GetDistrictProgress(index)
            details.TotalCost = cityBuildQueue:GetDistrictCost(index)
        elseif pUnitDef ~= nil then
            --get the index to get production detail
            local index = pUnitDef.Index
            --set the production detail
            details.IsUnit = true
            details.ItemType = pUnitDef.UnitType
            details.ItemName = Locale.Lookup(pUnitDef.Name)
            details.ItemIndex = index
            details.Progress = cityBuildQueue:GetUnitProgress(index)
            --get the miliitary formation type
            local formation = cityBuildQueue:GetCurrentProductionTypeModifier()
            if formation == MilitaryFormationTypes.STANDARD_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitCost(index)
            elseif formation == MilitaryFormationTypes.CORPS_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitCorpsCost(index)
                if pUnitDef.Domain == 'DOMAIN_SEA' then
                    -- Concatenanting two fragments is not loc friendly.  This needs to change.
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_FLEET_SUFFIX")
                else
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_CORPS_SUFFIX")
                end
            elseif formation == MilitaryFormationTypes.ARMY_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitArmyCost(index)
                if pUnitDef.Domain == 'DOMAIN_SEA' then
                    -- Concatenanting two fragments is not loc friendly.  This needs to change.
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMADA_SUFFIX")
                else
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMY_SUFFIX")
                end
            end
        elseif pProjectDef ~= nil then
            --get the index to get production detail
            local index = pProjectDef.Index
            --set the production detail
            details.IsProject = true
            details.ItemType = pProjectDef.ProjectType
            details.ItemName = Locale.Lookup(pProjectDef.Name)
            details.ItemIndex = index
            details.Progress = cityBuildQueue:GetProjectProgress(index)
            details.TotalCost = cityBuildQueue:GetProjectCost(index)
        end
    end
    return details
end

--mouse enter the button
function DragonEmperyEnter()
    UI.PlaySound("Main_Menu_Mouse_Over")
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
