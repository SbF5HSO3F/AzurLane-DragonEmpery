-- DragonHaiTien
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/31 20:08:16
--------------------------------------------------------------
--||=======================include========================||--
include('DragonCore')

--||===================glabol variables===================||--

local modifier_1 = 'HAI_TIEN_COMBAT_BUFF'
local modifier_2 = 'HAI_TIEN_COMBAT_ATTACH'
local percent_1 = 0.2
local greatWriterID = GameInfo.GreatPersonClasses['GREAT_PERSON_CLASS_WRITER'].Index

--||===================Events functions===================||--

--GreatWork Buff
function HaiTienOnGreatWorkCreated(playerID, unitID, iCityPlotX, iCityPlotY, buildingID, greatWorkIndex)
    --is Hei Tien?
    if not DragonCore.CheckLeaderMatched(playerID, 'LEADER_HAI_TIEN') then
        return
    end

    --get the great work information
    if ExposedMembers.DragonEmpery.GreatWorkTypeMatch then
        if ExposedMembers.DragonEmpery.GreatWorkTypeMatch(greatWorkIndex, 'GREATWORKOBJECT_WRITING') then
            local pPlayer = Players[playerID]
            pPlayer:AttachModifierByID(modifier_1)
            pPlayer:AttachModifierByID(modifier_2)
        end
    else
        print('No found ExposedMembers.DragonEmpery.GreatWorkTypeMatch!')
    end
end

--On tech completed
function HaiTienOnResearchCompleted(iPlayer, iTech)
    --is hei tien?
    if DragonCore.CheckLeaderMatched(iPlayer, 'LEADER_HAI_TIEN') then
        --get the player
        local pPlayer = Players[iPlayer]
        --get the player tech
        local playerTechs = pPlayer:GetTechs()
        --get the point
        local point = DragonCore.Round(playerTechs:GetResearchCost(iTech) * percent_1)
        --grant the point
        pPlayer:GetGreatPeoplePoints():ChangePointsTotal(greatWriterID, point)
    end
end

--||=================GameEvents functions=================||--

--Activating the Cultural Value of Great Writers
function HaiTienActivateGreatWriter(playerID, param)
    --get the player
    local pPlayer = Players[playerID]
    --get the player culture
    local playerCulture = pPlayer and pPlayer:GetCulture()
    --set the element
    local culture, production, x, y = param.culture, param.production, param.x, param.y
    --grant culture
    if playerCulture then
        playerCulture:ChangeCurrentCulturalProgress(culture)
        --the float string
        local fstring = Locale.Lookup('LOC_HAI_TIEN_GREAT_WRITER_CULTURE', culture)
        --add the view
        local fstringData = {
            MessageType = 0,
            MessageText = fstring,
            PlotX       = x,
            PlotY       = y,
            Visibility  = RevealedState.VISIBLE,
        }; Game.AddWorldViewText(fstringData)
    end
    --add production
    if param.cityID then
        --get the city
        local city = CityManager.GetCity(playerID, param.cityID)
        city:GetBuildQueue():AddProgress(production)
        --the float string
        local fstring = Locale.Lookup('LOC_HAI_TIEN_GREAT_WRITER_PRODUCTION', production)
        --add the view
        local fstringData = {
            MessageType = 0,
            MessageText = fstring,
            PlotX       = city:GetX(),
            PlotY       = city:GetY(),
            Visibility  = RevealedState.VISIBLE,
        }; Game.AddWorldViewText(fstringData)
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------
    Events.GreatWorkCreated.Add(HaiTienOnGreatWorkCreated)
    Events.ResearchCompleted.Add(HaiTienOnResearchCompleted)
    ---------------GameEvents---------------
    GameEvents.HaiTienGreatWriterActivated.Add(HaiTienActivateGreatWriter)
    ----------------------------------------
    print('Initial success!')
end

include('DragonEmpery_HaiTien_', true)

Initialize()
