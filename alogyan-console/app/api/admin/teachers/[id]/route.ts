import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Teacher from '@/models/Teacher';

async function handleGET(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {


    await dbConnect();

    const { id } = await params;
    const teacher = await Teacher.findById(id).lean();

    if (!teacher) {
      return NextResponse.json({ error: 'Teacher not found' }, { status: 404 });
    }

    return NextResponse.json(teacher);
  } catch (error) {
    console.error('Teacher fetch error:', error);
    return NextResponse.json({ error: 'Failed to fetch teacher' }, { status: 500 });
  }
}

export const GET = withConsole('can_manage_teachers', handleGET);
