import { NextRequest,NextResponse } from 'next/server';
import { adminDb } from '@/lib/firebase-admin';
import { withConsole } from '@/lib/admin/guard';
async function get(){const docs=await adminDb.collection('plans').orderBy('createdAt','desc').limit(50).get();return NextResponse.json({items:docs.docs.map(d=>({id:d.id,...d.data()}))});}
async function post(req:NextRequest){
 const {id,name,razorpayPlanId,totalCount}=await req.json();
 if(typeof id!=='string'||!/^[a-z0-9_-]{1,64}$/.test(id)||typeof name!=='string'||name.length<2||name.length>100||typeof razorpayPlanId!=='string'||!/^plan_[a-zA-Z0-9]+$/.test(razorpayPlanId)||!Number.isInteger(totalCount)||totalCount<1||totalCount>120)return NextResponse.json({error:'Valid plan ID, name, Razorpay plan ID and cycle count (1–120) required'},{status:400});
 const key=process.env.RAZORPAY_KEY_ID;const secret=process.env.RAZORPAY_KEY_SECRET;
 if(!key||!secret)return NextResponse.json({error:'Configure Razorpay test keys first'},{status:503});
 const result=await fetch(`https://api.razorpay.com/v1/plans/${razorpayPlanId}`,{headers:{Authorization:`Basic ${Buffer.from(`${key}:${secret}`).toString('base64')}`},cache:'no-store',signal:AbortSignal.timeout(15000)});
 if(!result.ok)return NextResponse.json({error:'Razorpay plan could not be verified'},{status:400});
 const plan=await result.json();
 await adminDb.collection('plans').doc(id).create({name,razorpayPlanId,totalCount,amount:plan.item.amount,currency:plan.item.currency,period:plan.period,interval:plan.interval,active:true,createdAt:new Date()});
 return NextResponse.json({success:true},{status:201});
}
async function patch(req:NextRequest){const {id,active}=await req.json();if(typeof id!=='string'||!/^[a-z0-9_-]{1,64}$/.test(id)||typeof active!=='boolean')return NextResponse.json({error:'Invalid plan'},{status:400});await adminDb.collection('plans').doc(id).update({active});return NextResponse.json({success:true});}
export const GET=withConsole('can_manage_billing',get);
export const POST=withConsole('can_manage_billing',post);
export const PATCH=withConsole('can_manage_billing',patch);
