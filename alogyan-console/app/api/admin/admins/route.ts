import { NextRequest,NextResponse } from 'next/server';
import { adminAuth,adminDb } from '@/lib/firebase-admin';
import { withConsole,requireConsole } from '@/lib/admin/guard';
import { roles,permissionsFor } from '@/lib/admin/auth';
async function get(){const docs=await adminDb.collection('platformStaff').limit(100).get();return NextResponse.json({admins:docs.docs.map(d=>({_id:d.id,...d.data()}))});}
async function post(req:NextRequest){
 const {email,username,role}=await req.json();
 if(typeof email!=='string'||typeof username!=='string'||!username.trim()||!roles.includes(role))return NextResponse.json({error:'Valid email, name and role required'},{status:400});
 const identity=await adminAuth.getUserByEmail(email.trim().toLowerCase());
 await adminDb.collection('platformStaff').doc(identity.uid).create({email:identity.email,username:username.slice(0,100),role,permissions:permissionsFor(role),is_active:true,created_at:new Date().toISOString()});
 return NextResponse.json({success:true},{status:201});
}
async function remove(req:NextRequest){
 const session=await requireConsole(req,'can_manage_admins');const {id}=await req.json();
 if(typeof id!=='string'||!/^[a-zA-Z0-9_-]{1,128}$/.test(id)||id===session.uid)return NextResponse.json({error:'Cannot revoke your own access'},{status:400});
 const ref=adminDb.collection('platformStaff').doc(id);const target=(await ref.get()).data();
 if(target?.role==='super_admin')return NextResponse.json({error:'Super admin removal requires an operator migration'},{status:409});
 await ref.update({is_active:false});await adminAuth.revokeRefreshTokens(id);return NextResponse.json({success:true});
}
export const GET=withConsole('can_manage_admins',get);export const POST=withConsole('can_manage_admins',post);export const DELETE=withConsole('can_manage_admins',remove);
