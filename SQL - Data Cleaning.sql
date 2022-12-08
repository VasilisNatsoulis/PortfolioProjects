/*
Cleaning Data in SQL Queries
*/



  SELECT * FROM PortfolioProject.dbo.NashvilleHousing



  --------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

  SELECT SaleDate,CONVERT(date,SaleDate) as SalesDate
  FROM PortfolioProject.dbo.NashvilleHousing

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET SaleDate = CONVERT(date,SaleDate) 


  -- If it doesn't Update properly

  ALTER TABLE NashvilleHousing
  ADD SaleDate2 date;

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET SaleDate2 = CONVERT(date,SaleDate) 



  --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing
  WHERE PropertyAddress is NULL
  ORDER BY ParcelID


  SELECT a.[UniqueID ],	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
  FROM PortfolioProject.dbo.NashvilleHousing AS a
  JOIN PortfolioProject.dbo.NashvilleHousing AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL

  
  UPDATE a
  SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing AS a
  JOIN PortfolioProject.dbo.NashvilleHousing AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL



	--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City) method #1

	 SELECT PropertyAddress
	 FROM PortfolioProject.dbo.NashvilleHousing

	 SELECT PropertyAddress,
	 SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress )-1) as address,
	 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress )+1, LEN(PropertyAddress)) as address2

	 FROM PortfolioProject.dbo.NashvilleHousing


  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress Nvarchar(255);

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress )-1)

  ALTER TABLE NashvilleHousing
  ADD PropertySplitCity Nvarchar(255);

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress )+1, LEN(PropertyAddress))


  -- Breaking out Address into Individual Columns (Address, City, State) method #2

  SELECT * FROM PortfolioProject.dbo.NashvilleHousing

	    SELECT OwnerAddress
		FROM PortfolioProject.dbo.NashvilleHousing

		  SELECT OwnerAddress, 
		  PARSENAME(REPLACE(OwnerAddress,',','.'),3) as test,
		  PARSENAME(REPLACE(OwnerAddress,',','.'),2) as test1,
		  PARSENAME(REPLACE(OwnerAddress,',','.'),1) as test3

		FROM PortfolioProject.dbo.NashvilleHousing


  ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress Nvarchar(255);

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity Nvarchar(255);

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState Nvarchar(255);

  UPDATE PortfolioProject.dbo.NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

  SELECT * FROM PortfolioProject.dbo.NashvilleHousing




	  --------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

	  SELECT DISTINCT SoldAsVacant,count(SoldasVacant)
	  FROM PortfolioProject.dbo.NashvilleHousing
	  GROUP BY SoldAsVacant
	  ORDER BY 2

	  SELECT SoldAsVacant,
		     CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END 
	  FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END 



			 -----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


			 WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



