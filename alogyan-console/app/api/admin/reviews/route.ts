import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import Review from '@/models/Review';
import Teacher from '@/models/Teacher';

async function handleGET(req: NextRequest) {
  try {


    await dbConnect();

    // Get all reviews with teacher name populated
    const reviews = await Review.aggregate([
      {
        $lookup: {
          from: 'teachers',
          localField: 'teacher_id',
          foreignField: '_id',
          as: 'teacher'
        }
      },
      {
        $addFields: {
          teacher_name: { $arrayElemAt: ['$teacher.name', 0] }
        }
      },
      {
        $project: {
          teacher: 0
        }
      },
      {
        $sort: { created_at: -1 }
      }
    ]);

    return NextResponse.json(reviews);
  } catch (error) {
    console.error('Reviews fetch error:', error);
    return NextResponse.json({ error: 'Failed to fetch reviews' }, { status: 500 });
  }
}

async function handleDELETE(req: NextRequest) {
  try {


    await dbConnect();

    const { reviewId } = await req.json();

    if (!reviewId) {
      return NextResponse.json({ error: 'Review ID is required' }, { status: 400 });
    }

    const deletedReview = await Review.findByIdAndDelete(reviewId);

    if (!deletedReview) {
      return NextResponse.json({ error: 'Review not found' }, { status: 404 });
    }

    // Update teacher rating
    const stats = await Review.aggregate([
      { $match: { teacher_slug: deletedReview.teacher_slug } },
      { $group: { _id: '$teacher_slug', avg: { $avg: '$rating' }, count: { $sum: 1 } } }
    ]);

    const { avg = 0, count = 0 } = stats[0] || {};

    await Teacher.findOneAndUpdate(
      { 'seo.slug': deletedReview.teacher_slug },
      {
        rating: Math.round(avg * 10) / 10,
        review_count: count
      }
    );

    return NextResponse.json({ success: true, message: 'Review deleted' });
  } catch (error) {
    console.error('Review delete error:', error);
    return NextResponse.json({ error: 'Failed to delete review' }, { status: 500 });
  }
}

export const GET = withConsole('can_manage_reviews', handleGET);
export const DELETE = withConsole('can_manage_reviews', handleDELETE);
