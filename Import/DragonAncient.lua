-- DragonAncient
-- Author: HSbF6HSO3F
-- DateCreated: 2025/1/8 10:55:51
--------------------------------------------------------------
--||=======================include========================||--
include('DragonCore')

--||=======================Constants======================||--

DeafultPercent = 2

--||====================loacl variables===================||--55


--||======================MetaTable=======================||--

DragonAncient = {
    EraCounter = 'DragonEmperyEraCounter',
    --黑暗时代
    Dark = {
        Counter = 'DragonEmperyDarkCounter',
        Through = 'DragonEmperyThroughDark',
        Out = {
            --永久战斗力
            Combat = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_COMBAT_MODIFIER',
                Modifier = {
                    'ANCIENT_COUNTRY_DARK_COMBAT_BUFF',
                    'ANCIENT_COUNTRY_DARK_COMBAT_ATTACH'
                },
                AttachEffect = function(self, player)
                    if not player then return end
                    local modifiers = self.Modifier
                    player:AttachModifierByID(modifiers[1])
                    player:AttachModifierByID(modifiers[2])
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 4)
                end
            },
            --军事生产力
            Military = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_MILITARY_PRODUCTION_MODIFIER',
                Modifier = 'ANCIENT_COUNTRY_DARK_MILITARY_PRODUCTION',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 10)
                end
            },
            --忠诚度
            Loyalty = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_IDENTITY_BUFF_MODIFIER',
                Modifier = 'ANCIENT_COUNTRY_DARK_IDENTITY_BUFF',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 2)
                end
            }
        },
        Enter = {
            --获得一位大将军
            General = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_GRANT_GENERAL_MODIFIER',
                Modifier = 'ANCIENT_COUNTRY_DARK_GRANT_GENERAL',
                AttachEffect = function(self, player)
                    if not player then return end
                    local cities = player:GetCities()
                    if not cities then return end
                    local city = cities:GetCapitalCity()
                    if not city then return end
                    city:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --军事单位战斗力
            Combat = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_MILITARY_COMBAT',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --军事单位生产力
            Production = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_MILITARY_PRODUCTION',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --所有单位移动力
            Movement = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_DARK_UNIT_MOVEMENT',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            }
        }
    },
    --普通时代
    Normal = {
        Counter = 'DragonEmperyNormalCounter',
        Through = 'DragonEmperyNormalCounter',
        Enter = {
            --额外区域位置
            ExtraDistirct = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_NORMAL_EXTRA_DISTRICT',
                Modifier = 'ANCIENT_COUNTRY_NORMAL_EXTRA_DISTRICT',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --区域生产力
            DistirctProduction = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_NORMAL_DISTRICT_PRODUCTION',
                Modifier = 'ANCIENT_COUNTRY_NORMAL_DISTRICT_PRODUCTION',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            }
        },
        Out = {
            --额外区域位置
            ExtraDistirct = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_NORMAL_EXTRA_DISTRICT',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count)
                end
            },
            --区域生产力
            DistirctProduction = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_NORMAL_DISTRICT_PRODUCTION',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 10)
                end
            }
        }
    },
    --黄金时代
    Golden = {
        Counter = 'DragonEmperyGoldenCounter',
        Through = 'DragonEmperyThroughGolden',
        Enter = {
            --城市生产力
            Production = {
                Tooltip = 'LOC_DRAGON_EMPERY_GOLDEN_PRODUCTION',
                Modifier = 'DRAGON_EMPERY_GOLDEN_PRODUCTION',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --全境旅游业绩
            Tourism = {
                Tooltip = 'LOC_DRAGON_EMPERY_GOLDEN_TOURISM',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --城市宜居度
            Amenity = {
                Tooltip = 'LOC_DRAGON_EMPERY_GOLDEN_AMENITY',
                Modifier = 'DRAGON_EMPERY_GOLDEN_AMENITY',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --贸易路线金币
            TradeGold = {
                Tooltip = 'LOC_DRAGON_EMPERY_GOLDEN_TRADE_GOLD',
                Modifier = 'DRAGON_EMPERY_ATTACH_GOLDEN_TRADE_GOLD',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            }
        },
        Out = {
            --城市生产力
            Production = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_GOLDEN_OUT_CITIES_PRODUCITON',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 20)
                end
            },
            --城市宜居度
            Amenity = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_GOLDEN_OUT_CITIES_TRADE_GOLD',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count)
                end
            },
            --城市贸易金币
            TradeGold = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_GOLDEN_OUT_CITIES_AMENITIES',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 2)
                end
            }
        }
    },
    --英雄时代
    Heroic = {
        Counter = 'DragonEmperyHeroicCounter',
        Through = 'DragonEmperyThroughHeroic',
        Enter = {
            --全境旅游业绩
            Tourism = {
                Tooltip = 'LOC_DRAGON_EMPERY_HEROIC_TOURISM',
                Modifier = 'DRAGON_EMPERY_HOERIC_TOURISM',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --城市生产力
            Production = {
                Tooltip = 'LOC_DRAGON_EMPERY_HEROIC_PRODUCTION',
                Modifier = 'DRAGON_EMPERY_HOERIC_PRODUCTION',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --城市宜居度
            Amenity = {
                Tooltip = 'LOC_DRAGON_EMPERY_HEROIC_AMENITY',
                Modifier = 'DRAGON_EMPERY_HOERIC_AMENITY',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --城市贸易金币
            TradeGold = {
                Tooltip = 'LOC_DRAGON_EMPERY_ATTACH_HEROIC_TRADE_GOLD',
                Modifier = 'DRAGON_EMPERY_ATTACH_HOERIC_TRADE_GOLD',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            },
            --伟人点数
            GreatPerson = {
                Tooltip = 'LOC_DRAGON_EMPERY_HEROIC_GREAT_PERSON',
                Modifier = 'DRAGON_EMPERY_HOERIC_GREAT_PERSON',
                AttachEffect = function(self, player)
                    if not player then return end
                    player:AttachModifierByID(self.Modifier)
                end,
                GetTooltip = function(self)
                    return Locale.Lookup(self.Tooltip)
                end
            }
        },
        Out = {
            --全境旅游业绩
            Tourism = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_HEROIC_OUT_TOURISM',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 25)
                end
            },
            --城市生产力
            Production = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_HEROIC_OUT_CITIES_PRODUCITON',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 50)
                end
            },
            --城市宜居度
            Amenity = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_HEROIC_OUT_CITIES_AMENITIES',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 3)
                end
            },
            --城市贸易金币
            TradeGold = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_HEROIC_OUT_CITIES_TRADE_GOLD',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 4)
                end
            },
            --伟人点数
            GreatPerson = {
                Tooltip = 'LOC_ANCIENT_COUNTRY_HEROIC_OUT_GREAT_PERSON',
                AttachEffect = function(self, player)
                end,
                GetTooltip = function(self, count)
                    if not count or count == 0 then return end
                    return Locale.Lookup(self.Tooltip, count * 25)
                end
            }
        }
    },
    Anceint = {
        Deafult = {
            Tooltip = 'LOC_ANCIENT_COUNTRY_EXTRA_RATIO_FROM_ANCIENT',
            GetPrecent = function(self)
                return DeafultPercent
            end,
            GetTooltip = function(self)
                local ratio = self:GetPrecent()
                return ratio ~= 0 and Locale.Lookup(self.Tooltip, ratio) or ''
            end
        }
    }
}

function DragonAncient:new(playerID)
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object.PlayerID = playerID
    object.Player = Players[playerID]
    return object
end

--||====================GamePlay, UI======================||--

--玩家每回合应获得科技值文化值的百分比
function DragonAncient:GetPrecent()
    local total = 0
    for _, percent in pairs(self.Anceint) do
        total = total + percent:GetPrecent()
    end
    return total
end

--玩家科技市政转化比例tooltip
function DragonAncient:GetExtraTooltip()
    local tooltip, ratio = '', self:GetPrecent()
    tooltip = Locale.Lookup('LOC_ANCIENT_COUNTRY_EXTRA_RATIO', ratio)
    for _, percent in pairs(self.Anceint) do
        tooltip = tooltip .. percent:GetTooltip()
    end
    return tooltip
end

--玩家每回合应获得的额外科技值
function DragonAncient:GetExtraScience()
    local player = self.Player
    if not player then return 0 end
    local techs = player:GetTechs()
    local sciences = 0
    for row in GameInfo.Technologies() do
        if techs:HasTech(row.Index) then
            sciences = sciences + techs:GetResearchCost(row.Index)
        end
    end
    return DragonCore:ModifyByPercent(sciences, self:GetPrecent(), true)
end

--玩家每回合应获得的额外文化值
function DragonAncient:GetExtraCulture()
    local player = self.Player
    if not player then return 0 end
    local civics = player:GetCulture()
    local cultures = 0
    for row in GameInfo.Civics() do
        if civics:HasCivic(row.Index) then
            cultures = cultures + civics:GetCultureCost(row.Index)
        end
    end
    return DragonCore:ModifyByPercent(cultures, self:GetPrecent(), true)
end

--获取时代计数
function DragonAncient:GetEraCount()
    local player = self.Player
    if not player then return 0 end
    local EraCounter = self.EraCounter
    return player:GetProperty(EraCounter) or 0
end

--获取进入特定时代的计数
function DragonAncient:GetEnterAgeCount(age)
    local player = self.Player
    if not player then return 0 end
    local counter = self[age].Counter
    return player:GetProperty(counter) or 0
end

--获取进入特定时代的tooltip
function DragonAncient:GetEnterTooltip(age)
    local tooltip, enter = '', self[age].Enter
    if not enter then return end
    for _, effect in pairs(enter) do
        tooltip = tooltip .. effect:GetTooltip()
    end
    return tooltip
end

--获取度过特定时代的计数
function DragonAncient:GetOutAgeCount(age)
    local player = self.Player
    if not player then return 0 end
    local counter = self[age].Through
    return player:GetProperty(counter) or 0
end

--获取退出特定时代的tooltip
function DragonAncient:GetOutTooltip(age)
    local tooltip, out = '', self[age].Out
    local count = self:GetOutAgeCount(age)
    if not out then return end
    for _, effect in pairs(out) do
        tooltip = tooltip .. effect:GetTooltip(count)
    end
    return tooltip
end

--||======================GamePlay========================||--

--设置时代计数
function DragonAncient:SetEraCount(count)
    local player = self.Player
    if not player then return end
    local EraCounter = self.EraCounter
    player:SetProperty(EraCounter, count)
end

--设置进入时代的计数
function DragonAncient:SetEnterAgeCount(age, count)
    local player = self.Player
    if not player then return end
    local counter = self[age].Counter
    player:SetProperty(counter, count)
end

--设置度过时代的计数
function DragonAncient:SetOutAgeCount(age, count)
    local player = self.Player
    if not player then return end
    local counter = self[age].Through
    player:SetProperty(counter, count)
end

--改变时代计数
function DragonAncient:ChangeEraCount(num)
    self:SetEraCount(self:GetEraCount() + num)
end

--改变进入的时代计数
function DragonAncient:ChangeEnterAgeCount(age, num)
    self:SetEnterAgeCount(age, self:GetEnterAgeCount(age) + num)
end

--改变度过的时代计数
function DragonAncient:ChangeOutAgeCount(age, num)
    self:SetOutAgeCount(age, self:GetOutAgeCount(age) + num)
end

--玩家获取度过特定时代效果
function DragonAncient:AttachOutEffect(age)
    local out = self[age].Out
    if not out then return end
    local player = self.Player
    if not player then return end
    for _, effect in pairs(out) do
        effect:AttachEffect(player)
    end
end

--玩家获得进入特定时代的效果
function DragonAncient:AttachEnterEffect(age)
    local enter = self[age].Enter
    if not enter then return end
    local player = self.Player
    if not player then return end
    if not enter or not player then return end
    for _, effect in pairs(enter) do
        effect:AttachEffect(player)
    end
end

--||=======================include========================||--
include('DragonAncient_', true)
