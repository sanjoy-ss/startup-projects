import {initializeApp,cert,applicationDefault} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
const email=process.argv.find(arg=>arg.startsWith('--email='))?.slice(8);
if(!email)throw new Error('Usage: node --env-file=.env.local scripts/bootstrap-staff.mjs --email=you@example.com [--apply]');
const account=process.env.FIREBASE_SERVICE_ACCOUNT_B64?JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64,'base64').toString()):null;
initializeApp({credential:account?cert(account):applicationDefault()});
const auth=getAuth();
let user=await auth.getUserByEmail(email);
if(!user.emailVerified){
 if(process.argv.includes('--verify-email')&&process.argv.includes('--apply')){
  user=await auth.updateUser(user.uid,{emailVerified:true});
  console.log(JSON.stringify({emailVerified:true,uid:user.uid}));
 }else if(!process.argv.includes('--allow-unverified')){
  throw new Error('Staff email unverified. Pass --verify-email or --allow-unverified.');
 }
}
const ref=getFirestore().collection('platformStaff').doc(user.uid);
if((await ref.get()).exists){console.log('Staff record already exists; no changes.');process.exit(0);}
console.log(JSON.stringify({action:'Create first console super admin',uid:user.uid,email:user.email,dryRun:!process.argv.includes('--apply')}));
if(process.argv.includes('--apply'))await ref.create({email:user.email,username:user.displayName||user.email,role:'super_admin',is_active:true,created_at:new Date().toISOString()});

