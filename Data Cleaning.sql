#Importing Data
SET GLOBAL local_infile = true;
LOAD DATA LOCAL INFILE  '~/Desktop/Data Analysis Projects/SQL Data Exploration/Data Cleaning/Nashville Housing Data for Data Cleaning.csv'
INTO TABLE PortfolioProject1.housingdata
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Delete all Data
delete from PortfolioProject1.housingdata;

#Checking Data Import
select * 
from PortfolioProject1.housingdata;


-- Cleaning data in SQL quaries


#Standardising Date Format
select SaleDate, CONVERT (SaleDate, Date) as newSaleDate
from PortfolioProject1.housingdata;

Update PortfolioProject1.housingdata
SET SaleDate = Convert (SaleDate,Date);

Alter Table housingdata
Add SaleDateConverted Date;

Update housingdata
SET SaleDateConverted = Convert (SaleDate, Date);


-- Populate Property Address Data


Select *
From PortfolioProject1.housingdata
#Where PropertyAddress ="";
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(b.PropertyAddress,a.PropertyAddress)
From PortfolioProject1.housingdata as a
JOIN PortfolioProject1.housingdata as b
	on a.ParcelID=b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress ="";

Update PortfolioProject1.housingdata as a
JOIN PortfolioProject1.housingdata as b
		on a.ParcelID=b.ParcelID
    AND a.UniqueID <> b.UniqueID
Set a.PropertyAddress = IFNULL(b.PropertyAddress,a.PropertyAddress)
Where a.PropertyAddress ="";


-- Breaking out Address into Individual Columns (Adderss, City, State)

Select PropertyAddress
From PortfolioProject1.housingdata;

Select
SUBSTRING(PropertyAddress, 1, LOCATE(',' ,PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, LOCATE(',' ,PropertyAddress) + 1, char_length(rtrim(PropertyAddress))) as Address 
From PortfolioProject1.housingdata;

Alter Table housingdata
Add PropertyAddressSplit NVARCHAR(255);

Update housingdata
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, LOCATE(',' ,PropertyAddress)-1);

Alter Table housingdata
Add PropertyCitySplit NVARCHAR(255);

Update housingdata
SET PropertyCitySplit = SUBSTRING(PropertyAddress, LOCATE(',' ,PropertyAddress) + 1, char_length(rtrim(PropertyAddress)));

Select *
From PortfolioProject1.housingdata;

Select owneraddress
From PortfolioProject1.housingdata;

#PARSING STATE CODE
Select
SUBSTRING_INDEX(owneraddress, ',', -1)
From PortfolioProject1.housingdata;

#PARSING CITY NAME
Select
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -2),',',1)
From PortfolioProject1.housingdata;

#PARSING ADDRESS
Select
SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -3),',',1),',',1)
From PortfolioProject1.housingdata;

Alter Table housingdata
Add OwnerSplitAddress NVARCHAR(255);

Update housingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -3),',',1),',',1);

Alter Table housingdata
Add OwnerSplitCity NVARCHAR(255);

Update housingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -2),',',1);

Alter Table housingdata
Add OwnerSplitState NVARCHAR(255);

Update housingdata
SET OwnerSplitState = SUBSTRING_INDEX(owneraddress, ',', -1);

Select *
From PortfolioProject1.housingdata;


-- Change to Yes and No from Y and N in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.housingdata
Group By SoldAsVacant
Order by 2;

Select SoldAsVacant,
CASE WHEN SoldAsVacant = "Y" THEN 'Yes'
			When SoldAsVacant = "N" THEN "No"
            ELSE SoldAsVacant
            END
From PortfolioProject1.housingdata;

Update housingdata
SET SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN 'Yes'
			When SoldAsVacant = "N" THEN "No"
            ELSE SoldAsVacant
            END;

-- Remove Dublicates using CTE table

With RowNumCTE AS(
Select *,
	row_number() over (
    Partition by ParcelID,
						PropertyAddress,
						SalePrice,
                        SaleDate,
                        LegalReference
						Order BY
							UniqueID
                            ) row_num
From PortfolioProject1.housingdata
)
DELETE
From housingdata using housingdata join RowNumCTE on housingdata.UniqueID = RowNumCTE.UniqueID
Where RowNumCTE.row_num >1;

-- Delete Unused columns

Select *
From PortfolioProject1.housingdata;

Alter Table PortfolioProject1.housingdata
Drop column TaxDistrict;

Alter Table PortfolioProject1.housingdata
Drop column SaleDate;