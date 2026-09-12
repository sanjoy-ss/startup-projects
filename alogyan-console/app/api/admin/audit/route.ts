import { NextRequest,NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { withConsole } from '@/lib/admin/guard';
async function get(req:NextRequest){
 let q=adminDb.collection('auditLogs').orderBy('createdAt','desc').orderBy('__name__','desc').limit(51);
 const cursor=req.nextUrl.searchParams.get('after');if(cursor){const [date,id]=cursor.split('|');if(!Number.isFinite(Number(date))||!id||!/^[a-zA-Z0-9_-]+$/.test(id))return NextResponse.json({error:'Invalid cursor'},{status:400});q=q.startAfter(new Date(Number(date)),id);}
 const docs=(await q.get()).docs;const last=docs[49];return NextResponse.json({items:docs.slice(0,50).map(d=>({id:d.id,...d.data(),createdAt:d.data().createdAt.toDate().toISOString()})),nextCursor:docs.length>50?`${last.data().createdAt.toMillis()}|${last.id}`:null});
}
export const GET=withConsole('can_manage_admins',get);
