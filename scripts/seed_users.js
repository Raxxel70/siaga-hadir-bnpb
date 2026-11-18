const fs = require('fs');
const path = require('path');
const https = require('https');

const configPath = path.join(
  process.env.USERPROFILE,
  '.config',
  'configstore',
  'firebase-tools.json'
);

if (!fs.existsSync(configPath)) {
  console.error('Konfigurasi token Firebase tidak ditemukan.');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const token = config.tokens?.access_token;
const projectId = 'siaga-hadir-bnpb';

if (!token) {
  console.error('Access token Firebase tidak ditemukan.');
  process.exit(1);
}

const sampleUsers = [
  {
    docId: 'usr_trc_001',
    fields: {
      id: { stringValue: 'usr_trc_001' },
      nip: { stringValue: '199208142018011003' },
      name: { stringValue: 'Rizki Pratama (TRC Bencana)' },
      email: { stringValue: '199208142018011003@bnpb.go.id' },
      role: { stringValue: 'field_trc' },
      registeredDeviceId: { stringValue: '' }, // Akan diikat otomatis pada login pertama
      department: { stringValue: 'Direktorat Kesiapsiagaan BNPB' },
      homeLatitude: { doubleValue: -6.2088 },
      homeLongitude: { doubleValue: 106.8456 }
    }
  },
  {
    docId: 'usr_wfo_001',
    fields: {
      id: { stringValue: 'usr_wfo_001' },
      nip: { stringValue: '198705202010121002' },
      name: { stringValue: 'Budi Santoso (Pusdalops)' },
      email: { stringValue: '198705202010121002@bnpb.go.id' },
      role: { stringValue: 'staff' },
      registeredDeviceId: { stringValue: '' },
      department: { stringValue: 'Pusdalops PB Graha BNPB' },
      homeLatitude: { doubleValue: -6.2575 },
      homeLongitude: { doubleValue: 106.8702 }
    }
  }
];

async function seedUser(user) {
  return new Promise((resolve, reject) => {
    const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${user.docId}`;
    const data = JSON.stringify({ fields: user.fields });

    const req = https.request(
      url,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data)
        }
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            console.log(`Berhasil membuat data personel: ${user.fields.name.stringValue}`);
            resolve(JSON.parse(body));
          } else {
            console.error(`Gagal membuat data: ${res.statusCode} - ${body}`);
            resolve(null);
          }
        });
      }
    );

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function run() {
  console.log('Memulai seeding data personel BNPB ke Cloud Firestore...');
  for (const user of sampleUsers) {
    await seedUser(user);
  }
  console.log('Selesai inisialisasi basis data personel.');
}

run();
