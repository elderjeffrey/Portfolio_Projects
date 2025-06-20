select *
from PortfolioProject.dbo.NashvilleHousing$


-- Standardize Date Format --------------------------------------------------------------------------------------------------------------------------------------------------------

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing$

update NashvilleHousing$
set SaleDate = CONVERT(Date, SaleDate)

-- above did not update properly, so utlized below ------------

alter table NashvilleHousing$
add SaleDateConverted Date;

update NashvilleHousing$
set SaleDateConverted = convert(Date, SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing$

-- Populate Property Address ------------------------------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject.dbo.NashvilleHousing$
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing$ a
join PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing$ a
join PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address (Address, City, State) ------------------------------------------------------------------------------------------------------------------------------------

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing$

select 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) -1) as Address, SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing$

alter table NashvilleHousing$
add PropertySplitAddress nvarchar(255);

alter table NashvilleHousing$
add PropertySplitCity nvarchar(255);

update NashvilleHousing$
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) -1)

update NashvilleHousing$
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) +1,LEN(PropertyAddress))



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing$

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing$

alter table NashvilleHousing$
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing$
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing$
add OwnerSplitState nvarchar(255);


update NashvilleHousing$
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update NashvilleHousing$
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update NashvilleHousing$
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)




-- Change Y and N to Yes and No in "Sold as Vacant" -------------------------------------------------------------------------------------------------------------------------------

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing$
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then  'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then  'No'
	 else SoldAsVacant
	 end


-- Remove Duplicates -------------------------------------------------------------------------------------------------------------------------------

select *,
	row_number() over (
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing$
order by ParcelID



with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing$
)
delete
from RowNumCTE
where row_num > 1


-- Delete Unused Columns (not standard) -------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject.dbo.NashvilleHousing$

alter table PortfolioProject.dbo.NashvilleHousing$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate