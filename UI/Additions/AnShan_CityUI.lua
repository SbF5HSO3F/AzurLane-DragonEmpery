-- DragonEmpery_AnShanUI
-- Author: HSbF6HSO3F
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
local Utils = ExposedMembers.DragonEmpery

--||======================MetaTable=======================||--

AnShanCityPanel = {
    --Get the city button detail
    GetDetail = function(pCity)
        --the detail that needs return
        local detail = {
            ResProduction   = baseResProduction,
            IronDisable     = true,
            IronCost        = 0,
            IronOffer       = 0,
            AluminumDisable = true,
            AluminumCost    = 0,
            AluminumOffer   = 0,
            ItemType        = 'NONE',
            ItemName        = 'NONE',
            Reason          = 'NONE',
        }
        --the production can afford
        local progress = DragonCore:GetPlayerProgress(pCity:GetOwner())
        local base = DragonCore:ModifyBySpeed((1 + (multFactor - 1) * (progress / 100)) * baseResProduction)
        detail.ResProduction = base
        --the city is not nil?
        if pCity then
            --the city has the AnSteel?
            local cityDistricts = pCity:GetDistricts()
            local pDistrict = cityDistricts:GetDistrict(AnSteelIndex)
            --the AnSteel is not pillaged
            if pDistrict and not pDistrict:IsPillaged() then
                --get the city production detail
                local cityProduction = DragonCore.GetProductionDetail(pCity)
                --the city has the production?
                if cityProduction.Producting then
                    --set the ItemType and ItemName
                    detail.ItemType = cityProduction.ItemType
                    detail.ItemName = cityProduction.ItemName
                    --get the production need
                    local need = cityProduction.TotalCost - cityProduction.Progress
                    --get the city id and the owner id
                    local cityID, ownerID = pCity:GetID(), pCity:GetOwner()
                    --has the GetSalvageProgress
                    if Utils:GetMultiplierUsable(ownerID, cityID) then
                        --calaculate the production multiplier
                        local multiplier = 1
                        if cityProduction.IsBuilding then
                            multiplier = Utils:GetBuildingMultiplier(ownerID, cityID, cityProduction.ItemIndex)
                        elseif cityProduction.IsDistrict then
                            multiplier = Utils:GetDistrictMultiplier(ownerID, cityID, cityProduction.ItemIndex)
                        elseif cityProduction.IsUnit then
                            multiplier = Utils:GetUnitMultiplier(ownerID, cityID, cityProduction.ItemIndex)
                        elseif cityProduction.IsProject then
                            multiplier = Utils:GetProjectMultiplier(ownerID, cityID, cityProduction.ItemIndex)
                        end
                        --calaculate the need production
                        --use the ceil to make sure the production is enough
                        need = math.ceil((need / multiplier) - Utils:GetSalvageProgress(ownerID, cityID))
                    end
                    --Quantity required for computing resources
                    local amount = need / base
                    --Check the resource effect
                    --use the ceil to make sure the production is enough
                    if cityProduction.IsBuilding or cityProduction.IsDistrict then
                        --the Iron
                        detail.IronCost = math.ceil(amount / 2)
                        detail.IronOffer = math.floor(detail.IronCost * base * 2)
                        --the Aluminum
                        detail.AluminumCost = math.ceil(amount)
                        detail.AluminumOffer = math.floor(detail.AluminumCost * base)
                    elseif cityProduction.IsUnit or cityProduction.IsProject then
                        --the Iron
                        detail.IronCost = math.ceil(amount)
                        detail.IronOffer = math.floor(detail.IronCost * base)
                        --the Aluminum
                        detail.AluminumCost = math.ceil(amount / 2)
                        detail.AluminumOffer = math.floor(detail.AluminumCost * base * 2)
                    end
                    --get player resources
                    local playerResources = Players[pCity:GetOwner()]:GetResources()
                    local IronAmount = playerResources:GetResourceAmount(ironIndex)
                    local AluminumAmount = playerResources:GetResourceAmount(aluminumIndex)
                    --check the resource enough
                    detail.IronDisable = IronAmount < detail.IronCost
                    detail.AluminumDisable = AluminumAmount < detail.AluminumCost
                else
                    detail.Reason = Locale.Lookup('LOC_ANSTEEL_NOBUILDINGQUEUE_WARNING')
                end
            else
                detail.Reason = Locale.Lookup('LOC_ANSTEEL_NOANSTEEL_WARNING')
            end
        else
            detail.Reason = Locale.Lookup('LOC_ANSTEEL_NOCITY_WARNING')
        end
        return detail
    end,
    --Refresh the city button detail
    Refresh = function(self)
        --get the selected city
        local pCity = UI.GetHeadSelectedCity()
        if pCity then
            local cityDistricts = pCity:GetDistricts()
            --the city has AnSteel?
            if cityDistricts:HasDistrict(AnSteelIndex, true) then
                Controls.AnShanCityStack:SetHide(false)
                --get the city detail
                local detail = self.GetDetail(pCity)
                local reason = detail.Reason
                --the tooltip
                local tooltip1 = Locale.Lookup('LOC_DISTRICT_ANSTEEL_NAME') ..
                    '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_IRON_DESC', detail.ResProduction)
                local tooltip2 = Locale.Lookup('LOC_DISTRICT_ANSTEEL_NAME') ..
                    '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_DESC', detail.ResProduction)
                --set the tooltip
                if detail.IronDisable and detail.AluminumDisable then
                    --the iron
                    Controls.IronButton:SetDisabled(true)
                    Controls.IronButton:SetAlpha(0.7)
                    --the Aluminum
                    Controls.AluminumButton:SetDisabled(true)
                    Controls.AluminumButton:SetAlpha(0.7)
                    --zhe disable reason
                    if detail.ItemType == 'NONE' then
                        tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. reason
                        tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. reason
                    else
                        tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOIRON_WARNING')
                        tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOALUMINUM_WARNING')
                    end
                else
                    --set the iron button
                    local ironDisable = detail.IronDisable
                    --the button disable
                    Controls.IronButton:SetDisabled(ironDisable)
                    Controls.IronButton:SetAlpha((ironDisable and 0.7) or 1)
                    --the button tooltip
                    tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_COST_IRON_NEED', detail.ItemName, detail.IronCost, detail.IronOffer)
                    if ironDisable then
                        tooltip1 = tooltip1 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOIRON_WARNING')
                    end
                    --set the Aluminum button
                    local aluminumDisable = detail.AluminumDisable
                    --the button disable
                    Controls.AluminumButton:SetDisabled(aluminumDisable)
                    Controls.AluminumButton:SetAlpha((aluminumDisable and 0.7) or 1)
                    --the button tooltip
                    tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' ..
                        Locale.Lookup('LOC_ANSTEEL_COST_ALUMINUM_NEED', detail.ItemName, detail.AluminumCost,
                            detail.AluminumOffer)
                    if aluminumDisable then
                        tooltip2 = tooltip2 .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_ANSTEEL_NOALUMINUM_WARNING')
                    end
                end
                --set the tooltip
                Controls.IronButton:SetToolTipString(tooltip1)
                Controls.AluminumButton:SetToolTipString(tooltip2)
            else
                Controls.AnShanCityStack:SetHide(true)
            end
        else
            --hide the stack
            Controls.AnShanCityStack:SetHide(true)
        end
    end
}

--||====================base functions====================||--

--reset
function AnShanResetCityButton()
    AnShanCityPanel:Refresh()
end

--Iron button click
function AnShanIronClick()
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local detail = AnShanCityPanel.GetDetail(pCity)
        if detail.IronDisable then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = ironIndex,
                Cost       = detail.IronCost,
                Production = detail.ItemType,
                Afford     = detail.IronOffer,
                OnStart    = 'AnShanFinishProduction'
            }
        ); UI.PlaySound("Confirm_Production")
    end
end

--Aluminum button click
function AluminumIronClick()
    local pCity = UI.GetHeadSelectedCity()
    if pCity then
        local detail = AnShanCityPanel.GetDetail(pCity)
        if detail.AluminumDisable then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                CityID     = pCity:GetID(),
                Resource   = aluminumIndex,
                Cost       = detail.AluminumCost,
                Production = detail.ItemType,
                Afford     = detail.AluminumOffer,
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
        AnShanCityPanel:Refresh()
    end
end

--Add a button to City Panel
function AnShanOnLoadGameViewStateDone()
    --get the parent
    local pContext = ContextPtr:LookUpControl("/InGame/CityPanel/ActionStack")
    if pContext then
        Controls.AnShanCityStack:ChangeParent(pContext)
        Controls.IronButton:RegisterCallback(Mouse.eLClick, AnShanIronClick)
        Controls.IronButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)

        Controls.AluminumButton:RegisterCallback(Mouse.eLClick, AluminumIronClick)
        Controls.AluminumButton:RegisterCallback(Mouse.eMouseEnter, DragonEmperyEnter)
        AnShanCityPanel:Refresh()
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
