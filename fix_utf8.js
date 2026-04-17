const { Client } = require('pg');

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
    await client.query('UPDATE agency_service."UserAgencies" SET "BranchId" = NULL, "RegionId" = NULL;');
    await client.query('DELETE FROM agency_service."Branches";');
    await client.query('DELETE FROM agency_service."Regions";');
    console.log('Cleaned up tables');

    // Insert Regions
    const regions = [
      { id: '11111111-1111-1111-1111-111111111111', name: 'Vùng 1', code: 'V01' },
      { id: '22222222-2222-2222-2222-222222222222', name: 'Vùng 2', code: 'V02' },
      { id: '33333333-3333-3333-3333-333333333333', name: 'Vùng 3', code: 'V03' },
      { id: '44444444-4444-4444-4444-444444444444', name: 'Vùng 4', code: 'V04' },
      { id: '55555555-5555-5555-5555-555555555555', name: 'Vùng 5', code: 'V05' },
      { id: '66666666-6666-6666-6666-666666666666', name: 'Vùng 6', code: 'V06' }
    ];

    for (const r of regions) {
      await client.query(`INSERT INTO agency_service."Regions" ("Id", "Name", "Code") VALUES ('${r.id}', '${r.name}', '${r.code}')`);
    }
    console.log('Inserted Regions');

    const branchNames = [
      "Hà Nội", "Hải Phòng", "Quảng Ninh", "Bắc Ninh", "Vĩnh Phúc", 
      "Thái Nguyên", "Hải Dương", "Hưng Yên", "Thái Bình", "Nam Định",
      "Thanh Hóa", "Nghệ An", "Hà Tĩnh", "Quảng Bình", "Quảng Trị", 
      "Thừa Thiên Huế", "Đà Nẵng", "Quảng Nam", "Quảng Ngãi", "Bình Định", 
      "Phú Yên", "Khánh Hòa", "Gia Lai", "Đắk Lắk", "Lâm Đồng", 
      "TP.HCM", "Đồng Nai", "Bình Dương", "Bà Rịa - Vũng Tàu", "Long An", 
      "Cần Thơ", "Tiền Giang", "Kiên Giang", "Cà Mau"
    ];

    // Insert 34 Branches
    for (let i = 0; i < branchNames.length; i++) {
        const rid = regions[Math.floor(Math.random() * regions.length)].id;
        const iStr = (i + 1).toString().padStart(2, '0');
        await client.query(`INSERT INTO agency_service."Branches" ("Name", "Code", "RegionId") VALUES ('Chi nhánh ${branchNames[i]}', 'CN${iStr}', '${rid}')`);
    }
    console.log('Inserted Branches');

    // Assign to UserAgencies
    const uasRes = await client.query('SELECT "Id" FROM agency_service."UserAgencies"');
    const brRes = await client.query('SELECT "Id", "RegionId" FROM agency_service."Branches"');
    
    let uasCount = 0;
    for (const row of uasRes.rows) {
        const br = brRes.rows[Math.floor(Math.random() * brRes.rows.length)];
        await client.query(`UPDATE agency_service."UserAgencies" SET "BranchId" = '${br.Id}', "RegionId" = '${br.RegionId}' WHERE "Id" = '${row.Id}'`);
        uasCount++;
    }
    console.log(`Updated ${uasCount} UserAgencies`);
  } catch (err) {
    console.error(err);
  } finally {
    await client.end();
  }
}

run();
