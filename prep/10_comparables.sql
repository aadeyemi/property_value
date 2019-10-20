SELECT
    harris_aggregate.unified_table.*,
    CASE
        WHEN harris_aggregate.unified_table.account = subject_.account THEN 1
        ELSE 0
    END AS is_subject
FROM
    harris_aggregate.unified_table
INNER JOIN (
    SELECT
        -- *
        DISTINCT account, neighborhood_code, neighborhood_group
    FROM
        harris_aggregate.unified_table
    WHERE
        _CONDITION_
        -- site_addr_1 = '12309 ormandy st'
        -- site_addr_1 = '14746 branchwest dr'
) AS subject_
ON
    harris_aggregate.unified_table.neighborhood_code = subject_.neighborhood_code
    AND
    harris_aggregate.unified_table.neighborhood_group = subject_.neighborhood_group
;