import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const account = process.env.FIREBASE_SERVICE_ACCOUNT_B64
  ? JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString())
  : null;
initializeApp({ credential: account ? cert(account) : applicationDefault() });

const auth = getAuth();
const db = getFirestore();

const targetEmail = process.argv.find(a => a.startsWith('--email='))?.slice(8) || 'admin@alogyan.com';

try {
  const authUser = await auth.getUserByEmail(targetEmail);
  console.log('AUTH USER:', { uid: authUser.uid, email: authUser.email, displayName: authUser.displayName });
  
  const userDoc = await db.collection('users').doc(authUser.uid).get();
  console.log('USER DOC (by UID):', userDoc.exists ? userDoc.data() : 'NOT_FOUND');

  const userByEmailSnap = await db.collection('users').where('email', '==', targetEmail).get();
  console.log(`USERS FOUND BY EMAIL FIELD (${userByEmailSnap.size}):`, userByEmailSnap.docs.map(d => ({ id: d.id, ...d.data() })));

  const instituteId = userDoc.data()?.instituteId || authUser.uid;
  console.log('INSTITUTE/TENANT ID CANDIDATE:', instituteId);

  const tenantDoc = await db.collection('tenants').doc(instituteId).get();
  console.log('TENANT DOC:', tenantDoc.exists ? tenantDoc.data() : 'NOT_FOUND');

  const instDoc = await db.collection('institutes').doc(instituteId).get();
  console.log('INSTITUTE DOC:', instDoc.exists ? instDoc.data() : 'NOT_FOUND');

  const teacherDoc = await db.collection('teachers').doc(instituteId).get();
  console.log('TEACHER DOC:', teacherDoc.exists ? teacherDoc.data() : 'NOT_FOUND');

  const [branches, batches, students] = await Promise.all([
    db.collection('branches').where('instituteId', '==', instituteId).get(),
    db.collection('batches').where('instituteId', '==', instituteId).get(),
    db.collection('students').where('instituteId', '==', instituteId).get(),
  ]);

  console.log('ASSOCIATED RECORDS COUNT (with instituteId = ' + instituteId + '):', {
    branches: branches.size,
    batches: batches.size,
    students: students.size,
  });

  if (batches.size === 0 && students.size === 0) {
    const [batchesByTeacher, studentsByTeacher] = await Promise.all([
      db.collection('batches').where('teacherId', '==', instituteId).get(),
      db.collection('students').where('teacherId', '==', instituteId).get(),
    ]);
    console.log('ASSOCIATED RECORDS COUNT (with teacherId = ' + instituteId + '):', {
      batches: batchesByTeacher.size,
      students: studentsByTeacher.size,
    });
  }

} catch (err) {
  console.error('ERROR:', err);
}
