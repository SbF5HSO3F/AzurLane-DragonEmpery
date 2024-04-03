-- DragonEmpery_Core
-- Author: jjj
-- DateCreated: 2023/12/30 22:17:09
--------------------------------------------------------------
--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function DragonEmperyLeaderTypeMatched(playerID, LeaderTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == LeaderTpye
end

--Civilization type judgment. if macth, return true (GamePlay, UI)
function DragonEmperyCivTypeMatched(playerID, CivTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == CivTpye
end

--process rounding (GamePlay, UI)
function DragonEmperyNumRound(num)
    return math.floor((num + 0.05) * 10) / 10
end

--Game Speed Modifier (GamePlay, UI)
function DragonEmperySpeedModifier(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then
        num = DragonEmperyNumRound(num * gameSpeed.CostMultiplier / 100)
    end
    return num
end