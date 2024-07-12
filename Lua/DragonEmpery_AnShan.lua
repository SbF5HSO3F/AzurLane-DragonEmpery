-- DragonEmpery_AnShan
-- Author: jjj
-- DateCreated: 2024/7/12 18:26:03
--------------------------------------------------------------
--||=======================include========================||--
include('DragonEmpery_Core.lua')

--||=================GameEvents functions=================||--

--finish the city production
function AnShanFinishCityProduction(playerID, param)
    --get the player
    local pPlayer = Players[playerID]
    --get the city
    local pCity = CityManager.GetCity(playerID, param.CityID)
    if pCity and pPlayer then
        --get the city currently production
        local cityBuildQueue = pCity:GetBuildQueue()
        --print(cityBuildQueue:CurrentlyBuilding(), param.Production)
        if cityBuildQueue and cityBuildQueue:CurrentlyBuilding() == param.Production then
            --finish production
            cityBuildQueue:FinishProgress()
            --cost the resource
            pPlayer:GetResources():ChangeResourceAmount(param.Resource, -param.Cost)
        end
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------

    ---------------GameEvents---------------
    GameEvents.AnShanFinishProduction.Add(AnShanFinishCityProduction)
    ----------------------------------------
    print('Initial success!')
end

Initialize()
