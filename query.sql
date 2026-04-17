-- ===== UPDATE packageName: thay tên provider cũ bằng tên mới =====

-- 1. PVI → MIC (trong packageName)
UPDATE ecommere_service."OrderItems"
SET "ProductSnapshot" = jsonb_set(
  "ProductSnapshot",
  '{attributes,package,name}',
  to_jsonb(REPLACE(("ProductSnapshot"->'attributes'->'package')->>'name', 'PVI', 'MIC'))
)
WHERE ("ProductSnapshot"->'attributes'->'package')->>'name' LIKE '%PVI%';

-- 2. BảoViệt → Hanwha Life
UPDATE ecommere_service."OrderItems"
SET "ProductSnapshot" = jsonb_set(
  "ProductSnapshot",
  '{attributes,package,name}',
  to_jsonb(REPLACE(("ProductSnapshot"->'attributes'->'package')->>'name', 'BảoViệt', 'Hanwha Life'))
)
WHERE ("ProductSnapshot"->'attributes'->'package')->>'name' LIKE '%BảoViệt%';

-- 3. DBV → PJICO
UPDATE ecommere_service."OrderItems"
SET "ProductSnapshot" = jsonb_set(
  "ProductSnapshot",
  '{attributes,package,name}',
  to_jsonb(REPLACE(("ProductSnapshot"->'attributes'->'package')->>'name', 'DBV', 'PJICO'))
)
WHERE ("ProductSnapshot"->'attributes'->'package')->>'name' LIKE '%DBV%';

-- 4. BaoLong → Bao Long (đã đúng format, giữ nguyên)
-- Không cần sửa vì "BaoLong" trong packageName giữ nguyên theo tên nhà BH

-- 5. Verify kết quả
SELECT DISTINCT 
  ("ProductSnapshot"->'attributes'->'package')->>'name' AS package_name,
  ("ProductSnapshot"->'attributes'->'package')->>'providerName' AS provider_name,
  COUNT(*) AS total
FROM ecommere_service."OrderItems"
GROUP BY 1, 2
ORDER BY 2, 1;
