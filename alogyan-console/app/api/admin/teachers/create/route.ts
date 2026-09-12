import { isDirectoryCategory } from '@/lib/directory-categories';
import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Teacher from '@/models/Teacher';

async function handlePOST(req: NextRequest) {
  try {


    await dbConnect();

    const teacherData = await req.json();
    if (teacherData.category !== undefined && teacherData.category !== '' && (typeof teacherData.category !== 'string' || !isDirectoryCategory(teacherData.category))) {
      return NextResponse.json({ error: 'Invalid education category' }, { status: 400 });
    }

    if (!teacherData.name || !teacherData.id || !teacherData.seo?.slug) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    const existingTeacher = await Teacher.findOne({
      $or: [{ id: teacherData.id }, { 'seo.slug': teacherData.seo.slug }]
    });

    if (existingTeacher) {
      return NextResponse.json({ error: 'Teacher with this slug or ID already exists' }, { status: 409 });
    }

    const newTeacher = await Teacher.create(teacherData);

    return NextResponse.json({ success: true, teacher: newTeacher }, { status: 201 });
  } catch (error: any) {
    console.error('Teacher create error:', error);
    return NextResponse.json({ error: error.message || 'Failed to create teacher' }, { status: 500 });
  }
}

export const POST = withConsole('can_manage_teachers', handlePOST);
