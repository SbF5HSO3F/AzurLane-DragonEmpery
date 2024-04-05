-- DragonEmpery_ChenHai
-- Author: jjj
-- DateCreated: 2024/4/3 23:20:15
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||===================glabol variables===================||--

local range_1 = 10

--||===================Events functions===================||--

--On tech completed
function ChenHaiResearchCompleted(playerID, iTech)
    --check the Leader is Chen Hai?
    if DragonEmperyLeaderTypeMatched(playerID, 'LEADER_CHEN_HAI') then
        --get the player
        local pPlayer = Players[playerID]
        --get the boost
        DragonEmperyRandomTechBoost(pPlayer, 2)
        --get the player tech
        local playerTechs = pPlayer:GetTechs()
        --get the gold
        local gold = playerTechs:GetResearchCost(iTech) * 2
        --grant the gold
        pPlayer:GetTreasury():ChangeGoldBalance(gold)
    end
end

--On civic completed
function ChenHaiCivicCompleted(playerID, iCivic)
    --check the Leader is Chen Hai?
    if DragonEmperyLeaderTypeMatched(playerID, 'LEADER_CHEN_HAI') then
        --get the player
        local pPlayer = Players[playerID]
        --get the boost
        DragonEmperyRandomCivicBoost(pPlayer, 2)
        --get the player tech
        local playerCulture = pPlayer:GetCulture()
        --get the gold
        local gold = playerCulture:GetCultureCost(iCivic) * 2
        --grant the gold
        pPlayer:GetTreasury():ChangeGoldBalance(gold)
    end
end

--Kill Unit grant the envoy
function ChenHaiKillUnit(killedPlayerID, killedUnitID, playerID, unitID)
    --check the Leader is Chen Hai
    if DragonEmperyLeaderTypeMatched(playerID, 'LEADER_CHEN_HAI') then
        --get the player Influence
        local playerInfluence = Players[playerID]:GetInfluence()
        --add the envoy
        playerInfluence:ChangeTokensToGive(1)
        --get the unit
        local pUnit = UnitManager.GetUnit(playerID, unitID)
        if pUnit == nil then return end
        --get the tplot
        local tPlot = Map.GetNeighborPlots(pUnit:GetX(), pUnit:GetY(), range_1)
        --get the given player table
        local givenPlayerTable = {}
        --begin the plot
        for _, plot in ipairs(tPlot) do
            --get the city owner
            local city = CityManager.GetCityAt(plot:GetX(), plot:GetY())
            local cityOwnerID = city and city:GetOwner()
            if cityOwnerID and not DragonEmperyContains(givenPlayerTable, cityOwnerID) then
                --can give the token?
                if ExposedMembers.ChenHai.CanGiveToken(playerID, cityOwnerID) then
                    --give the token to the minor
                    playerInfluence:GiveFreeTokenToPlayer(cityOwnerID)
                    table.insert(givenPlayerTable, cityOwnerID)
                end
            end
        end
    end
end

--||=================GameEvents functions=================||--

--give token to the minor in 10-tiles
function ChenHaiMoreToken(majorID, minorID, iAmount)
    --check the Leader is Chen Hai
    if DragonEmperyLeaderTypeMatched(majorID, 'LEADER_CHEN_HAI') then
        --remove this function, to prevent dead cycle
        GameEvents.OnPlayerGaveInfluenceToken.Remove(ChenHaiMoreToken)
        --get the player Influence
        local playerInfluence = Players[majorID]:GetInfluence()
        --get the given player table
        local givenPlayerTable = { minorID }
        --begin the plot
        for _, minor in ipairs(PlayerManager.GetAliveMinorIDs()) do
            if not DragonEmperyContains(givenPlayerTable, minor) then
                --can give the token?
                if ExposedMembers.ChenHai.CanGiveToken(majorID, minor) then
                    --give the token to the minor
                    playerInfluence:GiveFreeTokenToPlayer(minor)
                    table.insert(givenPlayerTable, minor)
                end
            end
        end
        --add this function again
        GameEvents.OnPlayerGaveInfluenceToken.Add(ChenHaiMoreToken)
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------
    Events.ResearchCompleted.Add(ChenHaiResearchCompleted)
    Events.CivicCompleted.Add(ChenHaiCivicCompleted)
    --Events.UnitKilledInCombat.Add(ChenHaiKillUnit)
    ---------------GameEvents---------------
    --GameEvents.OnPlayerGaveInfluenceToken.Add(ChenHaiMoreToken)
    ----------------------------------------
    print('DragonEmpery_ChenHai Initial success!')
end

Initialize()
