-- AnShan_UnitUI
-- Author: jjj
-- DateCreated: 2024/7/27 9:32:52
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================loacl variables===================||--

local eReason_1 = DB.MakeHash('ANSHAN_ADDCOMBAT')

--||====================base functions====================||--

--button diable
function AnShanUnitButtonDisable(pUnit)
    --the detail
    local detail = {
        disable = true,
        combat = 0,
        reason = 'NONE'
    }; if pUnit then
        --limit once per turn
        local turn = pUnit:GetProperty('AnShanCombatTurn') or 0
        if turn >= Game.GetCurrentGameTurn() then
            detail.reason = Locale.Lookup('LOC_ANSTEEL_NOCHARGE_WARNING')
        else
            --get the adjacnet unit max base combat
            local tPlot = Map.GetAdjacentPlots(pUnit:GetX(), pUnit:GetY())
            --the table about the adjacnet unit combat, and the unit base combat
            local combatArray, baseCombat = {}, pUnit:GetCombat() or 0
            --begin loop
            for _, plot in ipairs(tPlot) do
                --about the unit on the plot
                for _, unit in pairs(Units.GetUnitsInPlot(plot)) do
                    --if the unit has combat, insert into the arr
                    if unit ~= nil and unit:GetCombat() > baseCombat then
                        table.insert(combatArray, unit:GetCombat())
                    end
                end
            end
            --if have higher combat than the unit
            if #combatArray > 0 then
                --begin sort to find the maximum combat
                table.sort(combatArray, function(a, b) return a > b end)
                --get the maximum combat
                local combat = combatArray[1] - baseCombat
                detail.combat = combat
                detail.disable = false
                detail.reason = Locale.Lookup('LOC_ANSTEEL_UNIT_COMBAT_DETAIL', combat)
            else
                -- no combat improve, disabled
                detail.reason = Locale.Lookup('LOC_ANSTEEL_NOCOMBAT_WARNING')
            end
        end
    else
        -- no unit, disabled
        detail.reason = Locale.Lookup('LOC_ANSTEEL_NOUNIT_WARNING')
    end

    return detail
end

--button reset
function AnShanUnitButtonReset()
    --get the selected unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and DragonEmperyLeaderTypeMatched(
            pUnit:GetOwner(), 'LEADER_AN_SHAN_DD101'
        ) and pUnit:GetCombat() > 0 then
        Controls.AnShanGrid:SetHide(false)
        --get the detail
        local detail = AnShanUnitButtonDisable(pUnit)
        --get the disabled
        local disabled = detail.disable
        Controls.AnShanCombatButton:SetDisabled(disabled)
        Controls.AnShanCombatButton:SetAlpha((disabled and 0.4) or 1)
        --the tooltip
        local tooltip = Locale.Lookup('LOC_ANSTEEL_UNIT_COMBAT_NAME') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_UNIT_COMBAT_DESC') ..
            '[NEWLINE][NEWLINE]' .. detail.reason
        --set the tooltip
        Controls.AnShanCombatButton:SetToolTipString(tooltip)
    else
        Controls.AnShanGrid:SetHide(true)
    end
    --reset the base container
    DragonEmperyResetUnitBaseContainer()
end

--when button is clicked
function AnShanUnitButtonClick()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        local detail = AnShanUnitButtonDisable(pUnit)
        if detail.disable then return end
        UI.RequestPlayerOperation(
            Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                unitID  = pUnit:GetID(),
                combat  = detail.combat,
                OnStart = 'AnShanAddCombat'
            }
        )
    end
end

--||===================Events functions===================||--

--When the unit is selected
function AnShanOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected)
    if isSelected and playerId == Game.GetLocalPlayer() then
        AnShanUnitButtonReset()
    end
end

--On Unit Active
function AnShanUnitActive(owner, unitID, x, y, eReason)
    --play the animation
    local pUnit = UnitManager.GetUnit(owner, unitID)
    if eReason == eReason_1 then
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
    end
    --reset the button
    AnShanUnitButtonReset()
end

--Add a button to Unit Panel
function AnShanOnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.AnShanGrid:ChangeParent(pContext)
        Controls.AnShanCombatButton:RegisterCallback(Mouse.eLClick, AnShanUnitButtonClick)
        Controls.AnShanCombatButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)
    end

    AnShanUnitButtonReset()
end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(AnShanOnLoadGameViewStateDone)
    -------------------Resets-------------------
    Events.UnitSelectionChanged.Add(AnShanOnUnitSelectChanged)
    Events.UnitActivate.Add(AnShanUnitActive)
    --------------------------------------------
    Events.UnitOperationSegmentComplete.Add(AnShanUnitButtonReset)
    Events.UnitCommandStarted.Add(AnShanUnitButtonReset)
    Events.UnitDamageChanged.Add(AnShanUnitButtonReset)
    Events.UnitMoveComplete.Add(AnShanUnitButtonReset)
    Events.UnitChargesChanged.Add(AnShanUnitButtonReset)
    Events.UnitPromoted.Add(AnShanUnitButtonReset)
    Events.UnitOperationsCleared.Add(AnShanUnitButtonReset)
    Events.UnitOperationAdded.Add(AnShanUnitButtonReset)
    Events.UnitOperationDeactivated.Add(AnShanUnitButtonReset)
    Events.UnitMovementPointsChanged.Add(AnShanUnitButtonReset)
    Events.UnitMovementPointsCleared.Add(AnShanUnitButtonReset)
    Events.UnitMovementPointsRestored.Add(AnShanUnitButtonReset)
    Events.UnitAbilityLost.Add(AnShanUnitButtonReset)
    Events.PhaseBegin.Add(AnShanUnitButtonReset)
    ---------------ExposedMembers---------------

    --------------------------------------------
    print('Initial success!')
end

Initialize()
