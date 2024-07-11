-- DragonEmpery_AnShanUI
-- Author: jjj
-- DateCreated: 2024/7/10 18:13:39
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================loacl variables===================||--

local baseResProduction = 5
local effectResProduction = 10
local AnSteelIndex = GameInfo.Districts['DSITRICTS_ANSTEEL'].Index

--||====================base functions====================||--

--judge the city cost resource
function AnShanJudgeCityResource(pCity)
    local cityResource = pCity:GetProperty('AnShanCityResource')
    return cityResource == 'Aluminum' and 'Aluminum' or 'Iron'
end

--disable?
function AnShanCityDisable(pCity, resource)
    if pCity then
        --the city has the AnSteel?
        local cityDistricts = pCity.getDistricts()
        local pDistrict = cityDistricts:getDistrict(AnSteelIndex)
        if pDistrict and not pDistrict:IsPillaged() then
            --the city has the production?
            local cityBuildQueue = pCity.getBuildQueue()
            local currentProductionHash = cityBuildQueue:GetCurrentProductionTypeHash()
            if currentProductionHash ~= 0 then
                --get the city resource cost
                -- local resource = AnShanJudgeCityResource(pCity)
                --get the currently building producion need
                local productionNeed = 0
                local resourceCost = 0
                --get the currently building name
                local currentProduction = 'NONE'


                --building district unit project
                local pBuildingDef = GameInfo.Buildings[currentProductionHash]
                local pDistrictDef = GameInfo.Districts[currentProductionHash]
                local pUnitDef     = GameInfo.Units[currentProductionHash]
                local pProjectDef  = GameInfo.Projects[currentProductionHash]
                --judge the currently building
                if pBuildingDef ~= nil then
                    local index = pBuildingDef.Index
                    --get the building prduction need
                    productionNeed = cityBuildQueue:GetBuildingCost(index) - cityBuildQueue:GetBuildingProgress(index)
                    --remove the gameSpeed modifier
                    local need = DragonEmperySpeedModifier(productionNeed, true)
                    resourceCost = math.ceil(need / (resource == 'Iron' and effectResProduction or baseResProduction))
                elseif pDistrictDef ~= nil then
                    local index = pDistrictDef.Index
                    --get the district porduction need
                    productionNeed = cityBuildQueue:GetDistrictCost(index) - cityBuildQueue:GetDistrictProgress(index)
                    --remove the gameSpeed modifier
                    local need = DragonEmperySpeedModifier(productionNeed, true)
                    resourceCost = math.ceil(need / (resource == 'Iron' and effectResProduction or baseResProduction))
                elseif pUnitDef ~= nil then
                    local index = pUnitDef.Index
                    local unitProgress = cityBuildQueue:GetUnitProgress(index)
                    local eMilitaryFormationType = cityBuildQueue:GetCurrentProductionTypeModifier()
                    --judge the miliitary formation type
                    if eMilitaryFormationType == MilitaryFormationTypes.STANDARD_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitCost(index) - unitProgress
                    elseif eMilitaryFormationType == MilitaryFormationTypes.CORPS_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitCorpsCost(index) - unitProgress
                    elseif eMilitaryFormationType == MilitaryFormationTypes.ARMY_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitArmyCost(index) - unitProgress
                    end
                    --remove the gameSpeed modifier
                    local need = DragonEmperySpeedModifier(productionNeed, true)
                    resourceCost = math.ceil(need / (resource == 'Aluminum' and effectResProduction or baseResProduction))
                elseif pProjectDef ~= nil then
                    local index = pProjectDef.Index
                    --get the projecet production need
                    productionNeed = cityBuildQueue:GetProjectCost(index) - cityBuildQueue:GetProjectProgress(index)
                    --remove the gameSpeed modifier
                    local need = DragonEmperySpeedModifier(productionNeed, true)
                    resourceCost = math.ceil(need / (resource == 'Aluminum' and effectResProduction or baseResProduction))
                end
                --player has enough resources?
            else
                return true
            end
        else
            return true
        end
    else
        return true
    end
end

--||===================Events functions===================||--

--Add a button to City Panel
function AnShanOnLoadGameViewStateDone()
    --get the parent
    local pContext = ContextPtr:LookUpControl("/InGame/CityPanel/ActionStack")
    if pContext then
        Controls.AnShanCity_Stack:ChangeParent(pContext)
        -- Controls.AnShanCity_ActionButton:RegisterCallback(Mouse.eLClick, ShinanoClickedButton)
        Controls.AnShanCity_IronButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AnShanCity_AluminumButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)
        -- ShinanoButtonReset(true)
    end
end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(AnShanOnLoadGameViewStateDone)
    -- Events.CitySelectionChanged.Add(ShinanoCitySelectChange)
    -- Events.LocalPlayerChanged.Add(ShinanoResetButton)
    ---------------ExposedMembers---------------

    --------------------------------------------
    print('Initial success!')
end

Initialize()
