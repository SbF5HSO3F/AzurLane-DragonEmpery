-- DragonEmpery_ChenHai
-- Author: HSbF6HSO3F
-- DateCreated: 2024/4/3 23:20:15
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||===================glabol variables===================||--

local range_1 = 10
local settlerIndex = GameInfo.Units['UNIT_SETTLER'].Index

--||===================Events functions===================||--

--On tech completed
function ChenHaiResearchCompleted(playerID, iTech)
    --check the Leader is Chen Hai?
    if DragonCore.CheckLeaderMatched(playerID, 'LEADER_CHEN_HAI') then
        --get the player
        local pPlayer = Players[playerID]
        --get the boost
        DragonCore:GetRandomTechBoosts(pPlayer, 2)
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
    if DragonCore.CheckLeaderMatched(playerID, 'LEADER_CHEN_HAI') then
        --get the player
        local pPlayer = Players[playerID]
        --get the boost
        DragonCore:GetRandomCivicBoosts(pPlayer, 2)
        --get the player tech
        local playerCulture = pPlayer:GetCulture()
        --get the gold
        local gold = playerCulture:GetCultureCost(iCivic) * 2
        --grant the gold
        pPlayer:GetTreasury():ChangeGoldBalance(gold)
    end
end

--||=================GameEvents functions=================||--

--give token to the minor in 10-tiles
function ChenHaiMoreToken(majorID, minorID, iAmount)
    if iAmount <= 0 then return end
    --check the Leader is Chen Hai
    if DragonCore.CheckLeaderMatched(majorID, 'LEADER_CHEN_HAI') then
        --remove this function, to prevent dead cycle
        GameEvents.OnPlayerGaveInfluenceToken.Remove(ChenHaiMoreToken)
        --get the player Influence
        local playerInfluence = Players[majorID]:GetInfluence()
        --get the minor capital or settler
        local plot_1 = nil
        local pMinor = Players[minorID]
        local capital = pMinor:GetCities():GetCapitalCity()
        if capital then
            plot_1 = Map.GetPlot(capital:GetX(), capital:GetY())
        else
            for _, unit in pMinor:GetUnits():Members() do
                if unit:GetType() == settlerIndex then
                    plot_1 = Map.GetPlot(unit:GetX(), unit:GetY())
                    break
                end
            end
        end
        -- get minor in range
        for _, eMinor in ipairs(PlayerManager.GetAliveMinorIDs()) do
            if eMinor ~= minorID then
                --get the minor
                local minor = Players[eMinor]
                --get the capital or settler
                local aCapital = minor:GetCities():GetCapitalCity()
                if aCapital and DragonCore.GetDistance(
                        plot_1, Map.GetPlot(aCapital:GetX(), aCapital:GetY())
                    ) <= range_1 then
                    for i = 1, iAmount, 1 do
                        playerInfluence:GiveFreeTokenToPlayer(eMinor)
                    end
                else
                    for _, unit in minor:GetUnits():Members() do
                        if unit:GetType() == settlerIndex and
                            DragonCore.GetDistance(
                                plot_1, Map.GetPlot(unit:GetX(), unit:GetY())
                            ) <= range_1 then
                            for i = 1, iAmount, 1 do
                                playerInfluence:GiveFreeTokenToPlayer(eMinor)
                            end
                            break
                        end
                    end
                end
            end
        end
        --add this function again
        GameEvents.OnPlayerGaveInfluenceToken.Add(ChenHaiMoreToken)
    end
end

--give token to minor
function ChenHaiGiveTokenTo(playerID, param)
    --get the unit
    local pUnit = UnitManager.GetUnit(playerID, param.unitID)
    if pUnit then
        --get the player Influence
        local playerInfluence = Players[playerID]:GetInfluence()
        --give the token
        playerInfluence:GiveFreeTokenToPlayer(param.minorID)
        --report the unit
        UnitManager.ReportActivation(pUnit, "CHENHAI_GIVETOKEN")
        --kill the unit
        UnitManager.Kill(pUnit)
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
    GameEvents.OnPlayerGaveInfluenceToken.Add(ChenHaiMoreToken)
    GameEvents.ChenHaiGiveToken.Add(ChenHaiGiveTokenTo)
    ----------------------------------------
    print('Initial success!')
end

include('DragonEmpery_ChenHai_', true)

Initialize()
