CREATE TABLE ad.iat_ad_history(
  ID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  ACTION_ nvarchar(50) NOT NULL,
  LOGIN_ nvarchar(200) NOT NULL,
  GROUP_ nvarchar(200) NOT NULL,
  DATE_TO_GROUP datetime NOT NULL,
  CREATED_AT datetime NULL DEFAULT (getdate())
)