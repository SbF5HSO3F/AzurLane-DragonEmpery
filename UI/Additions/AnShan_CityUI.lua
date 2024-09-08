-- DragonEmpery_AnShanUI
-- Author: jjj
-- DateCreated: 2024/7/10 18:13:39
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||====================loacl variables===================||--

local baseResProduction = 5
local multFactor = 2
local AnSteelIndex = GameInfo.Districts['DISTRICT_ANSTEEL'].Index
local ironIndex = GameInfo.Resources['RESOURCE_IRON'].Index
local aluminumIndex = GameInfo.Resources['RESOURCE_ALUMINUM'].Index

--||====================base functions====================||--

--disable?
function AnShanGetCityButtonDetail(pCity)
    --the detail that needs return
    local detail = {
        AllDisable            = true,
        Production            = baseResProduction,
        IronDisable           = false,
        IronCost              = 0,
        IronNeed              = 0,
        IronEnough            = true,
        IronProduction        = 0,
        AluminumDisable       = false,
        AluminumCost          = 0,
        AluminumNeed          = 0,
        AluminumEnough        = true,
        AluminumProduction    = 0,
        currentProduction     = 'NONE',
        currentProductionName = 'NONE',
        reason                = 'NONE',
    }
    --the production can afford
    local progress = DragonEmperyPlayerGameProgress(pCity:GetOwner())
    local base = DragonEmperySpeedModifier((1 + (multFactor - 1) * (progress / 100)) * baseResProduction)
    detail.Production = base
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
                --We can calculate the quantity we neeed
                detail.AllDisable = false
                --get the currently building producion need
                local productionNeed = 0
                --get the currently building name
                local currentProduction = 'NONE'
                --get the iron effect
                local ironOffer = base
                --get the aluminum effect
                local aluminumOffer = base


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
                    --set the effect
                    ironOffer = ironOffer * 2
                    --the currently building name
                    currentProduction = Locale.Lookup(pBuildingDef.Name)
                    detail.currentProduction = pBuildingDef.BuildingType
                elseif pDistrictDef ~= nil then
                    local index = pDistrictDef.Index
                    --get the district porduction need
                    productionNeed = cityBuildQueue:GetDistrictCost(index) - cityBuildQueue:GetDistrictProgress(index)
                    --set the effect
                    ironOffer = ironOffer * 2
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
                    --set the effect
                    aluminumOffer = aluminumOffer * 2
                elseif pProjectDef ~= nil then
                    local index = pProjectDef.Index
                    --get the projecet production need
                    productionNeed = cityBuildQueue:GetProjectCost(index) - cityBuildQueue:GetProjectProgress(index)
                    --set the effect
                    aluminumOffer = aluminumOffer * 2
                    --the currently building name
                    currentProduction = Locale.Lookup(pProjectDef.Name)
                    detail.currentProduction = pProjectDef.ProjectType
                end
                --get the iron cost
                detail.IronCost = math.ceil(productionNeed / ironOffer)
                detail.IronNeed = detail.IronCost
                --get the aluminum cost
                detail.AluminumCost = math.ceil(productionNeed / aluminumOffer)
                detail.AluminumNeed = detail.AluminumCost
                --get player resources
                local playerResources = Players[pCity:GetOwner()]:GetResources()
                local IronAmount = playerResources:GetResourceAmount(ironIndex)
                local AluminumAmount = playerResources:GetResourceAmount(aluminumIndex)
                --player has enough resources?
                if IronAmount == 0 then
                    detail.IronDisable = true
                    detail.IronEnough = false
                elseif IronAmount < detail.IronCost then
                    detail.IronCost = IronAmount
                    detail.IronEnough = false
                end
                if AluminumAmount == 0 then
                    detail.AluminumDisable = true
                    detail.AluminumEnough = false
                elseif AluminumAmount < detail.AluminumCost then
                    detail.AluminumCost = AluminumAmount
                    detail.AluminumEnough = false
                end
                -- get the offer produciton
                detail.IronProduction = ironOffer * detail.IronCost
                detail.AluminumProduction = aluminumOffer * detail.AluminumCost
                -- set the parameters
                detail.currentProductionName = currentProduction
            else
                detail.reason = Locale.Lookup('LOC_ANSTEEL_NOBUILDINGQUEUE_WARNING')
            end
        else
            detail.reason = Locale.Lookup('LOC_ANSTEEL_NOANSTEEL_WARNING')
        end
    else
        detail.reason = Locale.Lookup('LOC_ANSTEEL_NOCITY_WARNING')
    end

    return detail
end

--reset
function AnShanResetCityButton()
    --get local player
    --local localPlayer = Players[Game.GetLocalPlayer()]
    --get the selected city
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local cityDistricts = pCity:GetDistricts()
        --the city has AnSteel?
        if cityDistricts:HasDistrict(AnSteelIndex) and cityDistricts:GetDistrict(AnSteelIndex):IsComplete() then
            Controls.AnShanCity_Stack:SetHide(false)
            --get the disabled
            local detail = AnShanGetCityButtonDetail(pCity)
            local reason = detail.reason
            --the tooltip
            local tooltip1 = Locale.Lookup('LOC_DISTRICT_ANSTEEL_NAME') ..
                '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_IRON_DESC', detail.Production)
            local tooltip2 = Locale.Lookup('LOC_DISTRICT_ANSTEEL_NAME') ..
                '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_DESC', detail.Production)
            --detail is table?
            if detail.AllDisable then
                --the iron
                Controls.AnShanCity_IronButton:SetDisabled(true)
                Controls.AnShanCity_IronButton:SetAlpha(0.4)
                tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. reason

                --the Aluminum
                Controls.AnShanCity_AluminumButton:SetDisabled(true)
                Controls.AnShanCity_AluminumButton:SetAlpha(0.4)
                tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. reason
            else
                --the iron
                local ironDisable = detail.IronDisable
                Controls.AnShanCity_IronButton:SetDisabled(ironDisable)
                Controls.AnShanCity_IronButton:SetAlpha((ironDisable and 0.4) or 1)
                tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_ANSTEEL_COST_IRON_NEED', detail.currentProductionName, detail.IronNeed)
                if ironDisable then
                    tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOIRON_WARNING')
                else
                    tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_COST_IRON_DETAIL', detail.IronCost, detail.IronProduction)
                    if detail.IronEnough then
                        tooltip1 = tooltip1 ..
                        '[NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_COMPLETE', detail.currentProductionName)
                    end
                end

                --the Aluminum
                local aluminumDisable = detail.AluminumDisable
                Controls.AnShanCity_AluminumButton:SetDisabled(aluminumDisable)
                Controls.AnShanCity_AluminumButton:SetAlpha((aluminumDisable and 0.4) or 1)
                tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_NEED', detail.currentProductionName, detail.AluminumNeed)
                if aluminumDisable then
                    tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOALUMINUM_WARNING')
                else
                    tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_DETAIL', detail.AluminumCost, detail.AluminumProduction)
                    if detail.AluminumEnough then
                        tooltip2 = tooltip2 ..
                        '[NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_COMPLETE', detail.currentProductionName)
                    end
                end
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
        local detail = AnShanGetCityButtonDetail(pCity)
        if detail.AllDisable then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = ironIndex,
                Cost       = detail.IronCost,
                Production = detail.currentProduction,
                Afford     = detail.IronProduction,
                OnStart    = 'AnShanFinishProduction'
            }
        ); UI.PlaySound("Confirm_Production")
    end
end

--Aluminum button click
function AluminumIronClick()
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local detail = AnShanGetCityButtonDetail(pCity)
        if detail.AllDisable then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = aluminumIndex,
                Cost       = detail.AluminumCost,
                Production = detail.currentProduction,
                Afford     = detail.AluminumProduction,
                OnStart    = 'AnShanFinishProduction'
            }
        ); UI.PlaySound("Confirm_Production")
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
        AnShanResetCityButton()
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
        AnShanResetCityButton()
    end
end

--||======================initialize======================||--

function Initialize()
    -------------------Events-------------------
    Events.LoadGameViewStateDone.Add(AnShanOnLoadGameViewStateDone)
    Events.CitySelectionChanged.Add(AnShanCitySelectChange)
    -------------------Resets-------------------
    Events.LocalPlayerChanged.Add(AnShanResetCityButton)

    Events.DistrictAddedToMap.Add(AnShanResetCityButton)
    Events.DistrictBuildProgressChanged.Add(AnShanResetCityButton)
    Events.DistrictRemovedFromMap.Add(AnShanResetCityButton)
    Events.DistrictPillaged.Add(AnShanResetCityButton)

    Events.CityAddedToMap.Add(AnShanResetCityButton)
    Events.CityProductionQueueChanged.Add(AnShanResetCityButton)
    Events.CityProductionUpdated.Add(AnShanResetCityButton)
    Events.CityProductionChanged.Add(AnShanResetCityButton)
    Events.CityProductionCompleted.Add(AnShanResetCityButton)
    Events.CityRemovedFromMap.Add(AnShanResetCityButton)

    Events.PlayerResourceChanged.Add(AnShanResetCityButton)

    ---------------ExposedMembers---------------
    -- table.sort(arr, function (a, b) return a > b end)
    --------------------------------------------
    print('Initial success!')
end

Initialize()
