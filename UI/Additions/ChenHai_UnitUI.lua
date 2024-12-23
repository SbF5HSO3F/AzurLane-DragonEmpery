-- ChenHai_UnitUI
-- Author: HSbF6HSO3F
-- DateCreated: 2024/7/24 15:16:30
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================ExposedMembers====================||--

ExposedMembers.ChenHai = ExposedMembers.ChenHai or {}

--||===================local variables====================||--

local eReason_1 = DB.MakeHash("CHENHAI_GIVETOKEN")

--||====================base functions====================||--

--button diable
function ChenHaiGetButtonDetail(pUnit)
    --set the detail table
    local detail = { disable = true, reason = 'NONE', Name = 'NONE', Id = nil }
    -- the unit isn't nil?
    if pUnit then
        --get the next plot
        local tPlot = Map.GetNeighborPlots(pUnit:GetX(), pUnit:GetY(), 1)
        --the unit is adjacent to a minor's city center?
        local adjacent, minorId = false, nil
        --begin loop to check the next plot is minor city center
        for _, plot in ipairs(tPlot) do
            --get the city
            local pCity = CityManager.GetCityAt(plot:GetX(), plot:GetY())
            if pCity and Players[pCity:GetOwner()]:IsMinor() then
                adjacent = true
                minorId = pCity:GetOwner()
                break
            end
        end
        --check player can give token to the minor
        if adjacent then
            --get the unit owner
            local pPlayer = Players[pUnit:GetOwner()]
            if pPlayer and pPlayer:GetInfluence():CanGiveTokensToPlayer(minorId) then
                detail.disable = false
                detail.Id = minorId
                local playerConfig = PlayerConfigurations[minorId]
                detail.Name = Locale.Lookup(GameInfo.Civilizations[playerConfig:GetCivilizationTypeID()].Name)
            else
                detail.reason = Locale.Lookup('LOC_CHENHAI_GIVETOKEN_CANTGIVETOKEN')
            end
        else
            detail.reason = Locale.Lookup('LOC_CHENHAI_GIVETOKEN_NONEXTSTATE')
        end
    else
        detail.reason = Locale.Lookup('LOC_CHENHAI_GIVETOKEN_NOUNIT')
    end
    --return the detail table
    return detail
end

--button reset
function ChenHaiResetButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and DragonCore.CheckLeaderMatched(
            pUnit:GetOwner(), 'LEADER_CHEN_HAI'
        ) then
        Controls.ChenHaiGrid:SetHide(false)
        --get the detail
        local detail = ChenHaiGetButtonDetail(pUnit)
        --get the diable
        local disable = detail.disable
        --reset the button
        Controls.ChenHaiTokenButton:SetDisabled(disable)
        Controls.ChenHaiTokenButton:SetAlpha((disable and 0.7) or 1)
        --set the tooltip
        local tooltip = Locale.Lookup('LOC_CHENHAI_GIVETOKEN_NAME')
        if disable then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]'
                .. Locale.Lookup('LOC_CHENHAI_GIVETOKEN_DESCRIPTION') .. '[NEWLINE][NEWLINE]'
                .. Locale.Lookup('LOC_CHENHAI_GIVETOKEN_DISABLED') .. '[NEWLINE]' .. detail.reason
        else
            tooltip = tooltip .. '[NEWLINE][NEWLINE]'
                .. Locale.Lookup('LOC_CHENHAI_GIVETOKEN_DETAIL', detail.Name)
        end
        Controls.ChenHaiTokenButton:SetToolTipString(tooltip)
    else
        Controls.ChenHaiGrid:SetHide(true)
    end

    --reset the base container
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--click the button
function ChenHaiButtonClick()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        local detail = ChenHaiGetButtonDetail(pUnit)
        if detail.disable then return end
        UI.RequestPlayerOperation(
            Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                unitID  = pUnit:GetID(),
                minorID = detail.Id,
                OnStart = 'ChenHaiGiveToken'
            }
        ); UI.PlaySound("Click_Confirm")
    end
end

--||===================Events functions===================||--

--When the unit is selected
function ChenHaiOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected)
    if isSelected and playerId == Game.GetLocalPlayer() then
        ChenHaiResetButton()
    end
end

--On Unit Active
function ChenHaiUnitActive(owner, unitID, x, y, eReason)
    --play the animation
    local pUnit = UnitManager.GetUnit(owner, unitID)
    if eReason == eReason_1 then
        SimUnitSystem.SetAnimationState(pUnit, "ACTION_1", "IDLE")
    end
    --reset the button
    ChenHaiResetButton()
end

--Add a button to Unit Panel
function ChenHaiOnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.ChenHaiGrid:ChangeParent(pContext)
        Controls.ChenHaiTokenButton:RegisterCallback(Mouse.eLClick, ChenHaiButtonClick)
        Controls.ChenHaiTokenButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)
    end

    ChenHaiResetButton()
end

--||====================ExposedMembers====================||--

-- --get the player is minor
-- function ChenHaiIsMinor(MinorID)
--     local pMinor = Players[MinorID]
--     return pMinor and pMinor:IsMinor() or false
-- end

-- --get the player can give token
-- function ChenHaiCanGiveTokenTo(MajorID, MinorID)
--     --set the return value
--     local canGiveToken = false
--     --get the Major and the Minor
--     local pMajor, pMinor = Players[MajorID], Players[MinorID]
--     --if major and minor is not nil
--     if pMajor and pMinor then
--         canGiveToken = pMajor:GetInfluence():CanGiveTokensToPlayer(MinorID)
--     end
--     return canGiveToken
-- end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(ChenHaiOnLoadGameViewStateDone)
    -------------------Resets-------------------
    Events.UnitSelectionChanged.Add(ChenHaiOnUnitSelectChanged)
    Events.UnitActivate.Add(ChenHaiUnitActive)
    --------------------------------------------
    Events.UnitOperationSegmentComplete.Add(ChenHaiResetButton)
    Events.UnitCommandStarted.Add(ChenHaiResetButton)
    Events.UnitDamageChanged.Add(ChenHaiResetButton)
    Events.UnitMoveComplete.Add(ChenHaiResetButton)
    Events.UnitChargesChanged.Add(ChenHaiResetButton)
    Events.UnitPromoted.Add(ChenHaiResetButton)
    Events.UnitOperationsCleared.Add(ChenHaiResetButton)
    Events.UnitOperationAdded.Add(ChenHaiResetButton)
    Events.UnitOperationDeactivated.Add(ChenHaiResetButton)
    Events.UnitMovementPointsChanged.Add(ChenHaiResetButton)
    Events.UnitMovementPointsCleared.Add(ChenHaiResetButton)
    Events.UnitMovementPointsRestored.Add(ChenHaiResetButton)
    Events.UnitAbilityLost.Add(ChenHaiResetButton)
    Events.PhaseBegin.Add(ChenHaiResetButton)
    ---------------ExposedMembers---------------
    -- ExposedMembers.ChenHai.IsMinor = ChenHaiIsMinor
    -- ExposedMembers.ChenHai.CanGiveTokensToPlayer = ChenHaiCanGiveTokenTo
    --------------------------------------------
    print('Initial success!')
end

Initialize()
