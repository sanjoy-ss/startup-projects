export const dynamic = 'force-dynamic';
import "./globals.css";
export const metadata = { title: "Alogyan Console", robots: { index: false, follow: false } };
export default function Layout({children}: {children: React.ReactNode}) { return <html lang="en"><body>{children}</body></html>; }
