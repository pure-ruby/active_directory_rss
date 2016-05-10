CREATE TABLE ad.iat_ad_info(
  ID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  TYPE_ nvarchar(200) NOT NULL,
  VAR1 nvarchar(200) NULL,
  VAR2 nvarchar(200) NULL,
  VAR3 nvarchar(200) NULL,
  CREATED_AT datetime NULL DEFAULT (getdate())
)