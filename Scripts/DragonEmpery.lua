-- DragonEmpery
-- Author: jjj
-- DateCreated: 2023/12/30 17:01:49
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================ExposedMembers====================||--

--ExposedMembers
ExposedMembers.DragonEmpery = ExposedMembers.DragonEmpery or {}
ExposedMembers.ChenHai = ExposedMembers.ChenHai or {}

--||===================glabol variables===================||--

local ePercent = 0.02
local AgeDetail = 'DragonEmperyAgeDetail'
local modifier_1 = 'ANCIENT_COUNTRY_EXTRA_WILD_SLOT'
local EraCounter = 'DragonEmperyEraCounter'
local DarkCounter = 'DragonEmperyDarkCounter'
local GoldenCounter = 'DragonEmperyGoldenCounter'
local HeroicCounter = 'DragonEmperyHeroicCounter'
local NormalCounter = 'DragonEmperyNormalCounter'
local ThroughDark = 'DragonEmperyThroughDark'
local ThroughGolden = 'DragonEmperyThroughGolden'
local ThroughHeroic = 'DragonEmperyThroughHeroic'
--enter normal age
local modifier_enternormal1 = 'ANCIENT_COUNTRY_NORMAL_EXTRA_DISTRICT'
local modifier_enternormal2 = 'ANCIENT_COUNTRY_NORMAL_DISTRICT_PRODUCTION'
--out of dark age
local modifier_outofdark1 = 'ANCIENT_COUNTRY_DARK_COMBAT_BUFF'
local modifier_outofdark2 = 'ANCIENT_COUNTRY_DARK_COMBAT_ATTACH'
local modifier_outofdark3 = 'ANCIENT_COUNTRY_DARK_MILITARY_PRODUCTION'
local modifier_outofdark4 = 'ANCIENT_COUNTRY_DARK_IDENTITY_BUFF'
--enter dark age
local modifier_enterdark1 = 'ANCIENT_COUNTRY_DARK_GRANT_GENERAL'
--out of golden age

--enter golden age
local modifier_entergolden1 = 'DRAGON_EMPERY_GOLDEN_PRODUCTION'
local modifier_entergolden2 = 'DRAGON_EMPERY_GOLDEN_AMENITY'
local modifier_entergolden3 = 'DRAGON_EMPERY_ATTACH_GOLDEN_TRADE_GOLD'
--out of heroic age

--enter heroic age
local modifier_enterheroic1 = 'DRAGON_EMPERY_HOERIC_TOURISM'
local modifier_enterheroic2 = 'DRAGON_EMPERY_HOERIC_PRODUCTION'
local modifier_enterheroic3 = 'DRAGON_EMPERY_HOERIC_AMENITY'
local modifier_enterheroic4 = 'DRAGON_EMPERY_ATTACH_HOERIC_TRADE_GOLD'
local modifier_enterheroic5 = 'DRAGON_EMPERY_HOERIC_GREAT_PERSON'
--the unique district
local gardenID = GameInfo.Districts['DISTRICT_DRAGON_EMPERY_GARDEN'].Index
local forestType = GameInfo.Features['FEATURE_FOREST'].Index
--great person points
local greatPersonPoints = 5

--||====================base functions====================||--

--Calculate the percentage spent on technology that has been developed
function DragonEmperyCalculateCost(playerID, percent, isCivic)
    --get player
    local pPlayer = Players[playerID]
    --if player is nil
    if not pPlayer then
        print('Player not found')
        return
    end
    --set the num
    local num = 0
    --begin calculation
    if isCivic then
        --get player culture
        local playerCulture = pPlayer:GetCulture()
        --begin loop
        for row in GameInfo.Civics() do
            if playerCulture:HasCivic(row.Index) then
                num = num + playerCulture:GetCultureCost(row.Index)
            end
        end
    else
        --get player tech
        local playerTechs = pPlayer:GetTechs()
        --begin loop
        for row in GameInfo.Technologies() do
            if playerTechs:HasTech(row.Index) then
                num = num + playerTechs:GetResearchCost(row.Index)
            end
        end
    end
    --process rounding
    num = DragonEmperyNumRound(num * percent)
    --return the number
    --print('The ' .. (isCivic and 'Culture' or 'Science') .. ' is ' .. num)
    return num
end

--||===================Events functions===================||--

function DragonEmperyOnEraChanged()
    --get the player
    local playerTable = {}
    for _, player in ipairs(Game.GetPlayers()) do
        if DragonEmperyCivTypeMatched(player:GetID(), 'CIVILIZATION_DRAGON_EMPERY') then
            table.insert(playerTable, player)
        end
    end

    if #playerTable > 0 then
        --begin loop
        for _, pPlayer in ipairs(playerTable) do
            --Grant a extra wild Slot
            pPlayer:AttachModifierByID(modifier_1)
            --add the player era counter
            pPlayer:SetProperty(EraCounter, (pPlayer:GetProperty(EraCounter) or 0) + 1)
            --get the player left Ages
            local oldAge = pPlayer:GetProperty(AgeDetail)
            if oldAge then
                --Players are out of the Golden Age
                if oldAge['Heroic'] then
                    print('DragonEmpery is out of the Heroic Age!')
                    pPlayer:SetProperty(ThroughHeroic, (pPlayer:GetProperty(ThroughHeroic) or 0) + 1)
                elseif oldAge['Golden'] then
                    print('DragonEmpery is out of the Golden Age!')
                    pPlayer:SetProperty(ThroughGolden, (pPlayer:GetProperty(ThroughGolden) or 0) + 1)
                elseif oldAge['Dark'] then
                    --Grant Ability to military units
                    pPlayer:AttachModifierByID(modifier_outofdark1)
                    --adjust the unit property, It's about boosting combat strength
                    pPlayer:AttachModifierByID(modifier_outofdark2)
                    --add production when producing military units
                    pPlayer:AttachModifierByID(modifier_outofdark3)
                    --add indentity
                    pPlayer:AttachModifierByID(modifier_outofdark4)
                    print('DragonEmpery is out of the Dark Age!')
                    pPlayer:SetProperty(ThroughDark, (pPlayer:GetProperty(ThroughDark) or 0) + 1)
                else
                    print('DragonEmpery is out of the Normal Age!')
                end
            end
            --Determining the era in which a player enters
            if ExposedMembers.DragonEmpery.GetAgeType then
                local playerID = pPlayer:GetID()
                local age = ExposedMembers.DragonEmpery.GetAgeType(playerID)
                if age['Heroic'] then
                    --add player tourism
                    pPlayer:AttachModifierByID(modifier_enterheroic1)
                    --add city production
                    pPlayer:AttachModifierByID(modifier_enterheroic2)
                    --add city amenity
                    pPlayer:AttachModifierByID(modifier_enterheroic3)
                    --add player trade yield
                    pPlayer:AttachModifierByID(modifier_enterheroic4)
                    --add player great persom
                    pPlayer:AttachModifierByID(modifier_enterheroic5)
                    print('DragonEmpery enters Heroic Age!')
                    pPlayer:SetProperty(HeroicCounter, (pPlayer:GetProperty(HeroicCounter) or 0) + 1)
                elseif age['Golden'] then
                    --add the city production
                    pPlayer:AttachModifierByID(modifier_entergolden1)
                    --add city amenity
                    pPlayer:AttachModifierByID(modifier_entergolden2)
                    --add player trade yield
                    pPlayer:AttachModifierByID(modifier_entergolden3)
                    print('DragonEmpery enters Golden Age!')
                    pPlayer:SetProperty(GoldenCounter, (pPlayer:GetProperty(GoldenCounter) or 0) + 1)
                elseif age['Dark'] then
                    --grant a general
                    local pCity = pPlayer:GetCities():GetCapitalCity()
                    if pCity then
                        pCity:AttachModifierByID(modifier_enterdark1)
                    end
                    print('DragonEmpery enters Dark Age!')
                    pPlayer:SetProperty(DarkCounter, (pPlayer:GetProperty(DarkCounter) or 0) + 1)
                else
                    --extra districts
                    pPlayer:AttachModifierByID(modifier_enternormal1)
                    --production modifier when producted districts
                    pPlayer:AttachModifierByID(modifier_enternormal2)
                    print('DragonEmpery enters Normal Age.')
                    pPlayer:SetProperty(NormalCounter, (pPlayer:GetProperty(NormalCounter) or 0) + 1)
                end
                --reset player property
                pPlayer:SetProperty(AgeDetail, age)
                --reset the panel
                ExposedMembers.DragonEmpery.ResetEra({
                    true, pPlayer:GetProperty(ThroughDark) or 0
                }, {
                    true, pPlayer:GetProperty(ThroughGolden) or 0
                }, {
                    true, pPlayer:GetProperty(ThroughHeroic) or 0
                }, {
                    true, {
                    counter = pPlayer:GetProperty(EraCounter) or 0,
                    dark = pPlayer:GetProperty(DarkCounter) or 0,
                    golden = pPlayer:GetProperty(GoldenCounter) or 0,
                    heroic = pPlayer:GetProperty(HeroicCounter) or 0,
                    normal = pPlayer:GetProperty(NormalCounter) or 0,
                }
                })
            else
                print('No ExposedMembers.DragonEmpery.GetAgeType!')
            end
        end
    end
end

--Truns Begin
function DragonEmperyTurnActivated(playerID, first)
    if DragonEmperyCivTypeMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') and first then
        local pPlayer = Players[playerID]
        --Get Culture
        pPlayer:GetCulture():ChangeCurrentCulturalProgress(DragonEmperyCalculateCost(playerID, ePercent, true))
        --Get Science
        pPlayer:GetTechs():ChangeCurrentResearchProgress(DragonEmperyCalculateCost(playerID, ePercent, false))
        --Reset the civic and tech panel
        ExposedMembers.DragonEmpery.ResetCivic()
        ExposedMembers.DragonEmpery.ResetTech()
    end
end

--||=================GameEvents functions=================||--

--Truns Begin TerrainBuilder.SetFeatureType
function DragonEmperyOnPlayerTurnStarted(playerID)
    --Is it Dragon Empery Civilization?
    if not DragonEmperyCivTypeMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') then
        return
    end

    local pPlayer = Players[playerID]
    --Get Culture
    pPlayer:GetCulture():ChangeCurrentCulturalProgress(DragonEmperyCalculateCost(playerID, ePercent, true))
    ExposedMembers.DragonEmpery.ResetCivic()
    --Get Science
    pPlayer:GetTechs():ChangeCurrentResearchProgress(DragonEmperyCalculateCost(playerID, ePercent, false))
    ExposedMembers.DragonEmpery.ResetTech()
end

--garden complete
function DragonEmperyOnDistrictComplete(playerID, districtID, cityID, iX, iY, districtType, era, civ, percentComplete)
    --get the player
    local pPlayer = Players[playerID]
    --get the district
    local pDistrict = pPlayer and pPlayer:GetDistricts():FindID(districtID)
    if pDistrict and pDistrict:GetProperty('GardenGenerateforests') ~= true and districtType == gardenID and percentComplete == 100 then
        local tNeighborPlots = Map.GetAdjacentPlots(iX, iY)
        for _, plot in ipairs(tNeighborPlots) do
            if TerrainBuilder.CanHaveFeature(plot, forestType) then
                TerrainBuilder.SetFeatureType(plot, forestType)
            end
        end
        pDistrict:SetProperty('GardenGenerateforests', true)
    end
end

--when great person activated
function DragonEmperyAcademyGrantGreatPersonPoints(playerID, param)
    --get the city
    local pCity = CityManager.GetCity(playerID, param.cityID)
    --get the great person points
    local points = DragonEmperySpeedModifier(greatPersonPoints * pCity:GetPopulation())
    --change the great person points
    local pPlayer = Players[playerID]
    pPlayer:GetGreatPeoplePoints():ChangePointsTotal(param.classID, points)
    --get the great person name
    local name = GameInfo.GreatPersonClasses[param.classID].Name
    --set the string
    local fstring = Locale.Lookup('LOC_APRICOT_ACADEMY_GREAT_PERSON_DETAIL', points, name)
    --Add the message
    local fstringData = {
        MessageType = 0,
        MessageText = fstring,
        PlotX       = pCity:GetX(),
        PlotY       = pCity:GetY(),
        Visibility  = RevealedState.VISIBLE,
    }; Game.AddWorldViewText(fstringData)
end

--||======================initialize======================||--

--Initialize
function Initialize()
    -------------------Events-------------------
    Events.GameEraChanged.Add(DragonEmperyOnEraChanged)
    Events.DistrictBuildProgressChanged.Add(DragonEmperyOnDistrictComplete)
    Events.PlayerTurnActivated.Add(DragonEmperyTurnActivated)
    -----------------GameEvents-----------------
    --GameEvents.PlayerTurnStartComplete.Add(DragonEmperyOnPlayerTurnStarted)
    GameEvents.AcademyGreatPersonActivated.Add(DragonEmperyAcademyGrantGreatPersonPoints)
    ---------------ExposedMembers---------------
    ExposedMembers.DragonEmpery.CalculateCost = DragonEmperyCalculateCost
    --------------------------------------------
    print('DragonEmpery Initial success!')
end

Initialize()
