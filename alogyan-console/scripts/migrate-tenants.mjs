import {initializeApp,cert,applicationDefault} from 'firebase-admin/app';
import {getFirestore,FieldPath} from 'firebase-admin/firestore';
const account=process.env.FIREBASE_SERVICE_ACCOUNT_B64?JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64,'base64').toString()):null;
initializeApp({credential:account?cert(account):applicationDefault()});
const db=getFirestore();const apply=process.argv.includes('--apply');
// Operators choose an explicit migration access deadline. Never silently grant perpetual access.
const deadline=process.argv.find(arg=>arg.startsWith('--access-until='))?.slice(15);
const accessUntil=deadline?Date.parse(deadline):0;
if(apply&&(!accessUntil||accessUntil<=Date.now()))throw new Error('Apply requires --access-until=<future ISO date>.');
let cursor;let count=0;
for(;;){
 let query=db.collection('users').where('role','==','owner').orderBy(FieldPath.documentId()).limit(100);
 if(cursor)query=query.startAfter(cursor);
 const page=await query.get();if(page.empty)break;
 for(const doc of page.docs){
  const profile=doc.data();const tenantId=profile.instituteId||doc.id;const ref=db.collection('tenants').doc(tenantId);
  if((await ref.get()).exists)continue;
  console.log(JSON.stringify({tenantId,ownerUid:doc.id,action:'provision',dryRun:!apply}));
  if(apply)await db.runTransaction(async tx=>{
   const [tenant,current]=await Promise.all([tx.get(ref),tx.get(doc.ref)]);
   if(tenant.exists)return;const data=current.data();if(!data||data.role!=='owner')throw new Error('Owner changed during migration');
   tx.create(ref,{name:data.instituteName||data.name||'Institute',ownerUid:doc.id,status:'active',subscription:{status:'trial',accessUntil},createdAt:new Date(),migration:'console-v1'});
   if(!data.instituteId)tx.update(doc.ref,{instituteId:tenantId});
  });count++;
 }
 cursor=page.docs.at(-1).id;
}
console.log(JSON.stringify({provisioned:count,dryRun:!apply}));
