import Records from '@/components/console/Records';
export default function Page(){return <Records title="Audit log" description="Console changes record staff identity, action and outcome. Pending entries may need investigation after an interrupted operation." endpoint="/api/admin/audit"/>;}
