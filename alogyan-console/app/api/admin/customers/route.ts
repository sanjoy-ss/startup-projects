import { NextRequest,NextResponse } from 'next/server';
import { adminAuth,adminDb } from '@/lib/firebase-admin';
import { withConsole } from '@/lib/admin/guard';
import { FieldPath } from 'firebase-admin/firestore';
async function get(req:NextRequest){
 let query=adminDb.collection('tenants').orderBy(FieldPath.documentId()).limit(26);
 const after=req.nextUrl.searchParams.get('after');if(after && /^[a-zA-Z0-9_-]{1,128}$/.test(after))query=query.startAfter(after);
 const docs=(await query.get()).docs;
 return NextResponse.json({items:docs.slice(0,25).map(d=>({id:d.id,...d.data()})),nextCursor:docs.length>25?docs[24].id:null});
}
async function post(req:NextRequest){
 const body=await req.json();const email=typeof body.email==='string'?body.email.trim().toLowerCase():'';const name=typeof body.name==='string'?body.name.trim():'';
 if(!name || name.length>120 || !email.includes('@'))return NextResponse.json({error:'Institute name and owner email are required'},{status:400});
 const owner=await adminAuth.getUserByEmail(email);
 const userRef=adminDb.collection('users').doc(owner.uid);
 const freshId=adminDb.collection('tenants').doc().id;
 const result=await adminDb.runTransaction(async tx=>{
  const user=await tx.get(userRef);const profile=user.data();
  if(profile && profile.role!=='owner')throw new Error('User already belongs to an institute');
  // Existing customer IDs are preserved; new institutes have independent IDs.
  const tenantId=profile?.instituteId || (profile ? owner.uid : freshId);
  const ref=adminDb.collection('tenants').doc(tenantId);
  if((await tx.get(ref)).exists)throw new Error('Institute already provisioned');
  tx.create(ref,{name,ownerUid:owner.uid,status:'active',subscription:{status:'pending',accessUntil:0},createdAt:new Date()});
  tx.set(userRef,{...profile,uid:owner.uid,instituteId:tenantId,role:'owner',branchIds:['*'],name:profile?.name || owner.displayName || name,email,status:'active',updatedAt:new Date(),createdAt:profile?.createdAt || new Date()});
  return {id:tenantId};
 });return NextResponse.json(result,{status:201});
}
async function patch(req:NextRequest){
 const {id,status,reason}=await req.json();
 if(typeof id!=='string'||!/^[a-zA-Z0-9_-]{1,128}$/.test(id)||!['active','suspended'].includes(status)||typeof reason!=='string'||reason.trim().length<5)return NextResponse.json({error:'Valid customer, status and reason required'},{status:400});
 const ref=adminDb.collection('tenants').doc(id);
 await adminDb.runTransaction(async tx=>{const doc=await tx.get(ref);if(!doc.exists)throw new Error('Customer missing');if(doc.data()?.status!==status)tx.update(ref,{status,statusReason:reason.slice(0,500),updatedAt:new Date()});});
 return NextResponse.json({success:true});
}
export const GET=withConsole('can_view_customers',get);
export const POST=withConsole('can_manage_billing',post);
export const PATCH=withConsole('can_manage_billing',patch);
