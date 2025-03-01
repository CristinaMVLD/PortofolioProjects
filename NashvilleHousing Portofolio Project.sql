

/*
Cleaning Data in SQL Quesries
*/


SELECT *
FROM PortofolioProject..NashvilleHousing


-- Standardize Date Format


SELECT SaleDate, Convert(Date, SaleDate)
FROM PortofolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)


-- Populate Property Address Data


SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing
Where PropertyAddress is null


SELECT *
FROM PortofolioProject..NashvilleHousing
Where PropertyAddress is null


SELECT *
FROM PortofolioProject..NashvilleHousing
Order By ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, B.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
Join PortofolioProject..NashvilleHousing b
 On a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null

 Update a
 SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
Join PortofolioProject..NashvilleHousing b
 On a.ParcelID = b.ParcelID
 And a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing


Select
Substring(PropertyAddress, 1, Charindex(',' , PropertyAddress) - 1) As Address
, Substring(PropertyAddress, Charindex(',' , PropertyAddress) + 1, Len(PropertyAddress)) As Address
FROM PortofolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',' , PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',' , PropertyAddress) + 1, Len(PropertyAddress))


SELECT *
FROM PortofolioProject..NashvilleHousing


-- Another method

SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing


Select
Parsename(Replace(PropertyAddress,',','.'), 3)
, Parsename(Replace(PropertyAddress,',','.'), 2)
, Parsename(Replace(PropertyAddress,',','.'), 1)
FROM PortofolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress2 nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress2 = Parsename(Replace(PropertyAddress,',','.'), 3)


Alter Table NashvilleHousing
Add PropertySplitCity2 nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity2 = Parsename(Replace(PropertyAddress,',','.'), 2)


Alter Table NashvilleHousing
Add PropertySplitState nvarchar(255);

Update NashvilleHousing
SET PropertySplitState = Parsename(Replace(PropertyAddress,',','.'), 1)


SELECT *
FROM PortofolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct ( SoldAsVacant), Count(SoldAsVacant)
FROM PortofolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
   	Else SoldAsVacant
	END
FROM PortofolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
   	Else SoldAsVacant
	END


-- Remove Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() over(Partition by ParcelID, PropertyAddress, SalePrice,
				 SaleDate, LegalReference
				 Order by UniqueID ) row_num


From PortofolioProject..NashvilleHousing

--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1

-- Delete Unused Columns


Select *
From PortofolioProject..NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate