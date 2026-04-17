-- Populate missing UserAgencies for all distinct PartnerIds in Orders so that Regions/Branches don't show as NULL
INSERT INTO agency_service."UserAgencies" ("Id", "UserId", "AgencyId", "Role", "IsActive", "Status", "JoinedAt", "UserMappingId", "CreatedAt", "IsDeleted", "BranchId", "RegionId")
SELECT 
    uuid_generate_v4(),
    o."PartnerId"::text,
    'bbd3204a-8c65-46ef-a047-5ff57c812f22',
    'Member',
    true,
    'Active',
    NOW(),
    uuid_generate_v4(),
    NOW(),
    false,
    b."Id" as "BranchId",
    b."RegionId" as "RegionId"
FROM (SELECT DISTINCT "PartnerId" FROM ecommere_service."Orders" WHERE "PartnerId" IS NOT NULL) o
CROSS JOIN LATERAL (
    SELECT "Id", "RegionId" FROM agency_service."Branches" ORDER BY random() LIMIT 1
) b
WHERE NOT EXISTS (
    SELECT 1 FROM agency_service."UserAgencies" ua WHERE ua."UserId" = o."PartnerId"::text
);

-- Force an update for existing NULL branches that might have gotten created
UPDATE agency_service."UserAgencies" ua
SET "BranchId" = b."Id", "RegionId" = b."RegionId"
FROM (SELECT "Id", "RegionId" FROM agency_service."Branches" ORDER BY random() LIMIT 1) b
WHERE ua."BranchId" IS NULL;
