--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject3..NashvilleHousing

----1/ Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate) AS DateConverted
FROM PortfolioProject3..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

--> does not work, let's try adding a new column

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate) AS DateConverted
FROM NashvilleHousing

----2/ Populate Property Address data
--Looking at the data we can see NULL values in PropertyAddress column
--Need to populate property addresses using ParcelID and UniqueID

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS AddressPopulated
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

----3/ Breaking out Property Address into 2 individual columns (Address, City) USING SUBSTRING & CHARINDEX

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, CHARINDEX(',', PropertyAddress) +10) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, CHARINDEX(',', PropertyAddress) +10)

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

----4/ Breaking out Owner Address into 3 individual columns (Address, City, State) using PARSENAME & REPLACE

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing

----5/ Change 'Y' and 'N' into 'Yes' and 'No' in "SoldAsVacant' Field using CASE statement

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Number
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN	SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN	SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

----6/ Remove Duplicates

WITH CTERow_Num AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) AS RowNum
FROM NashvilleHousing
)

SELECT *
FROM CTERow_Num
WHERE RowNum > 1
ORDER BY PropertyAddress


WITH CTERow_Num AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID) AS RowNum
FROM NashvilleHousing
)

DELETE
FROM CTERow_Num
WHERE RowNum > 1

----6/ Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict