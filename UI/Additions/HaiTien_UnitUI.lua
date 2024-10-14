-- HaiTien_UnitUI
-- Author: jjj
-- DateCreated: 2024/8/18 14:12:11
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||===================glabol variables===================||--

--great writer
local greatWriter = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_WRITER'].Index
--the culture values
local cultureAmount = 100
local cultureExtra = 50
--the production values
local productionAmount = 200
local productionExtra = 100

--||====================base functions====================||--

--get the unit detail
function HaiTienGetDetail(greatPersonIndividualID)
    --the detail table
    local detail = { EraName = 'NONE', Culture = 0, Production = 0 }
    --get the great person detail
    local greatPerson = GameInfo.GreatPersonIndividuals[greatPersonIndividualID]
    --get the era type
    local eraType = greatPerson.EraType
    --get the era detail
    local defEra = GameInfo.Eras[eraType]
    --get the era ChronologyIndex
    local index = defEra.ChronologyIndex
    --set the value
    detail.Culture = DragonCore:ModifyBySpeed(cultureAmount + cultureExtra * (index - 1))
    detail.Production = DragonCore:ModifyBySpeed(productionAmount + productionExtra * (index - 1))
    --get the era name
    detail.EraName = Locale.Lookup(defEra.Name)

    return detail
end

--reset the button
function HaiTienResetButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    --if Loacl player is Hai Tien
    if DragonCore.CheckLeaderMatched(
            Game.GetLocalPlayer(), 'LEADER_HAI_TIEN'
        ) and pUnit then
        --get the unit geart person
        local pGreatPerson = pUnit:GetGreatPerson()
        if pGreatPerson and pGreatPerson:GetClass() == greatWriter then
            Controls.HaiTienGrid:SetHide(false)
            --get the detail
            local detail = HaiTienGetDetail(pGreatPerson:GetIndividual())
            --get the unit Name
            local Name = Locale.Lookup(pUnit:GetName())
            --the Tooltip
            local tooltip = Locale.Lookup('LOC_HAI_TIEN_GREAT_WRITER_TITLE')
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_HAI_TIEN_GREAT_WRITER_PREVIEW',
                Name, detail.EraName, detail.Culture, detail.Production)
            --set the tooltip
            Controls.HaiTienWriterButton:SetToolTipString(tooltip)
        else
            Controls.HaiTienGrid:SetHide(true)
        end
    else
        Controls.HaiTienGrid:SetHide(true)
    end

    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--||===================Events functions===================||--

--When Selected
function HaiTienOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected)
    if isSelected and playerId == Game.GetLocalPlayer() then
        HaiTienResetButton()
    end
end

--Add a button to Unit Panel
function HaiTienOnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.HaiTienGrid:ChangeParent(pContext)
    end

    HaiTienResetButton()
end

--Hei Tien
function HaiTienOnGreatPersonActived(unitOwner, unitID, greatPersonClassID, greatPersonIndividualID)
    --judge the great person
    if greatPersonClassID ~= greatWriter then return end
    --check the loacl player
    if unitOwner ~= Game.GetLocalPlayer() then return end
    --judge the player
    if DragonCore.CheckLeaderMatched(unitOwner, 'LEADER_HAI_TIEN') then
        --get the unit
        local pUnit = UnitManager.GetUnit(unitOwner, unitID)
        local x, y = pUnit:GetX(), pUnit:GetY()
        --get the great person era
        local detail = HaiTienGetDetail(greatPersonIndividualID)
        --get the city
        local pCity = Cities.GetPlotPurchaseCity(Map.GetPlot(x, y))
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                x = x,
                y = y,
                culture = detail.Culture,
                production = detail.Production,
                cityID = pCity and pCity:GetID(),
                OnStart = 'HaiTienGreatWriterActivated'
            }
        )
    end
end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(HaiTienOnLoadGameViewStateDone)
    -------------------Resets-------------------
    Events.UnitSelectionChanged.Add(HaiTienOnUnitSelectChanged)
    --------------------------------------------
    Events.UnitGreatPersonActivated.Add(HaiTienOnGreatPersonActived)

    Events.UnitOperationSegmentComplete.Add(HaiTienResetButton)
    Events.UnitCommandStarted.Add(HaiTienResetButton)
    Events.UnitDamageChanged.Add(HaiTienResetButton)
    Events.UnitMoveComplete.Add(HaiTienResetButton)
    Events.UnitChargesChanged.Add(HaiTienResetButton)
    Events.UnitPromoted.Add(HaiTienResetButton)
    Events.UnitOperationsCleared.Add(HaiTienResetButton)
    Events.UnitOperationAdded.Add(HaiTienResetButton)
    Events.UnitOperationDeactivated.Add(HaiTienResetButton)
    Events.UnitMovementPointsChanged.Add(HaiTienResetButton)
    Events.UnitMovementPointsCleared.Add(HaiTienResetButton)
    Events.UnitMovementPointsRestored.Add(HaiTienResetButton)
    Events.UnitAbilityLost.Add(HaiTienResetButton)
    Events.PhaseBegin.Add(HaiTienResetButton)
    ---------------ExposedMembers---------------

    --------------------------------------------
    print('Initial success!')
end

Initialize()
