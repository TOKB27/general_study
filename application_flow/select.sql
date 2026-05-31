SELECT 
    resource_number, 
    resource_data, 
    version_id, 
    updated_at
FROM (
    SELECT 
        b.*, 
        -- リソースごとに、バージョンの日付が新しい順（同一日ならIDが大きい順）で連番を振る
        ROW_NUMBER() OVER(
            PARTITION BY b.resource_number 
            ORDER BY v.release_date DESC, v.version_id DESC
        ) as rn
    FROM backuptbl b
    -- バージョンの日付や識別子を判定するためにマスタを結合
    JOIN version_managertbl v ON b.version_id = v.version_id
    WHERE 
        v.project_code = :project_code       -- ステップ1: 選択された識別子 (例: 'DCS_24su2')
        AND v.release_date <= :release_date  -- ステップ1: 選択されたバージョン以前の日付
) t
-- 各resource_numberの中で「一番最新のレコード（rn=1）」だけを絞り込む
WHERE t.rn = 1 
  -- ステップ3: 該当バージョン時点で論理削除されていないもののみを表示
  AND t.is_deleted <> 'deleted';