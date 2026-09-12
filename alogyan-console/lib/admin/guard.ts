import { NextRequest, NextResponse } from 'next/server';
import { assertOrigin, CONSOLE_COOKIE, verifyAdminToken, type AdminSession } from './auth';
import { adminDb } from '@/lib/firebase-admin';
const identities = new WeakMap<NextRequest, ReturnType<typeof verifyAdminToken>>();
export async function requireConsole(req: NextRequest, permission?: string): Promise<AdminSession> {
 assertOrigin(req);
 let pending = identities.get(req);
 if (!pending) { pending = verifyAdminToken(req.cookies.get(CONSOLE_COOKIE)?.value || ''); identities.set(req,pending); }
 const session = await pending;
 if (!session) throw new Error('AUTH_UNAUTHORIZED');
 if (permission && !session.permissions[permission]) throw new Error('AUTH_FORBIDDEN');
 return session;
}
export function withConsole<C>(permission: string | undefined, handler: (req: NextRequest, context: C) => Promise<NextResponse>) {
 return async (req: NextRequest, context: C) => {
  try {
   const session = await requireConsole(req, permission);
   const mutation = !['GET','HEAD','OPTIONS'].includes(req.method);
   const audit = mutation ? adminDb.collection('auditLogs').doc() : null;
   // Record intent before external-store mutations; retain pending records if the process fails.
   if (audit) await audit.create({actorId:session.uid,action:req.method,path:req.nextUrl.pathname,status:'pending',createdAt:new Date()});
   const response = await handler(req, context);
   if (audit) await audit.update({status:response.ok ? 'succeeded' : 'failed',httpStatus:response.status,completedAt:new Date()});
   response.headers.set('Cache-Control','no-store');
   return response;
  } catch(error) {
   const message = error instanceof Error ? error.message : '';
   const status = message === 'AUTH_UNAUTHORIZED' ? 401 : message.startsWith('AUTH_') ? 403 : 500;
   return NextResponse.json({error:status===500 ? 'Operation failed' : 'Console access denied'}, {status,headers:{'Cache-Control':'no-store'}});
  }
 };
}
