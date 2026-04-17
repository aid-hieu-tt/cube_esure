const { Client } = require('pg');
const crypto = require('crypto');

async function run() {
  const client = new Client({
    host: 'localhost',
    port: 5434,
    database: 'aid_in4u_dev',
    user: 'common_user',
    password: 'CommonUser@2024'
  });

  await client.connect();
  console.log('Connected to DB');

  try {
    const brRes = await client.query('SELECT "Id", "Name", "RegionId" FROM agency_service."Branches"');
    const branches = brRes.rows;
    console.log(`Loaded ${branches.length} branches.`);

    const newAgencies = [];
    for (const br of branches) {
        const id = crypto.randomUUID();
        newAgencies.push({
            id,
            branchId: br.Id,
            regionId: br.RegionId,
            name: `Đại lý ${br.Name.replace('Chi nhánh ', '')}`
        });
    }

    // Insert into Agencies
    for (const ag of newAgencies) {
        await client.query(`
            INSERT INTO agency_service."Agencies" ("Id", "Name", "Code", "IsActive", "IsDeleted", "CreatedAt", "UpdatedAt") 
            VALUES ('${ag.id}', '${ag.name}', 'AG_${ag.id.substring(0,6)}', true, false, NOW(), NOW())
        `);
    }
    console.log('Inserted 34 Agencies');

    // Insert into UserAgencies
    for (const ag of newAgencies) {
        await client.query(`
            INSERT INTO agency_service."UserAgencies" 
            ("Id", "UserId", "Role", "IsActive", "Status", "BranchId", "RegionId", "IsDeleted", "CreatedAt", "JoinedAt", "UserMappingId", "AgencyId") 
            VALUES ('${crypto.randomUUID()}', '${ag.id}', 'Member', true, 'Active', '${ag.branchId}', '${ag.regionId}', false, NOW(), NOW(), '${crypto.randomUUID()}', '${ag.id}')
        `);
    }
    console.log('Inserted 34 UserAgencies');

    const ordersRes = await client.query('SELECT "Id" FROM ecommere_service."Orders"');
    const orderIds = ordersRes.rows.map(r => r.Id);

    console.log(`Distributing ${orderIds.length} orders across 34 branches...`);
    
    await client.query(`
        UPDATE ecommere_service."Orders" o
        SET "PartnerId" = a."Id"
        FROM (
            SELECT "Id", row_number() over (order by random()) as rn 
            FROM agency_service."Agencies" 
            WHERE "Name" LIKE 'Đại lý %'
        ) a 
        WHERE (ascii(substring(o."Id"::text from 1 for 1)) + length(o."Id"::text)) % 34 + 1 = a.rn;
    `);
    
    console.log(`Done distributing orders.`);

  } catch (err) {
    console.error(err);
  } finally {
    await client.end();
  }
}

run();
