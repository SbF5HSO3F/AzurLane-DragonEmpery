-- DragonEmpery_SecretSocieties
-- Author: jjj
-- DateCreated: 2024/2/25 15:40:04
--------------------------------------------------------------
INSERT INTO BuildingPrereqs
		(Building,						PrereqBuilding)
VALUES	('BUILDING_ALCHEMICAL_SOCIETY',	'BUILDING_APRICOT_ACADEMY');

INSERT INTO District_Adjacencies
		(DistrictType,						YieldChangeId)
VALUES	('DISTRICT_DRAGON_EMPERY_GARDEN',	'LeyLine_Science');