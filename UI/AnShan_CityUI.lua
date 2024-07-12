-- DragonEmpery_AnShanUI
-- Author: jjj
-- DateCreated: 2024/7/10 18:13:39
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================loacl variables===================||--

local baseResProduction = DragonEmperySpeedModifier(5)
local effectResProduction = baseResProduction * 2
local AnSteelIndex = GameInfo.Districts['DSITRICTS_ANSTEEL'].Index
local ironIndex = GameInfo.Resources['RESOURCE_IRON'].Index
local aluminumIndex = GameInfo.Resources['RESOURCE_ALUMINUM'].Index

--||====================base functions====================||--

--judge the city cost resource
function AnShanJudgeCityResource(pCity)
    local cityResource = pCity:GetProperty('AnShanCityResource')
    return cityResource == 'Aluminum' and 'Aluminum' or 'Iron'
end

--disable?
function AnShanButtonDisable(pCity)
    --if resource is nil, that is Iron
    if pCity then
        --the city has the AnSteel?
        local cityDistricts = pCity:GetDistricts()
        local pDistrict = cityDistricts:GetDistrict(AnSteelIndex)
        if pDistrict and not pDistrict:IsPillaged() then
            --the city has the production?
            local cityBuildQueue = pCity:GetBuildQueue()
            local currentProductionHash = cityBuildQueue:GetCurrentProductionTypeHash()
            if currentProductionHash ~= 0 then
                --create a new table to record the detail
                local detail = {
                    IronDisable = false,
                    IronCost = 0,
                    AluminumDisable = false,
                    AluminumCost = 0,
                    currentProduction = 'NONE'
                }
                --get the city resource cost
                -- local resource = AnShanJudgeCityResource(pCity)
                --get the currently building producion need
                local productionNeed = 0
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
                    --get the iron cost
                    detail.IronCost = math.ceil(productionNeed / effectResProduction)
                    --get the aluminum cost
                    detail.AluminumCost = math.ceil(productionNeed / baseResProduction)
                    --the currently building name
                    currentProduction = Locale.Lookup(pBuildingDef.Name)
                    detail.currentProduction = pBuildingDef.BuildingType
                elseif pDistrictDef ~= nil then
                    local index = pDistrictDef.Index
                    --get the district porduction need
                    productionNeed = cityBuildQueue:GetDistrictCost(index) - cityBuildQueue:GetDistrictProgress(index)
                    --get the iron cost
                    detail.IronCost = math.ceil(productionNeed / effectResProduction)
                    --get the aluminum cost
                    detail.AluminumCost = math.ceil(productionNeed / baseResProduction)
                    --the currently building name
                    currentProduction = Locale.Lookup(pDistrictDef.Name)
                    detail.currentProduction = pDistrictDef.DistrictType
                elseif pUnitDef ~= nil then
                    local index = pUnitDef.Index
                    local unitProgress = cityBuildQueue:GetUnitProgress(index)
                    local eMilitaryFormationType = cityBuildQueue:GetCurrentProductionTypeModifier()
                    --the currently building name
                    currentProduction = Locale.Lookup(pUnitDef.Name)
                    detail.currentProduction = pUnitDef.UnitType
                    --judge the miliitary formation type
                    if eMilitaryFormationType == MilitaryFormationTypes.STANDARD_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitCost(index) - unitProgress
                    elseif eMilitaryFormationType == MilitaryFormationTypes.CORPS_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitCorpsCost(index) - unitProgress
                        if (pUnitDef.Domain == "DOMAIN_SEA") then
                            -- Concatenanting two fragments is not loc friendly.  This needs to change.
                            currentProduction = currentProduction .. " " .. Locale.Lookup("LOC_UNITFLAG_FLEET_SUFFIX");
                        else
                            -- Concatenanting two fragments is not loc friendly.  This needs to change.
                            currentProduction = currentProduction .. " " .. Locale.Lookup("LOC_UNITFLAG_CORPS_SUFFIX");
                        end
                    elseif eMilitaryFormationType == MilitaryFormationTypes.ARMY_FORMATION then
                        productionNeed = cityBuildQueue:GetUnitArmyCost(index) - unitProgress
                        if (pUnitDef.Domain == "DOMAIN_SEA") then
                            -- Concatenanting two fragments is not loc friendly.  This needs to change.
                            currentProduction = currentProduction .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMADA_SUFFIX");
                        else
                            -- Concatenanting two fragments is not loc friendly.  This needs to change.
                            currentProduction = currentProduction .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMY_SUFFIX");
                        end
                    end
                    --get the iron cost
                    detail.IronCost = math.ceil(productionNeed / baseResProduction)
                    --get the aluminum cost
                    detail.AluminumCost = math.ceil(productionNeed / effectResProduction)
                elseif pProjectDef ~= nil then
                    local index = pProjectDef.Index
                    --get the projecet production need
                    productionNeed = cityBuildQueue:GetProjectCost(index) - cityBuildQueue:GetProjectProgress(index)
                    --get the iron cost
                    detail.IronCost = math.ceil(productionNeed / baseResProduction)
                    --get the aluminum cost
                    detail.AluminumCost = math.ceil(productionNeed / effectResProduction)
                    --the currently building name
                    currentProduction = Locale.Lookup(pProjectDef.Name)
                    detail.currentProduction = pProjectDef.ProjectType
                end
                --get player resources
                local playerResources = Players[pCity:GetOwner()]:GetResources()
                local IronAmount = playerResources:GetResourceAmount(ironIndex)
                local AluminumAmount = playerResources:GetResourceAmount(aluminumIndex)
                --player has enough resources?
                detail.IronDisable = IronAmount < detail.IronCost
                detail.AluminumDisable = AluminumAmount < detail.AluminumCost
                --return the detial to reset the button
                return detail, currentProduction
            else
                return true, Locale.Lookup('LOC_ANSTEEL_NOBUILDINGQUEUE_WARNING')
            end
        else
            return true, Locale.Lookup('LOC_ANSTEEL_NOANSTEEL_WARNING')
        end
    else
        return true, Locale.Lookup('LOC_ANSTEEL_NOCITY_WARNING')
    end
end

--reset
function AnShanButtonReset()
    --get local player
    --local localPlayer = Players[Game.GetLocalPlayer()]
    --get the selected city
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local cityDistricts = pCity:GetDistricts()
        --the city has AnSteel?
        if cityDistricts:HasDistrict(AnSteelIndex) and cityDistricts:GetDistrict(AnSteelIndex):IsComplete() then
            Controls.AnShanCity_Stack:SetHide(false)
            --the tooltip
            local tooltip1 = Locale.Lookup('LOC_DSITRICTS_ANSTEEL_NAME') ..
                '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_IRON_DESC', baseResProduction)
            local tooltip2 = Locale.Lookup('LOC_DSITRICTS_ANSTEEL_NAME') ..
                '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_DESC', baseResProduction)
            --get the disabled
            local detail, reason = AnShanButtonDisable(pCity)
            --detail is table?
            if type(detail) == 'table' then
                --the iron
                local ironDisable = detail.IronDisable
                Controls.AnShanCity_IronButton:SetDisabled(ironDisable)
                Controls.AnShanCity_IronButton:SetAlpha((ironDisable and 0.4) or 1)
                tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_ANSTEEL_COST_IRON_DETAIL', detail.IronCost, reason)
                if ironDisable then
                    tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_NOIRON_WARNING')
                end

                --the Aluminum
                local aluminumDisable = detail.AluminumDisable
                Controls.AnShanCity_AluminumButton:SetDisabled(aluminumDisable)
                Controls.AnShanCity_AluminumButton:SetAlpha((aluminumDisable and 0.4) or 1)
                tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_DETAIL', detail.AluminumCost, reason)
                if aluminumDisable then
                    tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_NOALUMINUM_WARNING')
                end
            else
                --the iron
                Controls.AnShanCity_IronButton:SetDisabled(true)
                Controls.AnShanCity_IronButton:SetAlpha(0.4)
                tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. reason

                --the Aluminum
                Controls.AnShanCity_AluminumButton:SetDisabled(true)
                Controls.AnShanCity_AluminumButton:SetAlpha(0.4)
                tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. reason
            end
            --set the tooltip
            Controls.AnShanCity_IronButton:SetToolTipString(tooltip1)
            Controls.AnShanCity_AluminumButton:SetToolTipString(tooltip2)
        else
            Controls.AnShanCity_Stack:SetHide(true)
        end
    else
        Controls.AnShanCity_Stack:SetHide(true)
    end
end

--Iron button click
function AnShanIronClick()
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local detail = AnShanButtonDisable(pCity)
        if type(detail) ~= "table" then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = ironIndex,
                Cost       = detail.IronCost,
                Production = detail.currentProduction,
                OnStart    = 'AnShanFinishProduction'
            })
    end
end

--Aluminum button click
function AluminumIronClick()
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local detail = AnShanButtonDisable(pCity)
        if type(detail) ~= "table" then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = aluminumIndex,
                Cost       = detail.AluminumCost,
                Production = detail.currentProduction,
                OnStart    = 'AnShanFinishProduction'
            })
    end
end

--||===================Events functions===================||--

--On City Selection change
function AnShanCitySelectChange(owner, cityID, i, j, k, isSelected)
    --get the local player
    local loaclPlayerID = Game.GetLocalPlayer()
    --check the leader
    if owner == loaclPlayerID and isSelected then
        --Reset the button
        AnShanButtonReset()
    end
end

--Add a button to City Panel
function AnShanOnLoadGameViewStateDone()
    --get the parent
    local pContext = ContextPtr:LookUpControl("/InGame/CityPanel/ActionStack")
    if pContext then
        Controls.AnShanCity_Stack:ChangeParent(pContext)
        Controls.AnShanCity_IronButton:RegisterCallback(Mouse.eLClick, AnShanIronClick)
        Controls.AnShanCity_IronButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AnShanCity_AluminumButton:RegisterCallback(Mouse.eLClick, AluminumIronClick)
        Controls.AnShanCity_AluminumButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)
        -- ShinanoButtonReset(true)
        AnShanButtonReset()
    end
end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(AnShanOnLoadGameViewStateDone)
    Events.CitySelectionChanged.Add(AnShanCitySelectChange)
    -------------------Resets-------------------
    Events.LocalPlayerChanged.Add(AnShanButtonReset)

    Events.DistrictAddedToMap.Add(AnShanButtonReset)
    Events.DistrictBuildProgressChanged.Add(AnShanButtonReset)
    Events.DistrictRemovedFromMap.Add(AnShanButtonReset)
    Events.DistrictPillaged.Add(AnShanButtonReset)

    Events.CityAddedToMap.Add(AnShanButtonReset)
    Events.CityProductionQueueChanged.Add(AnShanButtonReset)
    Events.CityProductionUpdated.Add(AnShanButtonReset)
    Events.CityProductionChanged.Add(AnShanButtonReset)
    Events.CityProductionCompleted.Add(AnShanButtonReset)
    Events.CityAddedToMap.Add(AnShanButtonReset)

    Events.PlayerResourceChanged.Add(AnShanButtonReset)
    ---------------ExposedMembers---------------

    --------------------------------------------
    print('Initial success!')
end

Initialize()
