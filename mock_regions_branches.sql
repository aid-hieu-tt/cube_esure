CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS agency_service."Regions" (
    "Id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Name" varchar NOT NULL,
    "Code" varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS agency_service."Branches" (
    "Id" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    "Name" varchar NOT NULL,
    "Code" varchar NOT NULL,
    "RegionId" uuid REFERENCES agency_service."Regions"("Id")
);

-- Dọn dẹp nếu có chạy lại
TRUNCATE TABLE agency_service."Branches" CASCADE;
TRUNCATE TABLE agency_service."Regions" CASCADE;

-- Insert 6 regions
INSERT INTO agency_service."Regions" ("Name", "Code") VALUES
('Vùng Bắc', 'VMB'),
('Vùng Trung', 'VMT'),
('Vùng Nam', 'VMN'),
('Vùng Tây Nguyên', 'VTN'),
('Vùng Đông Nam Bộ', 'VDNB'),
('Vùng Tây Nam Bộ', 'VTNB');

-- Insert 34 branches
DO $$
DECLARE
    r RECORD;
    v_regions uuid[];
    rid uuid;
BEGIN
    SELECT array_agg("Id") INTO v_regions FROM agency_service."Regions";
    FOR i IN 1..34 LOOP
        -- index from 1 to 6
        rid := v_regions[1 + floor(random() * 6)::int];
        INSERT INTO agency_service."Branches" ("Name", "Code", "RegionId")
        VALUES ('Chi nhánh ' || i, 'CN' || lpad(i::text, 2, '0'), rid);
    END LOOP;
END $$;

-- Alter UserAgencies
ALTER TABLE agency_service."UserAgencies" ADD COLUMN IF NOT EXISTS "BranchId" uuid REFERENCES agency_service."Branches"("Id");
ALTER TABLE agency_service."UserAgencies" ADD COLUMN IF NOT EXISTS "RegionId" uuid REFERENCES agency_service."Regions"("Id");

-- Assign random Branch/Region to UserAgencies
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
