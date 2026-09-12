import { NextRequest, NextResponse } from 'next/server';
import { withConsole, requireConsole } from '@/lib/admin/guard';
import { dbConnect } from '@/lib/db';
import MarketingSettings from '@/models/MarketingSettings';

async function handleGET(req: NextRequest) {
  try {
    const session = await requireConsole(req);


    // Check permission
    if (!session.permissions.can_manage_marketing && session.role !== 'super_admin') {
      return NextResponse.json({ error: 'Insufficient permissions' }, { status: 403 });
    }

    await dbConnect();

    let settings = await MarketingSettings.findOne();

    // Create default settings if none exist
    if (!settings) {
      settings = await MarketingSettings.create({
        updated_by: session.username
      });
    }

    return NextResponse.json(settings);
  } catch (error) {
    console.error('Marketing settings fetch error:', error);
    return NextResponse.json({ error: 'Failed to fetch marketing settings' }, { status: 500 });
  }
}

async function handlePATCH(req: NextRequest) {
  try {
    const session = await requireConsole(req);


    // Check permission
    if (!session.permissions.can_manage_marketing && session.role !== 'super_admin') {
      return NextResponse.json({ error: 'Insufficient permissions' }, { status: 403 });
    }

    await dbConnect();

    const { section, data } = await req.json();

    if (!section || !data) {
      return NextResponse.json({ error: 'Section and data are required' }, { status: 400 });
    }

    let settings = await MarketingSettings.findOne();

    if (!settings) {
      settings = new MarketingSettings();
    }

    // Update the specific section
    settings[section] = data;
    settings.updated_by = session.username;
    settings.updated_at = new Date();

    await settings.save();

    return NextResponse.json({ success: true, settings });
  } catch (error) {
    console.error('Marketing settings update error:', error);
    return NextResponse.json({ error: 'Failed to update marketing settings' }, { status: 500 });
  }
}

export const GET = withConsole('can_manage_marketing', handleGET);
export const PATCH = withConsole('can_manage_marketing', handlePATCH);
