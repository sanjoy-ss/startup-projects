import { NextRequest,NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { withConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Teacher from '@/models/Teacher';
async function get(){const docs=await adminDb.collection('listingDrafts').where('status','in',['pending','publishing']).limit(50).get();return NextResponse.json({items:docs.docs.map(d=>({id:d.id,...d.data()}))});}
async function post(req:NextRequest){
 const {id,revision}=await req.json();if(typeof id!=='string'||!/^[a-zA-Z0-9_-]{1,128}$/.test(id)||!Number.isInteger(revision))return NextResponse.json({error:'Invalid profile version'},{status:400});
 const ref=adminDb.collection('listingDrafts').doc(id);
 const fields=await adminDb.runTransaction(async tx=>{const doc=await tx.get(ref);const data=doc.data();if(!data||data.revision!==revision||!['pending','publishing'].includes(data.status))throw new Error('Profile changed; refresh before approving');if(data.status!=='publishing')tx.update(ref,{status:'publishing'});return data.publicFields;});
 await dbConnect();
 // Deterministic ID makes retries safe if Mongo succeeds before Firestore confirmation.
 await Teacher.findOneAndUpdate({id:`cms_${id}`},{$set:{name:fields.name,institution:fields.name,subject:fields.subject,'location.city':fields.city,'seo.slug':fields.slug,'seo.meta_description':fields.description},$setOnInsert:{id:`cms_${id}`,rating:0,review_count:0}},{upsert:true,runValidators:true});
 await adminDb.runTransaction(async tx=>{const doc=await tx.get(ref);if(doc.data()?.revision!==revision)throw new Error('Profile changed');tx.update(ref,{status:'published',publishedAt:new Date()});tx.set(adminDb.collection('listingLinks').doc(id),{tenantId:id,discoveryId:`cms_${id}`,slug:fields.slug,revision});});
 return NextResponse.json({success:true});
}
export const GET=withConsole('can_manage_teachers',get);export const POST=withConsole('can_manage_teachers',post);
