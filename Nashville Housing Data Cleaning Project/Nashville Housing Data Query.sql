-- --------------------------------------------------------------------------------------------------------------------------------

--                                         DATA CLEANING PROJECT - NASHVILLE HOUSING DATA

-- --------------------------------------------------------------------------------------------------------------------------------


-- Looking at our Data

select *
from Portfolio_Projects..Nashville_Housing_Data

----------------------------------------------------------------------------------------------------------------------------------

-- Standartize Date Format

select *  
from Portfolio_Projects..Nashville_Housing_Data

alter table Portfolio_Projects..Nashville_Housing_Data
alter column SaleDate DATE


----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property address data


select *
from Portfolio_Projects..Nashville_Housing_Data
--where PropertyAddress is NULL
order by ParcelID


select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) as populated_address
from Portfolio_Projects..Nashville_Housing_Data a
join Portfolio_Projects..Nashville_Housing_Data b
    on a.ParcelID =b.ParcelID
    and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is NULL   


UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Projects..Nashville_Housing_Data a
join Portfolio_Projects..Nashville_Housing_Data b
    on a.ParcelID = b.ParcelID
    and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out columns into individual columns



-- Breaking PROPERTY ADDRESS
 
 select PropertyAddress
 from Portfolio_Projects..Nashville_Housing_Data

 select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1) as street_address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(Propertyaddress)) as city
 from Portfolio_Projects..Nashville_Housing_Data

alter table Portfolio_Projects..Nashville_Housing_Data
add property_street_address VARCHAR(255)

UPDATE Portfolio_Projects..Nashville_Housing_Data
SET property_street_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table Portfolio_Projects..Nashville_Housing_Data
add property_City VARCHAR(255)

UPDATE Portfolio_Projects..Nashville_Housing_Data
SET property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(Propertyaddress))



-- Breaking OWNER ADDRESS

 select OwnerAddress
 from Portfolio_Projects..Nashville_Housing_Data

 select
 PARSENAME(replace(OwnerAddress,',','.'), 3) as Owner_street_address,
 PARSENAME(replace(OwnerAddress,',','.'), 2) as Owner_city,
 PARSENAME(replace(OwnerAddress,',','.'), 1) as Owner_state
 from Portfolio_Projects..Nashville_Housing_Data

 alter table Portfolio_Projects..Nashville_Housing_Data
 add Owner_street_address varchar(255), Owner_city varchar(255), Owner_state varchar(255)

 
UPDATE Portfolio_Projects..Nashville_Housing_Data
SET Owner_street_address = PARSENAME(replace(OwnerAddress,',','.'), 3),
    Owner_city = PARSENAME(replace(OwnerAddress,',','.'), 2),
	Owner_state = PARSENAME(replace(OwnerAddress,',','.'), 1)


----------------------------------------------------------------------------------------------------------------------------------------------

-- Updating/Unifying Y/N into Yes/No


 select distinct(SoldAsVacant), count(SoldAsVacant)
 from Portfolio_Projects..Nashville_Housing_Data
 group by SoldAsVacant
 order by 1

 select SoldAsVacant,
 (case 
  when SoldAsVacant = 'Y' then 'Yes'
  when SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end) as SoldAsVacant_Updated
from Portfolio_Projects..Nashville_Housing_Data
 

 update Portfolio_Projects..Nashville_Housing_Data
 set SoldAsVacant = 
 (case 
  when SoldAsVacant = 'Y' then 'Yes'
  when SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end)

  -----------------------------------------------------------------------------------------------------------------------------------------

  -- Removing Duplicates


  Select *
  From Portfolio_Projects..Nashville_Housing_Data

  With rownum_CTE as
  (
  Select *,
         ROW_NUMBER() Over(
		 Partition by ParcelID,
		              PropertyAddress,
					  SaleDate,
					  LegalReference,
					  SalePrice
					  Order by 
					    ParcelID
						) as rownum
  From Portfolio_Projects..Nashville_Housing_Data
  )
  select *
  from rownum_CTE
  where  rownum > 1

  -- NOTE : NOT a STANDARD PRACTICE TO DELETE DATA in a DATABASE

  -------------------------------------------------------------------------------------------------------------------------------------------

  -- Deleting unused columns

  select *
  from Portfolio_Projects..Nashville_Housing_Data


  alter table Portfolio_Projects..Nashville_Housing_Data
  drop column PropertyAddress, OwnerAddress, TaxDistrict

  -- NOTE : NOT a STANDARD PRACTICE TO DELETE DATA in a DATABASE

  -- ---------------------------------------------------------------------------------------------------------------------------------------
  
  -- Creating VIEW for further usage

  create view Nashville_Housing_Data_Cleaned as
  select *
  from Portfolio_Projects..Nashville_Housing_Data
