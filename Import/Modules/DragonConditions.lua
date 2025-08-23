-- DragonConditions
-- Author: jjj
-- DateCreated: 2025/8/23 9:37:39
--------------------------------------------------------------
--||======================MetaTable=======================||--

-- DragonConditions用于创建条件判断的文本，用于游戏的显示
DragonConditions = {}

--||===================local variables====================||--

local tab1 = '[ICON_DragonTab0]' -- '├'
local tab2 = '[ICON_DragonTab1]' -- '│'
local tab3 = '[ICON_DragonTab2]' -- '└'
local tab4 = '[ICON_DragonTab3]' -- ' '

--||====================Based functions===================||--

--获取条件集合的标题
function DragonConditions:GetTitle(conditions)
    if conditions.Title then return conditions.Title end
    local suffix = conditions.All and '_ALL' or '_ANY'
    if conditions.Not == true then suffix = suffix .. '_NOT' end
    return Locale.Lookup('LOC_AZURLANE_CONDITIONS' .. suffix)
end

--创建条件判断的文本
function DragonConditions:Create(conditions, tab, output)
    --制表字符
    tab = tab or ''
    --定义输出的文本集合
    local tooltips = {}
    --定义条件的表
    local sets = {}
    for i, set in ipairs(conditions.Sets) do
        if type(set) == 'table' then
            table.insert(sets, { tab .. tab1, i, true })
        else
            table.insert(sets, { tab .. tab1, i, set })
        end
    end
    --完毕，获取条件数量
    local sc = #sets
    if sc == 0 then return '' end
    --设置最后一个元素的分隔符
    sets[sc][1] = tab .. tab3
    --遍历条件
    for i, set in ipairs(sets) do
        --如果该条件是条件集合，则递归调用
        if set[3] == true then
            --设置缩进
            local ntab = tab .. (i == sc and tab4 or tab2)
            local subset = conditions.Sets[set[2]]
            --获取子条件集合
            local subSets = self:Create(subset, ntab)
            --如果子条件集合不为空，则添加到tooltips中
            if subSets ~= '' then
                local title = self:GetTitle(subset)
                table.insert(tooltips, set[1] .. title)
                for _, t in ipairs(subSets) do
                    table.insert(tooltips, t)
                end
            end
        else
            --否则，直接添加到tooltips中
            table.insert(tooltips, set[1] .. set[3])
        end
    end
    --如果输出为true，则返回tooltips，否则返回数组或字符串
    if output == true then
        local tooltip = ''
        for _, tip in ipairs(tooltips) do
            tooltip = tooltip .. '[NEWLINE]' .. tip
        end
        return tooltip
    else
        return tooltips
    end
end

--创建条件判断的文本，附带标题
function DragonConditions:CreateTooltip(conditions)
    local title = '[NEWLINE]' .. self:GetTitle(conditions)
    return title .. self:Create(conditions, nil, true)
end
