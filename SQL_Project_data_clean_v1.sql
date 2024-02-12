-- Data cleaning program for SQL table
-- Data is the NashvilleHousing data
-- Project from FreeCodeCamp https://youtu.be/PSNXoAs2FtQ?si=vhHq1Z8iU0PQzlbn&t=12841

-- Data table: NashvilleHousing


SELECT * FROM NashvilleHousing

-- Standardize Date formats
SELECT SaleDate, CONVERT(Date,SaleDate)
    FROM NashvilleHousing

UPDATE NashvilleHousing
    SET SaleDate=CONVERT(Date,SaleDate)

--SELECT SaleDate FROM NashvilleHousing

-- Populate Property address data where NULL
SELECT * FROM NashvilleHousing
    --Where PropertyAddress is NULL
    ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
 FROM NashvilleHousing AS A
    JOIN NashvilleHousing AS B
    ON A.ParcelID=B.ParcelID
        AND A.UniqueID<>B.UniqueID
    WHERE A.PropertyAddress IS NULL

UPDATE A SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
    FROM NashvilleHousing AS A
    JOIN NashvilleHousing AS B
        ON A.ParcelID=B.ParcelID
            AND A.UniqueID<>B.UniqueID
    WHERE A.PropertyAddress IS NULL


-- Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) /*address*/AS Address,
    SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))/*city*/ AS City
    FROM NashvilleHousing

ALTER TABLE NashvilleHousing
    ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
    SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
    ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
    SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




SELECT * FROM NashvilleHousing

-- parse out address pieces. PARSENAME only works with '.' so need to replace ','. Also parese from right to left
SELECT PARSENAME(replace(OwnerAddress,',','.'),3),
        PARSENAME(replace(OwnerAddress,',','.'),2),
        PARSENAME(replace(OwnerAddress,',','.'),1)
    FROM NashvilleHousing

-- Add some new columns for parsed out pieces
ALTER TABLE NashvilleHousing
    ADD OwnerSplitAddress NVARCHAR(255),
        OwnerSplitCity NVARCHAR(255),
        OwnerSplitState NVARCHAR(255);

-- Update table with new columns definitions
UPDATE NashvilleHousing
    SET OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3),
        OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2),
        OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1);

SELECT * FROM NashvilleHousing



-- Change any Y and N to Yes and No in 'SoldAsVacant'
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
    FROM NashvilleHousing
    GROUP BY SoldAsVacant
    ORDER BY 2;

-- Use a case statement to try the changes
SELECT SoldAsVacant,
    CASE when SoldAsVacant='Y' THEN 'Yes'
         when SoldAsVacant='N' THEN 'No'
        ELSE SoldAsVacant
    END
    FROM NashvilleHousing

-- Update the column
UPDATE NashvilleHousing
    SET SoldAsVacant=CASE when SoldAsVacant='Y' THEN 'Yes'
         when SoldAsVacant='N' THEN 'No'
        ELSE SoldAsVacant
    END;


-- Remove duplicates. Use a CTE to generate the duplicate rows then delete them
WITH RowNumCTE AS(
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                        ORDER BY UniqueID
    ) AS row_num
    FROM NashvilleHousing
)
SELECT * FROM RowNumCTE
    WHERE row_num>1
DELETE From RowNumCTE
    WHERE row_num>1



-- Delete unused column (don't do this for raw data)
SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
    DROP COLUMN OwnerAddress,PropertyAddress