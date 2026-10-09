import { NextRequest, NextResponse } from 'next/server';
import { adminAuth } from '@/lib/firebase-admin';
import { assertOrigin, CONSOLE_COOKIE, staffFor } from '@/lib/admin/auth';
export async function POST(req: NextRequest) {
    try {
        assertOrigin(req);
        const body = await req.json();
        if (body.action === 'logout') {
            const response = NextResponse.json({ success: true });
            const token = req.cookies.get(CONSOLE_COOKIE)?.value;
            if (token) { try { const user = await adminAuth.verifySessionCookie(token); await adminAuth.revokeRefreshTokens(user.uid); } catch { } }
            response.cookies.delete(CONSOLE_COOKIE); return response;
        }
        const token = body.idToken || body.googleIdToken;
        if (typeof token !== 'string') return NextResponse.json({ error: 'Sign in with Firebase first' }, { status: 401 });
        const identity = await adminAuth.verifyIdToken(token, true);
        if (!identity.email_verified || Date.now() / 1000 - identity.auth_time > 300) throw new Error('Invalid identity');
        const staff = await staffFor(identity.uid);
        if (!staff) throw new Error('Not internal staff');
        const cookie = await adminAuth.createSessionCookie(token, { expiresIn: 8 * 60 * 60 * 1000 });
        const response = NextResponse.json({ success: true, admin: staff }, { headers: { 'Cache-Control': 'no-store' } });
        response.cookies.set(CONSOLE_COOKIE, cookie, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'strict', path: '/', maxAge: 8 * 60 * 60 });
        return response;
    } catch { return NextResponse.json({ error: 'Unable to sign in. Use a verified, invited staff account.' }, { status: 401 }); }
}
