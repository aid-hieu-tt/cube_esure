SELECT 'UserAgencies' as type, COUNT(*) as cnt FROM agency_service."UserAgencies";
SELECT 'Branches' as type, COUNT(*) as cnt FROM agency_service."Branches";
SELECT 'Regions' as type, COUNT(*) as cnt FROM agency_service."Regions";

SELECT ua."UserId", ua."BranchId", ua."RegionId" 
FROM agency_service."UserAgencies" ua 
WHERE ua."BranchId" IS NOT NULL LIMIT 5;

SELECT * FROM agency_service."Regions" LIMIT 5;
SELECT * FROM agency_service."Branches" LIMIT 5;
