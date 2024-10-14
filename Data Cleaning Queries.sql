/*
CLEANING DATA IN SQL QUERIES

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------

-- STANDARDIZED DATE FORMAT


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;

---------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

-- Some values with the same ParcelID has the same PropertyAddress. A ParcelID with a NULL PropertyAddress will be replaced by the PropertiesAddress of the same ParcelID.


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

---------------------------------------------------------------------

-- BREAKING DOWN ADDRESS INTO INDIVIADUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

-- SUBSTRING (Column Name, Start of Trim, End of Trim)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- To trim the Address from OwnerAddress
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), -- To trim the City from OwnerAddress
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- -- To trim the State from OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------

-- CHANGE Y AND N TO 'Yes' AND 'No' in "SoldAsVacant" COLUMN


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant;


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		ELSE SoldAsVacant END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes' 
		ELSE SoldAsVacant END

---------------------------------------------------------------------

-- REMOVING DUPLICATES

-- Assigning row numbers to check for duplicates

WITH RowNumCTE AS (
	SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) AS row_number
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelId;
)

SELECT *
FROM RowNumCTE
WHERE row_number > 1
ORDER BY PropertyAddress;

DELETE
FROM RowNumCTE
WHERE row_number > 1;

---------------------------------------------------------------------

-- DELETING UNUSED COLUMNS

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate