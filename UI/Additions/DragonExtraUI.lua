-- DragonExtraUI
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/31 8:36:20
--------------------------------------------------------------
--||=======================include========================||--
include('DragonCore')
include('DragonAncient')

--||====================ExposedMembers====================||--

--GameEvents
----ExposedMembers.GameEvents = GameEvents
--ExposedMembers
ExposedMembers.DragonEmpery = ExposedMembers.DragonEmpery or {}

--||===================glabol variables===================||--

--the Apricot Academy
local ApricotAcademy = GameInfo.Buildings['BUILDING_APRICOT_ACADEMY'].Index

--||====================base functions====================||--

--get the player era
function DragonEmperyGetPlayerAgeType(playerID)
    local age, eras = {
        Heroic = false,
        Golden = false,
        Dark = false
    }, Game.GetEras()

    if eras:HasHeroicGoldenAge(playerID) then
        age['Heroic'] = true
    elseif eras:HasGoldenAge(playerID) then
        age['Golden'] = true
    elseif eras:HasDarkAge(playerID) then
        age['Dark'] = true
    end

    return age
end

--get the GreakWork Type
function DragonEmperyGreatWorkTypeMatch(greatWorkIndex, greatWorkType)
    local type = Game.GetGreatWorkType(greatWorkIndex)
    local objectType = type and GameInfo.GreatWorks[type]
    return objectType and objectType.GreatWorkObjectType == greatWorkType
end

--Set the Grid Hide
function DragonResetGridHide(playerID)
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        Controls.AncientCountryPanelGrid:SetHide(false)
        return true
    else
        Controls.AncientCountryPanelGrid:SetHide(true)
        return false
    end
end

--set the tech
function ResetPanelTech()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonResetGridHide(playerID) then
        local playerObj = DragonAncient:new(playerID)
        --Yield num
        local cost = playerObj:GetExtraScience()
        local string = Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_SCIENCE', cost)
        Controls.AncientScienceText:SetText(string)
        --Tool tip
        local pPlayer = Players[playerID]
        local num = pPlayer:GetStats():GetNumTechsResearched()
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_TITLE') .. '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_SCIENCE_TOOLTIP', num, cost) ..
            '[NEWLINE][NEWLINE]' .. playerObj:GetExtraTooltip() ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        Controls.AncientScienceButton:SetToolTipString(tooltip)
    end
end

--set the civic
function ResetPanelCivic()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonResetGridHide(playerID) then
        local playerObj = DragonAncient:new(playerID)
        --Yield num
        local cost = playerObj:GetExtraCulture()
        local string = Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_CULTURE', cost)
        Controls.AncientCultureText:SetText(string)
        --Tool tip
        local pPlayer = Players[playerID]
        local num = pPlayer:GetStats():GetNumCivicsCompleted()
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_TITLE') .. '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_CULTURE_TOOLTIP', num, cost) ..
            '[NEWLINE][NEWLINE]' .. playerObj:GetExtraTooltip() ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        Controls.AncientCultureButton:SetToolTipString(tooltip)
    end
end

--set the dark
function ResetPanelDark(ancient)
    --get the num
    local num = ancient:GetOutAgeCount('Dark')
    --set the num
    local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_DARK', num)
    --set the text
    Controls.AcientDrakCount:SetText(text)
    --Tool tip
    local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_DARK_TITLE', num)
    if num == 0 then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
    else
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. ancient:GetOutTooltip('Dark')
    end
    --is in dark age?
    local eras, playerID = Game.GetEras(), ancient.PlayerID
    if eras:HasDarkAge(playerID) then
        tooltip = tooltip ..
            '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_DARK_NOW') ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
            '[NEWLINE]' .. ancient:GetEnterTooltip('Dark')
    end
    tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
    --set the tooltip
    Controls.AncientDrakButton:SetToolTipString(tooltip)
end

--set the golden
function ResetPanelGolden(ancient)
    --get the num
    local num = ancient:GetOutAgeCount('Golden')
    --set the num
    local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_GOLDEN', num)
    --set the text
    Controls.AcientGoldenCount:SetText(text)
    --Tool tip
    local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_GOLDEN_TITLE', num)
    if num == 0 then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
    else
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. ancient:GetOutTooltip('Golden')
    end
    --is in golden age?
    local eras, playerID = Game.GetEras(), ancient.PlayerID
    if eras:HasGoldenAge(playerID) and not eras:HasHeroicGoldenAge(playerID) then
        tooltip = tooltip ..
            '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_GOLDEN_NOW') ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
            '[NEWLINE]' .. ancient:GetEnterTooltip('Golden')
    end
    tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
    --set the tooltip
    Controls.AncientGoldenButton:SetToolTipString(tooltip)
end

--set the heroic
function ResetPanelHeroic(ancient)
    --get the num
    local num = ancient:GetOutAgeCount('Heroic')
    --set the num
    local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_HEROIC', num)
    --set the text
    Controls.AcientHeroicCount:SetText(text)
    --Tool tip
    local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_HEROIC_TITLE', num)
    if num == 0 then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
    else
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. ancient:GetOutTooltip('Heroic')
    end
    --is in heroic age?
    local eras, playerID = Game.GetEras(), ancient.PlayerID
    if eras:HasHeroicGoldenAge(playerID) then
        tooltip = tooltip ..
            '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_HEROIC_NOW') ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
            '[NEWLINE]' .. ancient:GetEnterTooltip('Heroic')
    end
    tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
    --set the tooltip
    Controls.AncientHeroicButton:SetToolTipString(tooltip)
end

--set the counter
function ResetPanelCounter(ancient)
    --get the num
    local num    = ancient:GetEraCount()
    local dark   = ancient:GetEnterAgeCount('Dark')
    local golden = ancient:GetEnterAgeCount('Golden')
    local heroic = ancient:GetEnterAgeCount('Heroic')
    local normal = ancient:GetEnterAgeCount('Normal')
    --set the num
    local text   = Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER', num)
    --set the text
    Controls.AcientAgeCount:SetText(text)
    --Tool tip
    local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_TITLE', num) ..
        '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_EXTRA') ..
        '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_DARK', dark) ..
        '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_GOLDEN', golden) ..
        '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_HEROIC', heroic) ..
        '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_NORMAL', normal) ..
        '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_BONUS', num)
    if normal > 0 then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_NORMAL_DESC')
            .. '[NEWLINE]' .. ancient:GetOutTooltip('Normal')
    end
    local eras, playerID = Game.GetEras(), ancient.PlayerID
    if eras:HasHeroicGoldenAge(playerID) then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_HEROIC_NOW')
    elseif eras:HasGoldenAge(playerID) then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_GOLDEN_NOW')
    elseif eras:HasDarkAge(playerID) then
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_DARK_NOW')
    else
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_NORMAL_NOW')
    end
    tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
    --set the tooltip
    Controls.AncientAgeButton:SetToolTipString(tooltip)
end

--Reset the era all
function ResetEraAll()
    local playerID = Game.GetLocalPlayer()
    if DragonResetGridHide(playerID) then
        -- get the ancient
        local ancient = DragonAncient:new(playerID)
        -- reset
        ResetPanelDark(ancient)
        ResetPanelGolden(ancient)
        ResetPanelHeroic(ancient)
        ResetPanelCounter(ancient)
    end
end

--Reset all
function ResetPanelAll()
    ResetPanelTech()
    ResetPanelCivic()
    ResetEraAll()
end

--on click
function AncientScienceClicked()
    ResetPanelTech()
    UI.PlaySound('Confirm_Tech')
end

function AncientCultureClicked()
    ResetPanelCivic()
    UI.PlaySound('Confirm_Civic')
end

function AncientEraClicked()
    ResetEraAll()
    UI.PlaySound('UI_Screen_Open')
end

--||===================Events functions===================||--

--attach panel
function DragonEmperyAttachPanel()
    --get the parent
    local parent = ContextPtr:LookUpControl("/InGame/WorldTracker/PanelStack")
    if parent ~= nil then
        Controls.AncientCountryPanelGrid:ChangeParent(parent)

        Controls.AncientScienceButton:RegisterCallback(Mouse.eLClick, AncientScienceClicked)
        Controls.AncientScienceButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AncientCultureButton:RegisterCallback(Mouse.eLClick, AncientCultureClicked)
        Controls.AncientCultureButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AncientDrakButton:RegisterCallback(Mouse.eLClick, AncientEraClicked)
        Controls.AncientDrakButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AncientGoldenButton:RegisterCallback(Mouse.eLClick, AncientEraClicked)
        Controls.AncientGoldenButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AncientHeroicButton:RegisterCallback(Mouse.eLClick, AncientEraClicked)
        Controls.AncientHeroicButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AncientAgeButton:RegisterCallback(Mouse.eLClick, AncientEraClicked)
        Controls.AncientAgeButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        parent:AddChildAtIndex(Controls.AncientCountryPanelGrid, 1)
        parent:CalculateSize()
        parent:ReprocessAnchoring()
        ResetPanelAll()
    end
end

--when the era change
function DragonEmperyOnGameEraChanged()
    --get the loacl player
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --request operations
        UI.RequestPlayerOperation(playerID,
            PlayerOperations.EXECUTE_SCRIPT, {
                Age = '',
                OnStart = 'DragonEmperyOnEraChanged'
            }
        ); Network.BroadcastPlayerInfo()
    end
end

--when great person actived
--Acadmy
function AcademyOnGreatPersonActived(unitOwner, unitID, greatPersonClassID)
    --check the loacl player is the unit owner
    if unitOwner ~= Game.GetLocalPlayer() then return end
    --get the unit
    local pUnit = UnitManager.GetUnit(unitOwner, unitID)
    if pUnit then
        --get the x and y
        local x, y = pUnit:GetX(), pUnit:GetY()
        --get the city
        local pCity = Cities.GetPlotPurchaseCity(Map.GetPlot(x, y))
        if pCity == nil then return end
        --get the city building
        local cityBuildings = pCity:GetBuildings()
        if cityBuildings and cityBuildings:HasBuilding(ApricotAcademy) and not cityBuildings:IsPillaged(ApricotAcademy) then
            --request operations
            UI.RequestPlayerOperation(Game.GetLocalPlayer(),
                PlayerOperations.EXECUTE_SCRIPT, {
                    cityID = pCity:GetID(),
                    classID = greatPersonClassID,
                    OnStart = 'AcademyGreatPersonActivated'
                }
            ); Network.BroadcastPlayerInfo()
        end
    end
end

--||=================GameEvents functions=================||--

--||======================initialize======================||--

--Initialize
function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(DragonEmperyAttachPanel)
    Events.ResearchCompleted.Add(ResetPanelTech)
    Events.CivicCompleted.Add(ResetPanelCivic)
    Events.LocalPlayerChanged.Add(ResetPanelAll)
    Events.GamePropertyChanged.Add(ResetPanelAll)

    --Events.GameEraChanged.Add(DragonEmperyOnGameEraChanged)
    Events.UnitGreatPersonActivated.Add(AcademyOnGreatPersonActived)
    ---------------ExposedMembers---------------
    ExposedMembers.DragonEmpery.GetAgeType         = DragonEmperyGetPlayerAgeType
    ExposedMembers.DragonEmpery.GreatWorkTypeMatch = DragonEmperyGreatWorkTypeMatch
    --------------------------------------------
    print('Initial success!')
end

include('DragonExtraUI_', true)

Initialize()
