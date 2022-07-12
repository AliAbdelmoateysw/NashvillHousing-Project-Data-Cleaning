/* 
Cleaning Data in SQL Queries 
*/
select * 
from PortfolioProject.dbo.NashvillHousing

--===================================================================
-- Standardize Date Format
select SaleDate ,CONVERT(DATE, SaleDate)
from PortfolioProject..NashvillHousing

Update NashvillHousing
set SaleDate= CONVERT(date , SaleDate)

Alter table NashvillHousing
add SaleDateConverted Date;

update NashvillHousing
set SaleDateConverted = Convert(date,SaleDate)

select SaleDateConverted
from PortfolioProject..NashvillHousing

-----------------------------------------------------------------------
--Populate Property Address data

select PropertyAddress
from PortfolioProject.dbo.NashvillHousing
where PropertyAddress is null
order  by ParcelID


select a.ParcelID ,a.PropertyAddress , b.ParcelID , b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject .dbo.NashvillHousing a
join PortfolioProject..NashvillHousing b
on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject .dbo.NashvillHousing a
join PortfolioProject..NashvillHousing b
on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------
-- Break out Address into individual  Columns (Address , City , State)

select PropertyAddress
from PortfolioProject..NashvillHousing


select
substring(PropertyAddress,1,CHARINDEX(',' ,PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address 
from PortfolioProject..NashvillHousing

alter table NashvillHousing
add PropertySplitAddress nvarchar(255);

update NashvillHousing
set   PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',' ,PropertyAddress) -1);


alter table NashvillHousing
add PropertySplitCity nvarchar(255);

update NashvillHousing
set   PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1 ,len(PropertyAddress));

---=======================--

-- Break out OwnerAddress into individual  Columns (Address , City , State)


select OwnerAddress
from PortfolioProject..NashvillHousing

select OwnerAddress, 
PARSENAME( Replace(OwnerAddress,',','.') ,3),
PARSENAME( Replace(OwnerAddress,',','.') ,2),
PARSENAME( Replace(OwnerAddress,',','.') ,1)
from PortfolioProject..NashvillHousing

alter table NashvillHousing
add OwnerSplitAddress nvarchar(255);

update NashvillHousing
set   OwnerSplitAddress = PARSENAME( Replace(OwnerAddress,',','.') ,3);



alter table NashvillHousing
add OwnerSplitCity nvarchar(255);

update NashvillHousing
set   OwnerSplitCity = PARSENAME( Replace(OwnerAddress,',','.') ,2);


alter table NashvillHousing
add OwnerSplitState nvarchar(255);

update NashvillHousing
set   OwnerSplitState = PARSENAME( Replace(OwnerAddress,',','.') ,1);

select * 
from PortfolioProject.dbo.NashvillHousing;

--======================================================
--Change Y and N to Yes or No in "Sold as Vacant" field

select distinct(SoldAsVacant),COUNT(SoldAsVacant) as Count_Of_Sold_As_Vacant
from PortfolioProject.dbo.NashvillHousing
group by SoldAsVacant
order by 2 

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvillHousing

update NashvillHousing
set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
--============================================================

--Remove duplicates

--using CTE Common Table Expression

with RowNumCTE as(
select * ,
ROW_NUMBER () over (PARTITION by ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								Order by 
								UniqueID
								) row_num

from PortfolioProject.dbo.NashvillHousing
)	
select *
from RowNumCTE
where row_num >1 
order by PropertyAddress

/*
DELETE
from RowNumCTE
where row_num >1 
*/

--=================================================

--Delete unused Columns "Special for Views"

select * 
from PortfolioProject..NashvillHousing

alter table PortfolioProject..NashvillHousing
drop column OwnerAddress, TaxDistrict ,PropertyAddress


alter table NashvillHousing
drop column SaleDate