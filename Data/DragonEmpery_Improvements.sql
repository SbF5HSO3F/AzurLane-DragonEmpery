-- DragonEmpery_Improvements
-- Author: jjj
-- DateCreated: 2024/1/1 9:16:48
--------------------------------------------------------------
CREATE TEMPORARY TABLE temp_DragonEmperyWall_Table1 (
     District TEXT,
     DistrictType TEXT
);

CREATE TEMPORARY TABLE temp_DragonEmperyWall_Table2 (
     District TEXT,
     DistrictType TEXT
);

INSERT INTO temp_DragonEmperyWall_Table1
		(District,									DistrictType)
SELECT	LOWER(REPLACE(DistrictType,'DISTRICT_','')),DistrictType
FROM Districts WHERE DistrictType IN (SELECT CivUniqueDistrictType FROM DistrictReplaces WHERE ReplacesDistrictType = 'DISTRICT_CAMPUS');

INSERT INTO temp_DragonEmperyWall_Table2
		(District,									DistrictType)
SELECT	LOWER(REPLACE(DistrictType,'DISTRICT_','')),DistrictType
FROM Districts WHERE DistrictType IN (SELECT CivUniqueDistrictType FROM DistrictReplaces WHERE ReplacesDistrictType = 'DISTRICT_HOLY_SITE');

INSERT INTO Adjacency_YieldChanges
		(ID,											AdjacentDistrict,	YieldChange,YieldType,		Description,	ObsoleteCivic)
SELECT	'DragonEmpery_Wall_' || District || '_Science1',DistrictType,		1,			'YIELD_SCIENCE','Placeholder',	NULL
FROM temp_DragonEmperyWall_Table1
UNION
SELECT	'DragonEmpery_Wall_' || District || '_Faith1',	DistrictType,		1,			'YIELD_FAITH',	'Placeholder',	NULL
FROM temp_DragonEmperyWall_Table2;

/*INSERT INTO Adjacency_YieldChanges
		(ID,											AdjacentDistrict,	YieldChange,YieldType,		Description,	PrereqCivic)
SELECT	'DragonEmpery_Wall_' || District || '_Science2',DistrictType,		2,			'YIELD_SCIENCE','Placeholder',	'CIVIC_RECORDED_HISTORY'
FROM temp_DragonEmperyWall_Table1
UNION
SELECT	'DragonEmpery_Wall_' || District || '_Faith2',	DistrictType,		2,			'YIELD_FAITH',	'Placeholder',	'CIVIC_THEOLOGY'
FROM temp_DragonEmperyWall_Table2;*/

INSERT INTO Improvement_Adjacencies
		(ImprovementType,					YieldChangeId)
SELECT	'IMPROVEMENT_DRAGON_EMPERY_WALL',	'DragonEmpery_Wall_' || District || '_Science1'
FROM temp_DragonEmperyWall_Table1
UNION
SELECT	'IMPROVEMENT_DRAGON_EMPERY_WALL',	'DragonEmpery_Wall_' || District || '_Faith1'
FROM temp_DragonEmperyWall_Table2;
/*UNION
SELECT	'IMPROVEMENT_DRAGON_EMPERY_WALL',	'DragonEmpery_Wall_' || District || '_Science2'
FROM temp_DragonEmperyWall_Table1
UNION
SELECT	'IMPROVEMENT_DRAGON_EMPERY_WALL',	'DragonEmpery_Wall_' || District || '_Faith2'
FROM temp_DragonEmperyWall_Table2;*/