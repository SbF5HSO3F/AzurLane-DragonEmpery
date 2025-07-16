-- DragonScripts_AzurDLL
-- Author: HSbF6HSO3F
-- DateCreated: 2025/7/16 10:47:29
--------------------------------------------------------------

local gardenID = GameInfo.Districts['DISTRICT_DRAGON_EMPERY_GARDEN'].Index
local forestType = GameInfo.Features['FEATURE_FOREST'].Index

-- 使用DLL功能解决人造林问题
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
            plot:SetHasFeatureBeenAdded(false)
        end
        pDistrict:SetProperty('GardenGenerateforests', true)
    end
end
