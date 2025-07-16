-- DragonEmpery
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/30 17:01:49
--------------------------------------------------------------
--||=======================include========================||--
include('DragonCore')
include('DragonAncient')

--||====================ExposedMembers====================||--

--ExposedMembers
ExposedMembers.DragonEmpery = ExposedMembers.DragonEmpery or {}

ExposedMembers.DragonEmpery = {
    GetBuildQueue = function(playerID, cityID)
        local city = CityManager.GetCity(playerID, cityID)
        return city:GetBuildQueue()
    end,
    GetMultiplierUsable = function(self, playerID, cityID)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return type(buildQueue.GetSalvageProgress) == 'function'
    end,
    GetBuildingMultiplier = function(self, playerID, cityID, index)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return buildQueue:GetBuildingProductionMultiplier(index)
    end,
    GetDistrictMultiplier = function(self, playerID, cityID, index)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return buildQueue:GetDistrictProductionMultiplier(index)
    end,
    GetUnitMultiplier = function(self, playerID, cityID, index)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return buildQueue:GetUnitProductionMultiplier(index)
    end,
    GetProjectMultiplier = function(self, playerID, cityID, index)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return buildQueue:GetProjectProductionMultiplier(index)
    end,
    GetSalvageProgress = function(self, playerID, cityID)
        local buildQueue = self.GetBuildQueue(playerID, cityID)
        return buildQueue:GetSalvageProgress()
    end
}

ExposedMembers.ChenHai = ExposedMembers.ChenHai or {}

--||===================glabol variables===================||--

local AgeDetail = 'DragonEmperyAgeDetail'
local modifier_1 = 'ANCIENT_COUNTRY_EXTRA_WILD_SLOT'
--the unique district
local gardenID = GameInfo.Districts['DISTRICT_DRAGON_EMPERY_GARDEN'].Index
local forestType = GameInfo.Features['FEATURE_FOREST'].Index
--great person points
local greatPersonPoints = 5

--||====================base functions====================||--

--||===================Events functions===================||--

--on the era change
function DragonEmperyOnGameEraChanged()
    --get the player
    local playerTable = {}
    for _, player in ipairs(Game.GetPlayers()) do
        if DragonCore.CheckCivMatched(player:GetID(), 'CIVILIZATION_DRAGON_EMPERY') then
            table.insert(playerTable, player)
        end
    end
    if #playerTable > 0 then
        --begin loop
        for _, player in ipairs(playerTable) do
            local playerID = player:GetID()
            --get the player object
            local playerObj = DragonAncient:new(playerID)
            local pPlayer = playerObj.Player
            --Grant a extra wild Slot
            pPlayer:AttachModifierByID(modifier_1)
            --add the total age counter
            playerObj:ChangeEraCount(1)
            --get the player left Ages
            local oldAge = pPlayer:GetProperty(AgeDetail)
            if oldAge then
                --Players are out of the Golden Age
                if oldAge['Heroic'] then
                    playerObj:AttachOutEffect('Heroic')
                    print('DragonEmpery is out of the Heroic Age!')
                    playerObj:ChangeOutAgeCount('Heroic', 1)
                elseif oldAge['Golden'] then
                    playerObj:AttachOutEffect('Golden')
                    print('DragonEmpery is out of the Golden Age!')
                    playerObj:ChangeOutAgeCount('Golden', 1)
                elseif oldAge['Dark'] then
                    playerObj:AttachOutEffect('Dark')
                    print('DragonEmpery is out of the Dark Age!')
                    playerObj:ChangeOutAgeCount('Dark', 1)
                else
                    print('DragonEmpery is out of the Normal Age!')
                end
            end
            if ExposedMembers.DragonEmpery.GetAgeType then
                local age = ExposedMembers.DragonEmpery.GetAgeType(playerID)
                if age['Heroic'] then
                    playerObj:AttachEnterEffect('Heroic')
                    print('DragonEmpery enters Heroic Age!')
                    playerObj:ChangeEnterAgeCount('Heroic', 1)
                elseif age['Golden'] then
                    playerObj:AttachEnterEffect('Golden')
                    print('DragonEmpery enters Golden Age!')
                    playerObj:ChangeEnterAgeCount('Golden', 1)
                elseif age['Dark'] then
                    playerObj:AttachEnterEffect('Dark')
                    print('DragonEmpery enters Dark Age!')
                    playerObj:ChangeEnterAgeCount('Dark', 1)
                else
                    playerObj:AttachEnterEffect('Normal')
                    print('DragonEmpery enters Normal Age.')
                    playerObj:ChangeEnterAgeCount('Normal', 1)
                end
                --reset player property
                pPlayer:SetProperty(AgeDetail, age)
            end
        end
    end

    --Refresh the panel
    Game:SetProperty('DragonPanelRefresh', true)
end

--Truns Begin
function DragonEmperyTurnActivated(playerID, first)
    if DragonCore.CheckCivMatched(playerID, 'CIVILIZATION_DRAGON_EMPERY') and first then
        --get the class player
        local playerObj = DragonAncient:new(playerID)
        local science = playerObj:GetExtraScience()
        local culture = playerObj:GetExtraCulture()
        local pPlayer = playerObj.Player
        --Get Science
        pPlayer:GetTechs():ChangeCurrentResearchProgress(science)
        --Get Culture
        pPlayer:GetCulture():ChangeCurrentCulturalProgress(culture)
        --Refresh the panel
        Game:SetProperty('DragonPanelRefresh', true)
    end
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

--||=================GameEvents functions=================||--


--when great person activated
function DragonEmperyAcademyGrantGreatPersonPoints(playerID, param)
    --get the city
    local pCity = CityManager.GetCity(playerID, param.cityID)
    --get the great person points
    local points = DragonCore:ModifyBySpeed(greatPersonPoints * pCity:GetPopulation())
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
    Events.GameEraChanged.Add(DragonEmperyOnGameEraChanged)
    Events.DistrictBuildProgressChanged.Add(DragonEmperyOnDistrictComplete)
    Events.PlayerTurnActivated.Add(DragonEmperyTurnActivated)
    -----------------GameEvents-----------------
    --GameEvents.PlayerTurnStartComplete.Add(DragonEmperyOnPlayerTurnStarted)
    GameEvents.AcademyGreatPersonActivated.Add(DragonEmperyAcademyGrantGreatPersonPoints)
    ---------------ExposedMembers---------------
    --------------------------------------------
    print('Initial success!')
end

include('DragonScripts_', true)

Initialize()
