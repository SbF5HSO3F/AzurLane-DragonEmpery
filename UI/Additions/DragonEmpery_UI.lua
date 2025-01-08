-- DragonEmpery_UI
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/31 8:36:20
--------------------------------------------------------------
--||=======================include========================||--
include('DragonCore')

--||====================ExposedMembers====================||--

--GameEvents
----ExposedMembers.GameEvents = GameEvents
--ExposedMembers
ExposedMembers.DragonEmpery = ExposedMembers.DragonEmpery or {}

--||===================glabol variables===================||--

local ePercent = 0.02
local EraCounter = 'DragonEmperyEraCounter'
local DarkCounter = 'DragonEmperyDarkCounter'
local GoldenCounter = 'DragonEmperyGoldenCounter'
local HeroicCounter = 'DragonEmperyHeroicCounter'
local NormalCounter = 'DragonEmperyNormalCounter'
local ThroughDark = 'DragonEmperyThroughDark'
local ThroughGolden = 'DragonEmperyThroughGolden'
local ThroughHeroic = 'DragonEmperyThroughHeroic'
--great writer
local greatWriter = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_WRITER'].Index
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
function DragonResetGridHide()
    --get the loacl player
    local playerID = Game.GetLocalPlayer()
    --check the civ type
    local hide = not DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY')
    --set the hide
    Controls.AncientCountryPanelGrid:SetHide(hide)
end

--set the tech
function ResetPanelTech()
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --Yield num
        local cost = ExposedMembers.DragonEmpery.CalculateCost(playerID, ePercent, false)
        local string = Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_SCIENCE', cost)
        Controls.AncientScienceText:SetText(string)
        --Tool tip
        local pPlayer = Players[playerID]
        local num = pPlayer:GetStats():GetNumTechsResearched()
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_TITLE') .. '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_SCIENCE_TOOLTIP', num, cost) ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        Controls.AncientScienceButton:SetToolTipString(tooltip)
    end
end

--set the civic
function ResetPanelCivic()
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        local cost = ExposedMembers.DragonEmpery.CalculateCost(playerID, ePercent, true)
        local string = Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_CULTURE', cost)
        Controls.AncientCultureText:SetText(string)
        --Tool tip
        local pPlayer = Players[playerID]
        local num = pPlayer:GetStats():GetNumCivicsCompleted()
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_TITLE') .. '[NEWLINE][NEWLINE]' ..
            Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_CULTURE_TOOLTIP', num, cost) ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        Controls.AncientCultureButton:SetToolTipString(tooltip)
    end
end

--set the dark
function ResetPanelDark(gameplay, counter)
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --get the player
        local pPlayer, num, eras = Players[playerID], 0, Game.GetEras()
        if gameplay == true and counter then
            num = counter
        else
            num = pPlayer:GetProperty(ThroughDark) or 0
        end
        --set the num
        local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_DARK', num)
        --set the text
        Controls.AcientDrakCount:SetText(text)
        --Tool tip
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_DARK_TITLE', num)
        if num == 0 then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
        else
            local num1, num2, num3 = num * 4, num * 10, num * 2
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_PERMANENT_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_DARK_BUFF', num1, num2, num3)
        end
        --is in dark age?
        if eras:HasDarkAge(playerID) then
            tooltip = tooltip ..
                '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_DARK_NOW') ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_DARK_TEMP_BUFF')
        end
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        --set the tooltip
        Controls.AncientDrakButton:SetToolTipString(tooltip)
    end
end

--set the golden
function ResetPanelGolden(gameplay, counter)
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --get the player
        local pPlayer, num, eras = Players[playerID], 0, Game.GetEras()
        if gameplay == true and counter then
            num = counter
        else
            num = pPlayer:GetProperty(ThroughGolden) or 0
        end
        --set the num
        local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_GOLDEN', num)
        --set the text
        Controls.AcientGoldenCount:SetText(text)
        --Tool tip
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_GOLDEN_TITLE', num)
        if num == 0 then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
        else
            local num1, num2, num3 = num * 20, num * 2, num
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_PERMANENT_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_GOLDEN_BUFF', num1, num2, num3)
        end
        --is in golden age?
        if eras:HasGoldenAge(playerID) and not eras:HasHeroicGoldenAge(playerID) then
            tooltip = tooltip ..
                '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_GOLDEN_NOW') ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_GOLDEN_TEMP_BUFF')
        end
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        --set the tooltip
        Controls.AncientGoldenButton:SetToolTipString(tooltip)
    end
end

--set the heroic
function ResetPanelHeroic(gameplay, counter)
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --get the player
        local pPlayer, num, eras = Players[playerID], 0, Game.GetEras()
        if gameplay == true and counter then
            num = counter
        else
            num = pPlayer:GetProperty(ThroughHeroic) or 0
        end
        --set the num
        local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_HEROIC', num)
        --set the text
        Controls.AcientHeroicCount:SetText(text)
        --Tool tip
        local tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_HEROIC_TITLE', num)
        if num == 0 then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_NO_BUFF')
        else
            local num1, num2, num3, num4, num5 = num * 50, num * 25, num * 4, num * 3, num * 25
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_PERMANENT_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_HEROIC_BUFF', num1, num2, num3, num4, num5)
        end
        --is in heroic age?
        if eras:HasHeroicGoldenAge(playerID) then
            tooltip = tooltip ..
                '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_HEROIC_NOW') ..
                Locale.Lookup('LOC_ANCIENT_COUNTRY_BUFF') ..
                '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_HEROIC_TEMP_BUFF')
        end
        tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_RESET')
        --set the tooltip
        Controls.AncientHeroicButton:SetToolTipString(tooltip)
    end
end

--set the counter
function ResetPanelCounter(gameplay, param)
    --set the panel Hide
    DragonResetGridHide()
    --get the playerID
    local playerID = Game.GetLocalPlayer()
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        --get the player
        local pPlayer = Players[playerID]
        local num, dark, golden, heroic, normal = 0, 0, 0, 0, 0
        --set the parameter
        if gameplay == true and param then
            num = param.counter
            dark = param.dark
            golden = param.golden
            heroic = param.heroic
            normal = param.normal
        else
            num = pPlayer:GetProperty(EraCounter) or 0
            dark = pPlayer:GetProperty(DarkCounter) or 0
            golden = pPlayer:GetProperty(GoldenCounter) or 0
            heroic = pPlayer:GetProperty(HeroicCounter) or 0
            normal = pPlayer:GetProperty(NormalCounter) or 0
        end
        --set the num
        local text = Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER', num)
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
                .. '[NEWLINE]' .. Locale.Lookup('LOC_ANCIENT_COUNTRY_COUNTER_NORMAL_BUFF', normal, normal * 10)
        end
        local eras = Game.GetEras()
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
end

--Reset all
function ResetPanelAll()
    ResetPanelTech()
    ResetPanelCivic()
    ResetPanelDark()
    ResetPanelGolden()
    ResetPanelHeroic()
    ResetPanelCounter()
end

--Reset the era all
function ResetEraAll(table1, table2, table3, table4)
    ResetPanelDark(table1[1], table1[2])
    ResetPanelGolden(table2[1], table2[2])
    ResetPanelHeroic(table3[1], table3[2])
    ResetPanelCounter(table4[1], table4[2])
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
    ResetPanelDark()
    ResetPanelGolden()
    ResetPanelHeroic()
    ResetPanelCounter()
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
    Events.UnitGreatPersonActivated.Add(AcademyOnGreatPersonActived)
    Events.LocalPlayerChanged.Add(ResetPanelAll)
    ---------------ExposedMembers---------------
    ExposedMembers.DragonEmpery.GetAgeType         = DragonEmperyGetPlayerAgeType
    ExposedMembers.DragonEmpery.GreatWorkTypeMatch = DragonEmperyGreatWorkTypeMatch
    ExposedMembers.DragonEmpery.ResetTech          = ResetPanelTech
    ExposedMembers.DragonEmpery.ResetCivic         = ResetPanelCivic
    ExposedMembers.DragonEmpery.ResetEra           = ResetEraAll
    --------------------------------------------
    print('Initial success!')
end

include('DragonEmpery_UI_', true)

Initialize()
