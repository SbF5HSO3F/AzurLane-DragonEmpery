-- DragonEmpery_AnShan
-- Author: jjj
-- DateCreated: 2024/7/12 18:26:03
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||===================local variables====================||--

local ability_1 = 'ABILITY_AN_SHAN_COMBAT_UNITS_BUFF'
local ability_2 = 'ABILITY_AN_SHAN_UNIT_GRANT_EXP'

--||===================Events functions===================||--

--when AnShan's Unit kill unit
function AnShanKillUnit(killedPlayerID, killedUnitID, playerID, unitID)
    -- the leader is AnShan?
    if DragonEmperyLeaderTypeMatched(playerID, 'LEADER_AN_SHAN_DD101') then
        local pUnit = UnitManager.GetUnit(playerID, unitID)
        --get the unit ability
        local unitAbility = pUnit:GetAbility()
        if not unitAbility then return end
        --get the ability and remove it
        unitAbility:ChangeAbilityCount(ability_2, 1)
        unitAbility:ChangeAbilityCount(ability_2, -unitAbility:GetAbilityCount(ability_2))
    end
end

--||=================GameEvents functions=================||--

--Clear the unit abilities
function AnShanOnPlayerTurnStarted(playerID)
    --get the player
    local pPlayer = Players[playerID]
    if pPlayer and pPlayer:GetProperty('AnShanNeedClearCombat') == true then
        for _, unit in pPlayer:GetUnits():Members() do
            --get the unit ability
            local unitAbility = unit:GetAbility()
            if unitAbility and unitAbility:GetAbilityCount(ability_1) > 0 then
                --if the unit has the ability, clear it
                unitAbility:ChangeAbilityCount(ability_1, -unitAbility:GetAbilityCount(ability_1))
            end
        end
        --reset the player property
        pPlayer:SetProperty('AnShanNeedClearCombat', false)
    end
end

--finish the city production
function AnShanFinishCityProduction(playerID, param)
    --get the player
    local pPlayer = Players[playerID]
    --get the city
    local pCity = CityManager.GetCity(playerID, param.CityID)
    if pCity and pPlayer then
        --get the city currently production
        local cityBuildQueue = pCity:GetBuildQueue()
        --print(cityBuildQueue:CurrentlyBuilding(), param.Production)
        if cityBuildQueue and cityBuildQueue:CurrentlyBuilding() == param.Production then
            --finish production
            -- cityBuildQueue:FinishProgress()
            cityBuildQueue:AddProgress(param.Afford)
            --cost the resource
            pPlayer:GetResources():ChangeResourceAmount(param.Resource, -param.Cost)
        end
    end
end

--add the combat
function AnShanAddUnitCombat(playerID, param)
    --get the unit
    local pUnit = UnitManager.GetUnit(playerID, param.unitID)
    if pUnit == nil then return end
    --add the combat
    pUnit:SetProperty('AnShanCombatAdd', param.combat)
    pUnit:SetProperty('AnShanCombatTurn', Game.GetCurrentGameTurn())
    pUnit:GetAbility():ChangeAbilityCount(ability_1, 1)
    --report the unit active
    UnitManager.ReportActivation(pUnit, "ANSHAN_ADDCOMBAT")
    --add Text
    local message = Locale.Lookup('LOC_ANSTEEL_UNIT_COMBAT_NAME')
    --add the message text
    local messageData = {
        MessageType = 0,
        MessageText = message,
        PlotX       = pUnit:GetX(),
        PlotY       = pUnit:GetY(),
        Visibility  = RevealedState.VISIBLE,
    }; Game.AddWorldViewText(messageData)
    --set the player property to clear the ability every turn
    Players[playerID]:SetProperty('AnShanNeedClearCombat', true)
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------
    Events.UnitKilledInCombat.Add(AnShanKillUnit)
    ---------------GameEvents---------------
    GameEvents.PlayerTurnStarted.Add(AnShanOnPlayerTurnStarted)
    GameEvents.AnShanFinishProduction.Add(AnShanFinishCityProduction)
    GameEvents.AnShanAddCombat.Add(AnShanAddUnitCombat)
    ----------------------------------------
    print('Initial success!')
end

Initialize()
