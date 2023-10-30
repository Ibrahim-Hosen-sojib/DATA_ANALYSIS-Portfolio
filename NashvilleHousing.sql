-- Cleaning Data in sql queries

SELECT * 
FROM NashvilleHousing

-- Standerdize date format

 SELECT saleDateConverted, CONVERT(Date, SaleDate) ConvSaledate 
 FROM NashvilleHousing


 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD saleDateConverted date;


UPDATE NashvilleHousing
SET saleDateConverted = CONVERT(date, SaleDate)


-- Populate property address data

SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) as UPDATED__A
FROM NashvilleHousing a
 JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns
SELECT *
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address_1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address_2
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress 
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS UPDATED_1,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS UPDATED_2,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS UPDATED_3
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM NashvilleHousing;


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
     CASE
	    WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
     END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	                  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		              WHEN SoldAsVacant = 'N' THEN 'No'
		              ELSE SoldAsVacant
                   END






-- REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	    PARTITION BY 
		ParcelID,
		PropertyAddress,
	    SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
		UniqueID
	)row_num
FROM NashvilleHousing
--ORDER BY ParcelID;
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID 

--DELETE  
--FROM RowNumCTE
--WHERE row_num > 1
 

 -- Delete Unused Columns



SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
