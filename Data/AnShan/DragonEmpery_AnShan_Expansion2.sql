-- DragonEmpery_AnShan_Expansion2
-- Author: HSbF6HSO3F
-- DateCreated: 2024/7/10 10:00:36
--------------------------------------------------------------
--Update
UPDATE Districts
SET Description = 'LOC_DISTRICT_ANSTEEL_DESCRIPTION_XP2'
WHERE DistrictType = 'DISTRICT_ANSTEEL';

--District Adjacency
INSERT INTO District_Adjacencies
	(DistrictType,			YieldChangeId)
VALUES	
	('DISTRICT_ANSTEEL',	'Aqueduct_Production'),
	('DISTRICT_ANSTEEL',	'Bath_Production'),
	('DISTRICT_ANSTEEL',	'Canal_Production'),
	('DISTRICT_ANSTEEL',	'Dam_Production');

--Update
UPDATE Modifiers
SET ModifierType = 'MODIFIER_SINGLE_CITY_ADJUST_FREE_RESOURCE_EXTRACTION'
WHERE ModifierId IN (
	'ANSTEEL_GIVE_RESOURCE_IRON',
	'ANSTEEL_GIVE_RESOURCE_ALUMINUM',
	'ANSTEEL_EXTRA_RESOURCE_IRON',
	'ANSTEEL_EXTRA_RESOURCE_ALUMINUM'
);

UPDATE ModifierArguments
SET Value = Value * 2
WHERE ModifierId IN (
	'ANSTEEL_GIVE_RESOURCE_IRON',
	'ANSTEEL_GIVE_RESOURCE_ALUMINUM',
	'ANSTEEL_EXTRA_RESOURCE_IRON',
	'ANSTEEL_EXTRA_RESOURCE_ALUMINUM'
) AND Name = 'Amount';

--New
INSERT INTO DistrictModifiers
	(DistrictType,			ModifierId)
VALUES
	('DISTRICT_ANSTEEL',	'ANSTEEL_ADJUST_RESOURCE_STOCKPILE_CAP');

INSERT INTO Modifiers
	(ModifierId,								ModifierType)
VALUES
	('ANSTEEL_ADJUST_RESOURCE_STOCKPILE_CAP',	'MODIFIER_PLAYER_ADJUST_RESOURCE_STOCKPILE_CAP');

INSERT INTO ModifierArguments 
	(ModifierId,								Name,		Value)
VALUES
	('ANSTEEL_ADJUST_RESOURCE_STOCKPILE_CAP',	'Amount',	'10');