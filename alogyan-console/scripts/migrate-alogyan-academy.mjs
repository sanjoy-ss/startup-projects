import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const account = process.env.FIREBASE_SERVICE_ACCOUNT_B64
  ? JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString())
  : null;
initializeApp({ credential: account ? cert(account) : applicationDefault() });

const auth = getAuth();
const db = getFirestore();
const apply = process.argv.includes('--apply');

const targetEmail = 'admin@alogyan.com';
const authUser = await auth.getUserByEmail(targetEmail);
const uid = authUser.uid;
console.log(`Target Auth UID: ${uid} (${targetEmail})`);

const userRef = db.collection('users').doc(uid);
const userDoc = await userRef.get();
const userData = userDoc.exists ? userDoc.data() : {};

const instRef = db.collection('institutes').doc(uid);
const instDoc = await instRef.get();
const instData = instDoc.exists ? instDoc.data() : {};
const instituteName = instData.name || userData.instituteName || 'Alogyan Academy';

const tenantId = uid;
const tenantRef = db.collection('tenants').doc(tenantId);
const tenantDoc = await tenantRef.get();

console.log('--- PLANNED CHANGES ---');
console.log(`1. Tenant doc [/tenants/${tenantId}]:`, {
  name: instituteName,
  ownerUid: uid,
  status: 'active',
  subscription: {
    status: 'active',
    planId: 'enterprise_internal',
    accessUntil: 4102444800000, // Jan 1 2100
  }
});

console.log(`2. User profile [/users/${uid}]:`, {
  role: 'owner',
  status: 'active',
  instituteId: tenantId,
  branchIds: ['*'],
  name: userData.displayName || userData.name || authUser.displayName || 'Debajyoti Karmakar',
});

// Scan batches, students, fees, attendance
const [batchesSnap, studentsSnap, branchesSnap, feesSnap] = await Promise.all([
  db.collection('batches').where('teacherId', '==', tenantId).get(),
  db.collection('students').where('teacherId', '==', tenantId).get(),
  db.collection('branches').where('instituteId', '==', tenantId).get(),
  db.collection('fees').where('teacherId', '==', tenantId).get(),
]);

console.log('3. Data integrity check:');
console.log(`   - Branches found: ${branchesSnap.size}`);
console.log(`   - Batches found: ${batchesSnap.size}`);
console.log(`   - Students found: ${studentsSnap.size}`);
console.log(`   - Fee records found: ${feesSnap.size}`);

if (!apply) {
  console.log('\nDRY RUN ONLY. Pass --apply to execute.');
  process.exit(0);
}

// Execute migration safely without deleting anything
const batch = db.batch();

// Set tenant
batch.set(tenantRef, {
  name: instituteName,
  ownerUid: uid,
  status: 'active',
  subscription: {
    status: 'active',
    planId: 'enterprise_internal',
    accessUntil: 4102444800000,
  },
  createdAt: tenantDoc.exists && tenantDoc.data()?.createdAt ? tenantDoc.data()?.createdAt : new Date(),
  updatedAt: new Date(),
  migratedFrom: 'legacy_admin_alogyan',
}, { merge: true });

// Set user
batch.set(userRef, {
  ...userData,
  uid,
  email: targetEmail,
  name: userData.displayName || userData.name || authUser.displayName || 'Debajyoti Karmakar',
  role: 'owner',
  status: 'active',
  instituteId: tenantId,
  branchIds: ['*'],
  updatedAt: new Date(),
}, { merge: true });

await batch.commit();

// Backfill instituteId on batches if missing
let batchBackfillCount = 0;
for (const doc of batchesSnap.docs) {
  if (!doc.data().instituteId) {
    await doc.ref.update({ instituteId: tenantId });
    batchBackfillCount++;
  }
}

// Backfill instituteId on students if missing
let studentBackfillCount = 0;
for (const doc of studentsSnap.docs) {
  if (!doc.data().instituteId) {
    await doc.ref.update({ instituteId: tenantId });
    studentBackfillCount++;
  }
}

// Backfill instituteId on fees if missing
let feeBackfillCount = 0;
for (const doc of feesSnap.docs) {
  if (!doc.data().instituteId) {
    await doc.ref.update({ instituteId: tenantId });
    feeBackfillCount++;
  }
}

console.log('\n✅ MIGRATION COMPLETED SUCCESSFULLY:');
console.log(`   - Tenant ${tenantId} activated with unlimited internal subscription.`);
console.log(`   - User ${uid} set to active owner with full branch access [*].`);
console.log(`   - Batches backfilled: ${batchBackfillCount}`);
console.log(`   - Students backfilled: ${studentBackfillCount}`);
console.log(`   - Fees backfilled: ${feeBackfillCount}`);
console.log('   - ZERO records deleted. All existing IDs preserved.');
