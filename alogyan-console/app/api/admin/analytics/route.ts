import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Teacher from '@/models/Teacher';
import Review from '@/models/Review';

async function handleGET(req: NextRequest) {
  try {


    await dbConnect();

    // Get total teachers
    const totalTeachers = await Teacher.countDocuments();

    // Get active teachers (with ad_listing.active = true)
    const activeTeachers = await Teacher.countDocuments({ 'ad_listing.active': true });

    // Get featured teachers
    const featuredTeachers = await Teacher.countDocuments({ is_featured: true });

    // Get total reviews
    const totalReviews = await Review.countDocuments();

    // Get average rating
    const ratingStats = await Teacher.aggregate([
      {
        $group: {
          _id: null,
          averageRating: { $avg: '$rating' }
        }
      }
    ]);

    const averageRating = ratingStats[0]?.averageRating || 0;

    // Get unique subjects
    const subjectStats = await Teacher.distinct('subject');
    const totalSubjects = subjectStats.length;

    return NextResponse.json({
      totalTeachers,
      activeTeachers,
      featuredTeachers,
      totalReviews,
      averageRating,
      totalSubjects
    });
  } catch (error) {
    console.error('Analytics error:', error);
    return NextResponse.json({ error: 'Failed to fetch analytics' }, { status: 500 });
  }
}

export const GET = withConsole('can_view_analytics', handleGET);
