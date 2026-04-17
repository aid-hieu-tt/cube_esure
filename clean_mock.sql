-- Xoá dữ liệu Branches và Regions rác
UPDATE agency_service."UserAgencies" SET "BranchId" = NULL, "RegionId" = NULL;
DELETE FROM agency_service."Branches";
DELETE FROM agency_service."Regions";

-- Tạo lại 6 vùng chuẩn Tiếng Việt
INSERT INTO agency_service."Regions" ("Id", "Name", "Code") VALUES
('11111111-1111-1111-1111-111111111111', 'Vùng Bắc', 'VMB'),
('22222222-2222-2222-2222-222222222222', 'Vùng Trung', 'VMT'),
('33333333-3333-3333-3333-333333333333', 'Vùng Nam', 'VMN'),
('44444444-4444-4444-4444-444444444444', 'Vùng Tây Nguyên', 'VTN'),
('55555555-5555-5555-5555-555555555555', 'Vùng Đông Nam Bộ', 'VDNB'),
('66666666-6666-6666-6666-666666666666', 'Vùng Tây Nam Bộ', 'VTNB');

-- Tạo 34 chi nhánh (mỗi vùng 5-6 chi nhánh)
DO $$
DECLARE
    v_regions uuid[] := ARRAY[
        '11111111-1111-1111-1111-111111111111'::uuid, 
        '22222222-2222-2222-2222-222222222222'::uuid, 
        '33333333-3333-3333-3333-333333333333'::uuid, 
        '44444444-4444-4444-4444-444444444444'::uuid, 
        '55555555-5555-5555-5555-555555555555'::uuid, 
        '66666666-6666-6666-6666-666666666666'::uuid
    ];
    rid uuid;
BEGIN
    FOR i IN 1..34 LOOP
        rid := v_regions[1 + floor(random() * 6)::int];
        INSERT INTO agency_service."Branches" ("Name", "Code", "RegionId")
        VALUES ('Chi nhánh ' || lpad(i::text, 2, '0'), 'CN' || lpad(i::text, 2, '0'), rid);
    END LOOP;
END $$;

-- Cập nhật lại UserAgencies an toàn
DO $$
DECLARE
    u RECORD;
    b RECORD;
BEGIN
    FOR u IN SELECT "Id" FROM agency_service."UserAgencies" LOOP
        SELECT "Id", "RegionId" INTO b FROM agency_service."Branches" ORDER BY random() LIMIT 1;
        UPDATE agency_service."UserAgencies"
        SET "BranchId" = b."Id",
            "RegionId" = b."RegionId"
        WHERE "Id" = u."Id";
    END LOOP;
END $$;
