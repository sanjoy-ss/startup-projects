import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';

async function handleGET(req: NextRequest) {
  try {
    const session = await requireConsole(req);


    return NextResponse.json({ 
      uid: session.uid,
      username: session.username,
      email: session.email,
      role: session.role,
      permissions: session.permissions,
      success: true 
    });
  } catch (error) {
    console.error('Auth check error:', error);
    return NextResponse.json({ error: 'Authentication failed' }, { status: 500 });
  }
}

export const GET = withConsole(undefined, handleGET);
