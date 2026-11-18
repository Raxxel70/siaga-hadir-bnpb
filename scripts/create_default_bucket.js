const fs = require('fs');
const path = require('path');
const https = require('https');

const configPath = path.join(
  process.env.USERPROFILE,
  '.config',
  'configstore',
  'firebase-tools.json'
);

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const token = config.tokens?.access_token;
const projectId = 'siaga-hadir-bnpb';

const url = `https://firebase.googleapis.com/v1beta1/projects/${projectId}/defaultBucket`;

const req = https.request(
  url,
  {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': 0
    }
  },
  (res) => {
    let body = '';
    res.on('data', (d) => (body += d));
    res.on('end', () => {
      console.log('Status:', res.statusCode);
      console.log('Response:', body);
    });
  }
);

req.on('error', (e) => console.error(e));
req.end();
