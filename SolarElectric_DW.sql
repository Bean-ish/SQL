USE SolarElectirc
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[factSE]') AND type in (N'U'))
DROP TABLE [dbo].[factSE]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SEStaging]') AND type in (N'U'))
DROP TABLE [dbo].[SEStaging]
GO
-- Define:


CREATE TABLE [dbo].[SEStaging](
    ReportingPeriodDate DATE,
    ProjectNumber VARCHAR(50),  -- unique identifier
    LegacyProjectNumber VARCHAR(50),
    StreetAddress VARCHAR(255),
    City VARCHAR(30), --
    County VARCHAR(20), -- dim
    State VARCHAR(10),
    ZIPCode VARCHAR(5),
    IncorporatedMunicipality VARCHAR(30), --
    MunicipalityType VARCHAR(5), -- 2d
    CensusTract VARCHAR(15), -- another identifier
    NYSDisadvantagedCommunityStatus VARCHAR(20),  -- 2d
    ClimateAndEconomicJusticeScreeningToolStatus VARCHAR(20),  -- 2d
    Sector VARCHAR(20),  -- 2d
    ProgramType VARCHAR(50),  -- 3d
    Solicitation VARCHAR(50),
    ElectricUtility VARCHAR(50),
    PurchaseType VARCHAR(50), -- 3d
    DateApplicationReceived DATE,
    DateCompleted DATE,
    ProjectStatus VARCHAR(50), -- 2d
    Contractor VARCHAR(100),  
    MinorityOrWomenOwnedBusinessEnterprise VARCHAR(5), -- 2d
    PrimaryInverterManufacturer VARCHAR(100),
    PrimaryInverterModelNumber VARCHAR(100),
    TotalInverterQuantity INT,
    PrimaryPVModuleManufacturer VARCHAR(100),
    PVModuleModelNumber VARCHAR(100),
    TotalPVModuleQuantity INT,
    ProjectCost MONEY, 
    TotalNYSERDAIncentive MONEY,
    AffordableSolarResidentialAdder MONEY,
    AffordableMultifamilyHousingIncentive MONEY,
    CommunityAdder MONEY,
    InclusiveCommunitySolarAdder MONEY,
    ExpandedSolarForAllAdder MONEY,
    BrownfieldLandfillAdder MONEY,
    CanopyAdder MONEY,
    PrevailingWageAdder MONEY,
    TotalNameplateKWDc DECIMAL(18, 2),
    ExpectedKWhAnnualProduction DECIMAL(18, 2),
    RemoteNetMetering VARCHAR(5), -- 2d
    CommunityDistributedGeneration VARCHAR(5), -- 2d
    GreenJobsGreenNewYorkParticipant VARCHAR(5), --2d
    Latitude DECIMAL(9, 6),
    Longitude DECIMAL(9, 6),
    Georeference VARCHAR(100)
)

BULK INSERT SEStaging
FROM 'C:\solar\\Solar_Electric_240407.csv'
WITH(
	FORMAT='CSV',
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    ROWTERMINATOR = '0x0a'
)


SELECT *
FROM SEStaging


--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
-- create dimension tables --

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimCounty]') AND type in (N'U'))
DROP TABLE [dbo].[dimCounty]
GO

CREATE TABLE [dbo].[dimCounty](
	CountyID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimCounty_County PRIMARY KEY CLUSTERED(CountyID),
	County	varchar(20)
)
-------------------------------------------
--	Load table
INSERT INTO dimCounty
	SELECT	DISTINCT County
	FROM SEStaging
	ORDER BY County

SELECT *
FROM dimCounty

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimMunicipalityType]') AND type in (N'U'))
DROP TABLE [dbo].[dimMunicipalityType]
GO

CREATE TABLE [dbo].[dimMunicipalityType](
	MunicipalityTypeID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimMunicipalityType_MunicipalityType PRIMARY KEY CLUSTERED(MunicipalityTypeID),
	MunicipalityType	varchar(5)
)
-------------------------------------------
--	Load table
INSERT INTO dimMunicipalityType
	SELECT	DISTINCT MunicipalityType
	FROM SEStaging

SELECT *
FROM dimMunicipalityType

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimNYSDACStatus]') AND type in (N'U'))
DROP TABLE [dbo].[dimNYSDACStatus]
GO

CREATE TABLE [dbo].[dimNYSDACStatus](
	StatusID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimNYSDACStatus_NYSDisadvantagedCommunityStatus PRIMARY KEY CLUSTERED(StatusID),
	NYSDACStatus	varchar(20)
)
-------------------------------------------
--	Load the table
INSERT INTO dimNYSDACStatus
	SELECT	DISTINCT NYSDisadvantagedCommunityStatus
	FROM SEStaging

SELECT *
FROM dimNYSDACStatus

-------------------------------------------
-------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimCEJSTStatus]') AND type IN (N'U'))
    DROP TABLE [dbo].[dimCEJSTStatus];
GO

-- Create dimCEJSTStatus table
CREATE TABLE [dbo].[dimCEJSTStatus](
    StatusID INT IDENTITY(1,1) NOT NULL,
    CEJSTStatus varchar(20),
    CONSTRAINT PK_dimCEJSTStatus_CEJSTStatus PRIMARY KEY CLUSTERED(StatusID)
);

------------------------------
INSERT INTO dimCEJSTStatus
	SELECT	DISTINCT ClimateAndEconomicJusticeScreeningToolStatus
	FROM SEStaging
SELECT *
FROM dimCEJSTStatus

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimSector]') AND type in (N'U'))
DROP TABLE [dbo].[dimSector]
GO

CREATE TABLE [dbo].[dimSector](
	SectorID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimSector_Sector PRIMARY KEY CLUSTERED(SectorID),
	Sector	varchar(15)
)
-------------------------------------------
--	Load the table
INSERT INTO dimSector
	SELECT	DISTINCT Sector
	FROM SEStaging

SELECT *
FROM dimSector

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimProgramType]') AND type in (N'U'))
DROP TABLE [dbo].[dimProgramType]
GO

CREATE TABLE [dbo].[dimProgramType](
	ProgramTypeID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimProgramType_ProgramType PRIMARY KEY CLUSTERED(ProgramTypeID),
	ProgramType	varchar(50)
)
-------------------------------------------
--	Load the table
INSERT INTO dimProgramType
	SELECT	DISTINCT ProgramType
	FROM SEStaging

SELECT *
FROM dimProgramType

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimPurchaseType]') AND type in (N'U'))
DROP TABLE [dbo].[dimPurchaseType]
GO

CREATE TABLE [dbo].[dimPurchaseType](
	PurchaseTypeID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimPurchaseType_PurchaseType PRIMARY KEY CLUSTERED(PurchaseTypeID),
	PurchaseType	varchar(50)
)
-------------------------------------------
--	Load the table
INSERT INTO dimPurchaseType
	SELECT	DISTINCT PurchaseType
	FROM SEStaging

SELECT *
FROM dimPurchaseType

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimProjectStatus]') AND type in (N'U'))
DROP TABLE [dbo].[dimProjectStatus]
GO

CREATE TABLE [dbo].[dimProjectStatus](
	ProjectStatusID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimProjectStatus_ProjectStatus PRIMARY KEY CLUSTERED(ProjectStatusID),
	ProjectStatus	varchar(10)
)
-------------------------------------------
--	Load the table
INSERT INTO dimProjectStatus
	SELECT	DISTINCT ProjectStatus
	FROM SEStaging

SELECT *
FROM dimProjectStatus

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimMWBE]') AND type in (N'U'))
DROP TABLE [dbo].[dimMWBE]
GO

CREATE TABLE [dbo].[dimMWBE](
	MWBEID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimMWBE_MWBE PRIMARY KEY CLUSTERED(MWBEID),
	MWBE	varchar(10)
)
-------------------------------------------
--	Load the table
INSERT INTO dimMWBE
	SELECT	DISTINCT MinorityOrWomenOwnedBusinessEnterprise
	FROM SEStaging

SELECT *
FROM dimMWBE

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimRemoteNetMetering]') AND type in (N'U'))
DROP TABLE [dbo].[dimRemoteNetMetering]
GO

CREATE TABLE [dbo].[dimRemoteNetMetering](
	RemoteNetMeteringID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimRemoteNetMetering_RemoteNetMetering PRIMARY KEY CLUSTERED(RemoteNetMeteringID),
	RemoteNetMetering	varchar(10)
)
-------------------------------------------
--	Load the table
INSERT INTO dimRemoteNetMetering
	SELECT	DISTINCT RemoteNetMetering
	FROM SEStaging

SELECT *
FROM dimRemoteNetMetering

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimCommunityDistributedGeneration]') AND type in (N'U'))
DROP TABLE [dbo].[dimCommunityDistributedGeneration]
GO

CREATE TABLE [dbo].[dimCommunityDistributedGeneration](
	CommunityDistributedGenerationID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimCommunityDistributedGeneration_CommunityDistributedGeneration PRIMARY KEY CLUSTERED(CommunityDistributedGenerationID),
	CommunityDistributedGeneration	varchar(10)
)
-------------------------------------------
--	Load the table
INSERT INTO dimCommunityDistributedGeneration
	SELECT	DISTINCT CommunityDistributedGeneration
	FROM SEStaging

SELECT *
FROM dimCommunityDistributedGeneration

-------------------------------------------
-------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dimGreenJobsGreenNewYorkParticipant]') AND type in (N'U'))
DROP TABLE [dbo].[dimGreenJobsGreenNewYorkParticipant]
GO

CREATE TABLE [dbo].[dimGreenJobsGreenNewYorkParticipant](
	GreenJobsGreenNewYorkParticipantID INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_dimGreenJobsGreenNewYorkParticipant_GreenJobsGreenNewYorkParticipant PRIMARY KEY CLUSTERED(GreenJobsGreenNewYorkParticipantID),
	GreenJobsGreenNewYorkParticipant	varchar(10)
)
-------------------------------------------
--	Load the table
INSERT INTO dimGreenJobsGreenNewYorkParticipant
	SELECT	DISTINCT GreenJobsGreenNewYorkParticipant
	FROM SEStaging

SELECT *
FROM dimGreenJobsGreenNewYorkParticipant

-------------------------------------------
-------------------------------------------
-------------------------------------------
-- data quality control
-- city/IncorporatedMunicipality/StreetAddress (deal w/ it later)



-------------------------------------------
-------------------------------------------
-------------------------------------------
-- create solar electric project fact table --

CREATE TABLE [dbo].[factSE](
	SEID int IDENTITY(1,1) NOT NULL,
		CONSTRAINT PK_factSE_SEID PRIMARY KEY CLUSTERED (SEID),
	ReportingPeriodDate DATE,
    ProjectNumber VARCHAR(50),  -- unique identifier
    LegacyProjectNumber VARCHAR(50),
    StreetAddress VARCHAR(255),
    City VARCHAR(30), --
    CountyID int,
		CONSTRAINT FK_dimCounty_factSE FOREIGN KEY (CountyID)
		REFERENCES dimCounty (CountyID),
    State VARCHAR(10),
    ZIPCode VARCHAR(5),
    IncorporatedMunicipality VARCHAR(30), --
    MunicipalityTypeID int,
		CONSTRAINT FK_dimMunicipalityType_factSE FOREIGN KEY (MunicipalityTypeID)
		REFERENCES dimMunicipalityType (MunicipalityTypeID),
    CensusTract VARCHAR(15), -- another identifier
    NYSDACStatusID int,
		CONSTRAINT FK_dimNYSDACStatus_factSE FOREIGN KEY (NYSDACStatusID)
		REFERENCES dimNYSDACStatus (StatusID),
    CEJSTStatusID int,
		CONSTRAINT FK_dimCEJSTStatus_factSE FOREIGN KEY (CEJSTStatusID)
		REFERENCES dimCEJSTStatus (StatusID),
    SectorID int,
		CONSTRAINT FK_dimSector_factSE FOREIGN KEY (SectorID)
		REFERENCES dimSector (SectorID),
    ProgramTypeID int,
		CONSTRAINT FK_dimProgramType_factSE FOREIGN KEY (ProgramTypeID)
		REFERENCES dimProgramType (ProgramTypeID),
        Solicitation VARCHAR(50),
    ElectricUtility VARCHAR(50),
    PurchaseTypeID int,
		CONSTRAINT FK_dimPurchaseType_factSE FOREIGN KEY (PurchaseTypeID)
		REFERENCES dimPurchaseType (PurchaseTypeID),
    DateApplicationReceived DATE,
    DateCompleted DATE,
    ProjectStatusID int,
		CONSTRAINT FK_dimProjectStatus_factSE FOREIGN KEY (ProjectStatusID)
		REFERENCES dimProjectStatus (ProjectStatusID),
    Contractor VARCHAR(100),  
    MWBEID int,
		CONSTRAINT FK_dimMWBE_factSE FOREIGN KEY (MWBEID)
		REFERENCES dimMWBE (MWBEID),
    PrimaryInverterManufacturer VARCHAR(100),
    PrimaryInverterModelNumber VARCHAR(100),
    TotalInverterQuantity INT,
    PrimaryPVModuleManufacturer VARCHAR(100),
    PVModuleModelNumber VARCHAR(100),
    TotalPVModuleQuantity INT,
    ProjectCost MONEY, 
    TotalNYSERDAIncentive MONEY,
    AffordableSolarResidentialAdder MONEY,
    AffordableMultifamilyHousingIncentive MONEY,
    CommunityAdder MONEY,
    InclusiveCommunitySolarAdder MONEY,
    ExpandedSolarForAllAdder MONEY,
    BrownfieldLandfillAdder MONEY,
    CanopyAdder MONEY,
    PrevailingWageAdder MONEY,
    TotalNameplateKWDc DECIMAL(18, 2),
    ExpectedKWhAnnualProduction DECIMAL(18, 2),
    RemoteNetMeteringID int,
		CONSTRAINT FK_dimRemoteNetMetering_factSE FOREIGN KEY (RemoteNetMeteringID)
		REFERENCES dimRemoteNetMetering (RemoteNetMeteringID),
    CommunityDistributedGenerationID int,
		CONSTRAINT FK_dimCommunityDistributedGeneration_factSE FOREIGN KEY (CommunityDistributedGenerationID)
		REFERENCES dimCommunityDistributedGeneration (CommunityDistributedGenerationID),
    GreenJobsGreenNewYorkParticipantID int,
		CONSTRAINT FK_dimGreenJobsGreenNewYorkParticipant_factSE FOREIGN KEY (GreenJobsGreenNewYorkParticipantID)
		REFERENCES dimGreenJobsGreenNewYorkParticipant (GreenJobsGreenNewYorkParticipantID),
    Latitude DECIMAL(9, 6),
    Longitude DECIMAL(9, 6),
    Georeference VARCHAR(100)
)
GO

------------------------------------
INSERT INTO factSE
SELECT ReportingPeriodDate,
    ProjectNumber,
    LegacyProjectNumber,
    StreetAddress,
    City,
    County = 
		CASE
			WHEN County = 'N/A' THEN 1
			WHEN County = 'Albany' THEN 2
			WHEN County = 'Allegany' THEN 3
			WHEN County = 'Bronx' THEN 4
			WHEN County = 'Broome' THEN 5
			WHEN County = 'Cattaraugus' THEN 6
			WHEN County = 'Cayuga' THEN 7
			WHEN County = 'Chautauqua' THEN 8
			WHEN County = 'Chemung' THEN 9
			WHEN County = 'Chenango' THEN 10
			WHEN County = 'Clinton' THEN 11
			WHEN County = 'Columbia' THEN 12
			WHEN County = 'Cortland' THEN 13
			WHEN County = 'Delaware' THEN 14
			WHEN County = 'Dutchess' THEN 15
			WHEN County = 'Erie' THEN 16
			WHEN County = 'Essex' THEN 17
			WHEN County = 'Franklin' THEN 18
			WHEN County = 'Fulton' THEN 19
			WHEN County = 'Genesee' THEN 20
			WHEN County = 'Greene' THEN 21
			WHEN County = 'Hamilton' THEN 22
			WHEN County = 'Herkimer' THEN 23
			WHEN County = 'Jefferson' THEN 24
			WHEN County = 'Kings' THEN 25
			WHEN County = 'Lewis' THEN 26
			WHEN County = 'Livingston' THEN 27
			WHEN County = 'Madison' THEN 28
			WHEN County = 'Monroe' THEN 29
			WHEN County = 'Montgomery' THEN 30
			WHEN County = 'Nassau' THEN 31
			WHEN County = 'New York' THEN 32
			WHEN County = 'Niagara' THEN 33
			WHEN County = 'Oneida' THEN 34
			WHEN County = 'Onondaga' THEN 35
			WHEN County = 'Ontario' THEN 36
			WHEN County = 'Orange' THEN 37
			WHEN County = 'Orleans' THEN 38
			WHEN County = 'Oswego' THEN 39
			WHEN County = 'Otsego' THEN 40
			WHEN County = 'Putnam' THEN 41
			WHEN County = 'Queens' THEN 42
			WHEN County = 'Rensselaer' THEN 43
			WHEN County = 'Richmond' THEN 44
			WHEN County = 'Rockland' THEN 45
			WHEN County = 'Saratoga' THEN 46
			WHEN County = 'Schenectady' THEN 47
			WHEN County = 'Schoharie' THEN 48
			WHEN County = 'Schuyler' THEN 49
			WHEN County = 'Seneca' THEN 50
			WHEN County = 'St Lawrence' THEN 51
			WHEN County = 'Steuben' THEN 52
			WHEN County = 'Suffolk' THEN 53
			WHEN County = 'Sullivan' THEN 54
			WHEN County = 'Tioga' THEN 55
			WHEN County = 'Tompkins' THEN 56
			WHEN County = 'Ulster' THEN 57
			WHEN County = 'Warren' THEN 58
			WHEN County = 'Washington' THEN 59
			WHEN County = 'Wayne' THEN 60
			WHEN County = 'Westchester' THEN 61
			WHEN County = 'Wyoming' THEN 62
			WHEN County = 'Yates' THEN 63
		END,
    State,
    ZIPCode,
    IncorporatedMunicipality,
    MunicipalityType = 
		CASE
			WHEN MunicipalityType = 'Town' THEN 1
			WHEN MunicipalityType = 'N/A' THEN 2
			WHEN MunicipalityType = 'City' THEN 3
		END,
    CensusTract, 
    NYSDisadvantagedCommunityStatus = 
		CASE
			WHEN NYSDisadvantagedCommunityStatus = 'N/A' THEN 1
			WHEN NYSDisadvantagedCommunityStatus = 'Inside a NYS DAC' THEN 2
			WHEN NYSDisadvantagedCommunityStatus = 'Outside a NYS DAC' THEN 3
		END,
    ClimateAndEconomicJusticeScreeningToolStatus =
		CASE
			WHEN ClimateAndEconomicJusticeScreeningToolStatus = 'N/A' THEN 1
			WHEN ClimateAndEconomicJusticeScreeningToolStatus = 'Outside a CEJST DAC' THEN 2
			WHEN ClimateAndEconomicJusticeScreeningToolStatus = 'Inside a CEJST DAC' THEN 3
		END, 
    Sector = 
		CASE
			WHEN Sector = 'Residential' THEN 1
			WHEN Sector = 'Non-Residential' THEN 2
		END,
    ProgramType = 
		CASE
			WHEN ProgramType = 'Residential/Small Commercial' THEN 1
			WHEN ProgramType = 'Commercial/Industrial (Competitive)' THEN 2
			WHEN ProgramType = 'Commercial/Industrial (MW Block)' THEN 3
		END,
    Solicitation,
    ElectricUtility,
    PurchaseType = 
		CASE
			WHEN PurchaseType = 'Lease' THEN 1
			WHEN PurchaseType = 'N/A' THEN 2
			WHEN PurchaseType = 'Purchase' THEN 3
			WHEN PurchaseType = 'Power Purchase Agreement' THEN 4
		END,
    DateApplicationReceived DATE,
    DateCompleted DATE,
    ProjectStatus =
		CASE
			WHEN ProjectStatus = 'Complete' THEN 1
			WHEN ProjectStatus = 'Pipeline' THEN 2
		END,
    Contractor,  
    MinorityOrWomenOwnedBusinessEnterprise =
		CASE
			WHEN MinorityOrWomenOwnedBusinessEnterprise = 'No' THEN 1
			WHEN MinorityOrWomenOwnedBusinessEnterprise = 'Yes' THEN 2
		END,
    PrimaryInverterManufacturer,
    PrimaryInverterModelNumber,
    TotalInverterQuantity,
    PrimaryPVModuleManufacturer,
    PVModuleModelNumber,
    TotalPVModuleQuantity,
    ProjectCost, 
    TotalNYSERDAIncentive,
    AffordableSolarResidentialAdder,
    AffordableMultifamilyHousingIncentive,
    CommunityAdder,
    InclusiveCommunitySolarAdder,
    ExpandedSolarForAllAdder,
    BrownfieldLandfillAdder,
    CanopyAdder,
    PrevailingWageAdder,
    TotalNameplateKWDc,
    ExpectedKWhAnnualProduction,
    RemoteNetMetering = 
		CASE
			WHEN RemoteNetMetering = 'N/A' THEN 1
			WHEN RemoteNetMetering = 'No' THEN 2
			WHEN RemoteNetMetering = 'Yes' THEN 3
		END,
    CommunityDistributedGeneration = 
		CASE
			WHEN CommunityDistributedGeneration = 'No' THEN 1
			WHEN CommunityDistributedGeneration = 'Yes' THEN 2
		END,
    GreenJobsGreenNewYorkParticipant = 
		CASE
			WHEN GreenJobsGreenNewYorkParticipant = 'No' THEN 1
			WHEN GreenJobsGreenNewYorkParticipant = 'Yes' THEN 2
		END,
    Latitude,
    Longitude,
    Georeference
FROM SEStaging
-------------------------------------------


 --SELECT concat('WHEN County = ''',CountyName,''' THEN ',CountyID)
 --FROM dimCounty