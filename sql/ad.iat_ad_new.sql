CREATE TABLE ad.iat_ad_new(
  ID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  LOGIN_ nvarchar(200) NOT NULL,
  GROUP_ nvarchar(200) NOT NULL,
  CREATED_AT datetime NULL DEFAULT (getdate())
)