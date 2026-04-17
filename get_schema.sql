SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'agency_service' 
  AND table_name = 'UserAgencies' 
  AND is_nullable = 'NO';
