import { isDirectoryCategory } from '@/lib/directory-categories';
import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Teacher from '@/models/Teacher';

async function handleGET(req: NextRequest) {
  try {


    await dbConnect();

    const page = Math.max(1, Math.min(1000, Number(req.nextUrl.searchParams.get('page')) || 1));
    const teachers = await Teacher.find()
      .select('name institution profile_image rating subject location is_featured ad_listing email phone created_at')
      .sort({ created_at: -1, _id: -1 }).skip((page - 1) * 50).limit(51)
      .lean();

    return NextResponse.json(teachers.slice(0,50), {headers:{'X-Has-More':String(teachers.length>50)}});
  } catch (error) {
    console.error('Teachers fetch error:', error);
    return NextResponse.json({ error: 'Failed to fetch teachers' }, { status: 500 });
  }
}

async function handlePATCH(req: NextRequest) {
  try {


    await dbConnect();

    const { teacherId, ...updates } = await req.json();
    if (updates.category !== undefined && updates.category !== '' && (typeof updates.category !== 'string' || !isDirectoryCategory(updates.category))) {
      return NextResponse.json({ error: 'Invalid education category' }, { status: 400 });
    }

    if (!teacherId) {
      return NextResponse.json({ error: 'Teacher ID is required' }, { status: 400 });
    }

    const updatedTeacher = await Teacher.findByIdAndUpdate(
      teacherId,
      { $set: updates },
      { new: true }
    );

    if (!updatedTeacher) {
      return NextResponse.json({ error: 'Teacher not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, teacher: updatedTeacher });
  } catch (error) {
    console.error('Teacher update error:', error);
    return NextResponse.json({ error: 'Failed to update teacher' }, { status: 500 });
  }
}

async function handleDELETE(req: NextRequest) {
  try {


    await dbConnect();

    const { teacherId } = await req.json();

    if (!teacherId) {
      return NextResponse.json({ error: 'Teacher ID is required' }, { status: 400 });
    }

    const deletedTeacher = await Teacher.findByIdAndDelete(teacherId);

    if (!deletedTeacher) {
      return NextResponse.json({ error: 'Teacher not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, message: 'Teacher deleted' });
  } catch (error) {
    console.error('Teacher delete error:', error);
    return NextResponse.json({ error: 'Failed to delete teacher' }, { status: 500 });
  }
}

export const GET = withConsole('can_manage_teachers', handleGET);
export const PATCH = withConsole('can_manage_teachers', handlePATCH);
export const DELETE = withConsole('can_manage_teachers', handleDELETE);
