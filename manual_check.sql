SELECT
    *
FROM
    member_accumulation
WHERE
    ( member_id,
      rx_total,
      med_total,
      met_deductable ) NOT IN (
        SELECT
            b.member_id,
            b.rx,
            b.med,
            nvl((
                SELECT
                    'Y'
                FROM
                    dual
                WHERE
                    (b.rx + b.med) >(
                        SELECT
                            deductible_threshold
                        FROM
                            members
                        WHERE
                            member_id = b.member_id
                    )
            ), 'N') AS met
FROM
            (
                SELECT DISTINCT
                    a.member_id,
                    nvl((
                        SELECT
                            SUM(claim_amount)
                FROM
                    stage_2_archive
                        WHERE
                            member_id = a.member_id
                            AND claim_type = 'RX'
            ), 0) AS rx,
                    nvl((
                        SELECT
                    SUM(claim_amount)
                        FROM
                            stage_2_archive
                WHERE
                            member_id = a.member_id
                            AND claim_type = 'MED'
                    ), 0) AS med
                FROM
                    stage_2_archive a
            ) b
    );