--Cleaning the Nashville Housing Data

select *
from PortfolioProject.dbo.NashvilleHousing

--covert the sales date format from date-time, to date

select SalesDate, CONVERT(Date, [Sale Date])
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET [Sale Date] = CONVERT(Date, [Sale Date])

ALTER TABLE NashvilleHousing
Add SalesDate Date;

update NashvilleHousing
SET SalesDate = CONVERT(Date, [Sale Date])

--populate property address for places where the address is null

select *
from PortfolioProject.dbo.NashvilleHousing
--where [Property Address] is null
order by [Parcel ID]

select aa.[Parcel ID], aa.[Property Address], bb.[Parcel ID], bb.[Property Address], isnull(aa.[Property Address], bb.[Property Address])
from PortfolioProject.dbo.NashvilleHousing aa
join PortfolioProject..NashvilleHousing bb
	on aa.[Parcel ID] = bb.[Parcel ID]
	and aa.F1 <> bb.F1
where aa.[Property Address] is null

Update aa
SET [Property Address] = isnull(aa.[Property Address], bb.[Property Address])
from PortfolioProject.dbo.NashvilleHousing aa
join PortfolioProject..NashvilleHousing bb
	on aa.[Parcel ID] = bb.[Parcel ID]
	and aa.F1 <> bb.F1
where aa.[Property Address] is null

Update aa
SET [Property Address] = isnull(aa.[Property Address], 'No Address')
from PortfolioProject.dbo.NashvilleHousing aa
join PortfolioProject..NashvilleHousing bb
	on aa.[Parcel ID] = bb.[Parcel ID]
	and aa.F1 <> bb.F1
where aa.[Property Address] is null

--Seperarting the property address into address and city
select [Property Address]
from PortfolioProject..NashvilleHousing

select
SUBSTRING([Property Address], 1, CHARINDEX(',', [Property Address]) -1) as Address
, SUBSTRING([Property Address], CHARINDEX(',', [Property Address]) +1, LEN([Property Address])) as Address

from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyAddressNew Nvarchar(255);

update NashvilleHousing
SET PropertyAddressNew = SUBSTRING([Property Address], 1, CHARINDEX(',', [Property Address]) -1)

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

update NashvilleHousing
SET PropertyCity = SUBSTRING([Property Address], CHARINDEX(',', [Property Address]) +1, LEN([Property Address]))

--seperate owners address into address, city and state using parsname

select Address
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(Address, ',', '.'), 3)
,PARSENAME(replace(Address, ',', '.'), 2)
,PARSENAME(replace(Address, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnersAddress Nvarchar(255);

update NashvilleHousing
SET OwnersAddress = PARSENAME(replace(Address, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnersCity Nvarchar(255);

update NashvilleHousing
SET OwnersCity = PARSENAME(replace(Address, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnersState Nvarchar(255);

update NashvilleHousing
SET OwnersState = PARSENAME(replace(Address, ',', '.'), 1)


--changing Y to Yes and N to No
Select Distinct([Sold As Vacant])
From PortfolioProject.dbo.NashvilleHousing

Select ([Sold As Vacant])
, CASE When [Sold As Vacant] = 'Y' THEN 'Yes'
		When [Sold As Vacant] = 'N' THEN 'NO'
		ELSE [Sold As Vacant]
		END
From PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
SET [Sold As Vacant] = CASE When [Sold As Vacant] = 'Y' THEN 'Yes'
		When [Sold As Vacant] = 'N' THEN 'NO'
		ELSE [Sold As Vacant]
		END

--Remove Duplicates

With RowNumCTE As(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY [Parcel ID],
				 [Property Address],
				 [Sale Price],
				 [Sale Date],
				 [Legal Reference]
	ORDER BY F1
						) row_num
from PortfolioProject.dbo.NashvilleHousing
--Order By [Parcel ID]
)

DELETE
FROM RowNumCTE
where row_num > 1
--order by [Property Address]

--Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column [Tax District], [Neighborhood], image
