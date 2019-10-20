CREATE SCHEMA IF NOT EXISTS harris_aggregate AUTHORIZATION keymaker;

-- (1)
-- structural_elem1
-- BUILDING ADJUSTMENT CODES AND DESCRIPTIONS FROM structural_elem1
DROP TABLE IF EXISTS harris_aggregate.structural_elem1;
CREATE TABLE harris_aggregate.structural_elem1 AS
SELECT 
    account,
    building_number,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'cdu' THEN adj_cd ELSE 0 END) AS cdu,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'grd' THEN adj_cd ELSE 0 END) AS grd,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'hac' THEN adj_cd ELSE 0 END) AS heating_cooling,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'fnd' THEN adj_cd ELSE 0 END) AS foundation,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'xwr' THEN adj_cd ELSE 0 END) AS exterior_wall,
    SUM (CASE WHEN TRIM(LOWER(structure_type)) = 'cad' THEN adj_cd ELSE 0 END) AS cost_and_design,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'cdu' THEN category_description ELSE NULL END) AS cdu_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'grd' THEN category_description ELSE NULL END) AS grd_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'hac' THEN category_description ELSE NULL END) AS heating_cooling_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'fnd' THEN category_description ELSE NULL END) AS foundation_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'xwr' THEN category_description ELSE NULL END) AS exterior_wall_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'pcr' THEN category_description ELSE NULL END) AS physical_condition_desc,
    MAX (CASE WHEN TRIM(LOWER(structure_type)) = 'cad' THEN category_description ELSE NULL END) AS cost_and_design_desc
FROM 
    harris_raw.structural_elem1
GROUP BY account, building_number
ORDER BY account, building_number;


-- (2)
-- fixtures
-- BUILDING ROOM COUNT AND HEIGHT FROM fixtures
DROP TABLE IF EXISTS harris_aggregate.fixtures;
CREATE TABLE harris_aggregate.fixtures AS
SELECT 
    account,
    building_number,
    SUM (CASE WHEN TRIM(LOWER(fixture_type)) = 'rmt' THEN units ELSE 0 END) AS total_rooms,
    SUM (CASE WHEN TRIM(LOWER(fixture_type)) = 'rmb' THEN units ELSE 0 END) AS num_bedrooms,
    SUM (CASE WHEN TRIM(LOWER(fixture_type)) = 'rmf' THEN units ELSE 0 END) AS num_full_baths,
    SUM (CASE WHEN TRIM(LOWER(fixture_type)) = 'rmh' THEN units ELSE 0 END) AS num_half_baths,
    SUM (CASE WHEN TRIM(LOWER(fixture_type)) = 'sty' THEN units ELSE 0 END) AS story_height_index
FROM harris_raw.fixtures
GROUP BY account, building_number
ORDER BY account, building_number;


-- (3)
-- building_res
-- BUILDING SIZE, NEIGHBORHOOD FACTOR, AGE, USE CODES FROM building_res 
DROP TABLE IF EXISTS harris_aggregate.building_res;
CREATE TABLE harris_aggregate.building_res AS
SELECT
    harris_raw.building_res.account,
    harris_raw.building_res.building_number,
    harris_raw.building_res.depreciation_value,
    harris_raw.building_res.impr_sq_ft,
    harris_raw.building_res.imprv_type,
    harris_raw.building_res.building_style_code,
    harris_raw.building_res.use_code,
    harris_raw.building_res.class_structure,
    harris_raw.building_res.class_struc_description,
    harris_raw.building_res.nbhd_factor,
    harris_raw.building_res.size_index,
    harris_raw.building_res.percent_complete,
    harris_raw.building_res.lump_sum_adj,
    harris_raw.building_res.date_erected,
    harris_raw.building_res.yr_remodel,
    COUNT (harris_raw.building_res.building_number) OVER (
        PARTITION BY 
            harris_raw.building_res.account
    ) AS num_buildings,
    COUNT(*) OVER (
        PARTITION BY 
            harris_raw.building_res.account,
            harris_raw.building_res.imprv_type,
            harris_raw.building_res.building_style_code,
            harris_raw.building_res.use_code
    ) AS distinct_uses
FROM harris_raw.building_res
ORDER BY account, building_number;


-- (4)
-- real_acct
-- ACCOUNTING
DROP TABLE IF EXISTS harris_aggregate.real_acct;
CREATE TABLE harris_aggregate.real_acct AS
SELECT 
    -- ADDRESS
    harris_raw.real_acct.account,
    TRIM(LOWER(harris_raw.real_acct.site_addr_1)) AS site_addr_1,
    TRIM(LOWER(harris_raw.real_acct.site_addr_2)) AS site_addr_2,
    TRIM(LOWER(harris_raw.real_acct.site_addr_3)) AS site_addr_3,
    harris_raw.real_acct.neighborhood_code,
    harris_raw.real_acct.neighborhood_group,
    harris_raw.real_acct.market_area_1,
    TRIM(harris_raw.real_acct.market_area_1_dscr) AS market_area_1_dscr,
    TRIM(harris_raw.real_acct.legal_dscr_1) AS legal_dscr_1,
    harris_raw.real_acct.total_building_area,
    harris_raw.real_acct.total_land_area,
    TRIM(UPPER(harris_raw.real_acct.cap_account)) AS cap_account,
    harris_raw.real_acct.land_value,
    harris_raw.real_acct.improvement_value,
    harris_raw.real_acct.extra_features_value,
    harris_raw.real_acct.ag_value,
    harris_raw.real_acct.assessed_value,
    harris_raw.real_acct.total_appraised_value
FROM harris_raw.real_acct
ORDER BY account;


-- (5)
-- extra_features
-- EXTRA FEATURES
DROP TABLE IF EXISTS harris_aggregate.extra_features;
CREATE TABLE harris_aggregate.extra_features AS
SELECT 
    account,
    string_agg(DISTINCT t.feature, ', ') AS extra_feature 
FROM (
    SELECT 
        *,
        CASE 
            WHEN TRIM(LOWER(category)) = 'gr' THEN LOWER(dscr)
            WHEN TRIM(LOWER(category)) = 'pl' THEN LOWER(dscr)
            WHEN TRIM(LOWER(category)) = 'fd' THEN LOWER(dscr)
            WHEN TRIM(LOWER(category)) = 'cr' THEN LOWER(dscr)
            WHEN TRIM(LOWER(category)) = 'ob' THEN LOWER(dscr)
            WHEN TRIM(LOWER(category)) = 'so' THEN LOWER(dscr)
            ELSE 'other' 
        END AS feature
    FROM harris_raw.extra_features
) AS t
GROUP BY account
ORDER BY account;


-- (6)
-- combined_buildings
-- COMBINED BUILDINGS
DROP TABLE IF EXISTS harris_aggregate.combined_buildings;
CREATE TABLE harris_aggregate.combined_buildings AS
-- FINAL TABLE
SELECT * FROM (
    SELECT 
        -- BUILDING SIZE, NEIGHBORHOOD FACTOR, AGE, USE CODES FROM building_res 
        -- building_res
        harris_aggregate.building_res.*,
        -- fixtures
        harris_aggregate.fixtures.total_rooms,
        harris_aggregate.fixtures.num_bedrooms,
        harris_aggregate.fixtures.num_full_baths,
        harris_aggregate.fixtures.num_half_baths,
        harris_aggregate.fixtures.story_height_index,
        -- structural_elem1
        harris_aggregate.structural_elem1.cdu,
        harris_aggregate.structural_elem1.grd,
        harris_aggregate.structural_elem1.heating_cooling,
        harris_aggregate.structural_elem1.foundation,
        harris_aggregate.structural_elem1.exterior_wall,
        harris_aggregate.structural_elem1.cost_and_design,
        harris_aggregate.structural_elem1.cdu_desc,
        harris_aggregate.structural_elem1.grd_desc,
        harris_aggregate.structural_elem1.heating_cooling_desc,
        harris_aggregate.structural_elem1.foundation_desc,
        harris_aggregate.structural_elem1.exterior_wall_desc,
        harris_aggregate.structural_elem1.physical_condition_desc,
        harris_aggregate.structural_elem1.cost_and_design_desc
    FROM harris_aggregate.building_res
    INNER JOIN harris_aggregate.fixtures
    ON harris_aggregate.fixtures.account = harris_aggregate.building_res.account
    AND
    harris_aggregate.fixtures.building_number = harris_aggregate.building_res.building_number
    INNER JOIN harris_aggregate.structural_elem1
    ON harris_aggregate.structural_elem1.account = harris_aggregate.building_res.account
    AND
    harris_aggregate.structural_elem1.building_number = harris_aggregate.building_res.building_number
    WHERE 
        -- BUILDING USE
        imprv_type IN ('1001','1002','1003','1004','1006','1007')
        AND
        building_style_code IN ('101','102','103','104','107')
        AND
        use_code IN ('A1','B1','B2','B3','B4')
    ORDER BY
        account, building_number

) AS t
WHERE
    -- NUMBER OF BUILDINGS < 5
    num_buildings < 5
    AND
    -- USE CODES MUST BE THE SAME FOR ALL BUILDINGS
    distinct_uses = num_buildings
ORDER BY
    account, building_number
;


-- (7)
-- unified_table
-- UNIFIED TABLE
DROP TABLE IF EXISTS harris_aggregate.unified_table;
CREATE TABLE harris_aggregate.unified_table AS
SELECT 
    -- ADDRESS
    harris_aggregate.combined_buildings.account,
    harris_aggregate.combined_buildings.building_number,
    TRIM(LOWER(harris_raw.real_acct.site_addr_1)) AS site_addr_1,
    TRIM(LOWER(harris_raw.real_acct.site_addr_2)) AS site_addr_2,
    TRIM(LOWER(harris_raw.real_acct.site_addr_3)) AS site_addr_3,
    harris_raw.real_acct.neighborhood_code,
    harris_raw.real_acct.neighborhood_group,
    harris_raw.real_acct.market_area_1,
    TRIM(harris_raw.real_acct.market_area_1_dscr) AS market_area_1_dscr,
    TRIM(harris_raw.real_acct.legal_dscr_1) AS legal_dscr_1,
    harris_raw.real_acct.total_building_area,
    harris_raw.real_acct.total_land_area,
    -- NEIGHBORHOOD CODE
    TRIM(LOWER(harris_raw.real_neighborhood_code.description)) AS neighborhood_dscr,
    -- COMBINED BUILDINGS
    harris_aggregate.combined_buildings.depreciation_value,
    harris_aggregate.combined_buildings.impr_sq_ft,
    harris_aggregate.combined_buildings.imprv_type,
    harris_aggregate.combined_buildings.building_style_code,
    harris_aggregate.combined_buildings.use_code,
    harris_aggregate.combined_buildings.class_structure,
    harris_aggregate.combined_buildings.class_struc_description,
    harris_aggregate.combined_buildings.nbhd_factor,
    harris_aggregate.combined_buildings.size_index,
    harris_aggregate.combined_buildings.percent_complete,
    harris_aggregate.combined_buildings.lump_sum_adj,
    harris_aggregate.combined_buildings.date_erected,
    harris_aggregate.combined_buildings.yr_remodel,
    harris_aggregate.combined_buildings.num_buildings,
    harris_aggregate.combined_buildings.distinct_uses,
    harris_aggregate.combined_buildings.total_rooms,
    harris_aggregate.combined_buildings.num_bedrooms,
    harris_aggregate.combined_buildings.num_full_baths,
    harris_aggregate.combined_buildings.num_half_baths,
    harris_aggregate.combined_buildings.story_height_index,
    harris_aggregate.combined_buildings.cdu,
    harris_aggregate.combined_buildings.grd,
    harris_aggregate.combined_buildings.heating_cooling,
    harris_aggregate.combined_buildings.foundation,
    harris_aggregate.combined_buildings.exterior_wall,
    harris_aggregate.combined_buildings.cost_and_design,
    harris_aggregate.combined_buildings.cdu_desc,
    harris_aggregate.combined_buildings.grd_desc,
    harris_aggregate.combined_buildings.heating_cooling_desc,
    harris_aggregate.combined_buildings.foundation_desc,
    harris_aggregate.combined_buildings.exterior_wall_desc,
    harris_aggregate.combined_buildings.physical_condition_desc,
    harris_aggregate.combined_buildings.cost_and_design_desc,
    -- EXTRA FEATURES
    extra_features.extra_feature,
    -- ACCOUNTING
    TRIM(UPPER(harris_raw.real_acct.cap_account)) AS cap_account,
    harris_raw.real_acct.land_value,
    harris_raw.real_acct.improvement_value,
    harris_raw.real_acct.extra_features_value,
    harris_raw.real_acct.ag_value,
    harris_raw.real_acct.assessed_value,
    harris_raw.real_acct.total_appraised_value
FROM harris_raw.real_acct
INNER JOIN harris_aggregate.combined_buildings
ON harris_aggregate.combined_buildings.account = harris_raw.real_acct.account
LEFT JOIN harris_aggregate.extra_features
ON harris_aggregate.extra_features.account = harris_raw.real_acct.account
LEFT JOIN harris_raw.real_neighborhood_code
ON harris_raw.real_neighborhood_code.neighborhood_cd = harris_raw.real_acct.neighborhood_code
AND harris_raw.real_neighborhood_code.group_cd = harris_raw.real_acct.neighborhood_group
-- CONDITIONS
WHERE TRIM(LOWER(harris_raw.real_acct.cap_account)) != 'pending'
-- ORDERING
ORDER BY account, building_number;


-- CLEAN UP
DROP TABLE IF EXISTS harris_aggregate.structural_elem1;
DROP TABLE IF EXISTS harris_aggregate.fixtures;
DROP TABLE IF EXISTS harris_aggregate.building_res;
DROP TABLE IF EXISTS harris_aggregate.real_acct;
DROP TABLE IF EXISTS harris_aggregate.extra_features;
DROP TABLE IF EXISTS harris_aggregate.combined_buildings;

CREATE INDEX IF NOT EXISTS index_account_bldg_num ON harris_aggregate.unified_table (account,building_number);
CREATE INDEX IF NOT EXISTS index_neighborhood ON harris_aggregate.unified_table (neighborhood_code,neighborhood_group);

ALTER TABLE harris_aggregate.unified_table ALTER COLUMN building_number TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN num_buildings TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN num_bedrooms TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN num_full_baths TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN num_half_baths TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN total_rooms TYPE INT;
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN site_addr_1 TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN site_addr_2 TYPE VARCHAR(32);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN site_addr_3 TYPE VARCHAR(8);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN market_area_1 TYPE VARCHAR(32);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN market_area_1_dscr TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN legal_dscr_1 TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN neighborhood_dscr TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN imprv_type TYPE VARCHAR(8);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN building_style_code TYPE VARCHAR(8);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN use_code TYPE VARCHAR(8);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN class_structure TYPE VARCHAR(8);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN class_struc_description TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN impr_sq_ft TYPE INT USING (TRIM(impr_sq_ft)::INTEGER);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN nbhd_factor TYPE DOUBLE PRECISION USING (TRIM(nbhd_factor)::DOUBLE PRECISION);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN size_index TYPE DOUBLE PRECISION USING (TRIM(size_index)::DOUBLE PRECISION);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN percent_complete TYPE DOUBLE PRECISION USING (TRIM(percent_complete)::DOUBLE PRECISION);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN lump_sum_adj TYPE DOUBLE PRECISION USING (TRIM(lump_sum_adj)::DOUBLE PRECISION);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN depreciation_value TYPE DOUBLE PRECISION USING (TRIM(depreciation_value)::DOUBLE PRECISION);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN date_erected TYPE VARCHAR(32);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN yr_remodel TYPE VARCHAR(32);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN cdu_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN grd_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN heating_cooling_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN foundation_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN exterior_wall_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN physical_condition_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN cost_and_design_desc TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN extra_feature TYPE VARCHAR(255);
ALTER TABLE harris_aggregate.unified_table ALTER COLUMN cap_account TYPE VARCHAR(4);
