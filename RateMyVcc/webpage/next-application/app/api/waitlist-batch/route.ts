import { NextRequest, NextResponse } from 'next/server';
import { google } from 'googleapis';

// Email validation function
function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export async function POST(request: NextRequest) {
  try {
    const { emails } = await request.json();

    // Validate input
    if (!emails || !Array.isArray(emails) || emails.length === 0) {
      return NextResponse.json(
        { error: 'Valid emails array is required' },
        { status: 400 }
      );
    }

    // Validate all emails
    const validEmails = emails.filter(email => email && isValidEmail(email));
    if (validEmails.length === 0) {
      return NextResponse.json(
        { error: 'No valid email addresses provided' },
        { status: 400 }
      );
    }

    // Get environment variables
    const {
      GOOGLE_SERVICE_ACCOUNT_EMAIL,
      GOOGLE_PRIVATE_KEY,
      GOOGLE_SHEET_ID,
    } = process.env;

    if (!GOOGLE_SERVICE_ACCOUNT_EMAIL || !GOOGLE_PRIVATE_KEY || !GOOGLE_SHEET_ID) {
      console.error('Missing required environment variables');
      return NextResponse.json(
        { error: 'Server configuration error' },
        { status: 500 }
      );
    }

    // Clean and format the private key
    let privateKey = GOOGLE_PRIVATE_KEY;
    
    // Handle different private key formats (development vs production)
    if (privateKey.includes('\\n')) {
      privateKey = privateKey.replace(/\\n/g, '\n');
    }
    
    // Remove extra quotes if present (common in Vercel env vars)
    privateKey = privateKey.replace(/^["']|["']$/g, '');
    
    // Add proper formatting if it's a raw key without headers
    if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
      // Check if it's a base64 encoded key without headers
      if (privateKey.length > 100 && !privateKey.includes('\n')) {
        // This might be a raw base64 key, try to format it
        console.error('Private key appears to be missing headers. Expected format: -----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----');
      }
      
      console.error('Private key missing proper headers. Key preview:', privateKey.substring(0, 50) + '...');
      return NextResponse.json(
        { error: 'Invalid private key format. Make sure the key includes -----BEGIN PRIVATE KEY----- and -----END PRIVATE KEY----- headers.' },
        { status: 500 }
      );
    }
    
    // Validate the key format
    if (!privateKey.includes('-----END PRIVATE KEY-----')) {
      console.error('Private key missing footer');
      return NextResponse.json(
        { error: 'Invalid private key format. Missing -----END PRIVATE KEY----- footer.' },
        { status: 500 }
      );
    }

    // Create Google Sheets client
    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: GOOGLE_SERVICE_ACCOUNT_EMAIL,
        private_key: privateKey,
      },
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });

    const sheets = google.sheets({ version: 'v4', auth });

    // Get current timestamp
    const timestamp = new Date().toISOString();

    // Prepare batch data
    const values = validEmails.map(email => [email, timestamp]);

    // Batch append to the sheet
    await sheets.spreadsheets.values.append({
      spreadsheetId: GOOGLE_SHEET_ID,
      range: 'Sheet1!A:B',
      valueInputOption: 'USER_ENTERED',
      requestBody: {
        values,
      },
    });

    return NextResponse.json(
      { 
        message: `${validEmails.length} emails successfully added to waitlist`,
        processed: validEmails.length,
        skipped: emails.length - validEmails.length
      },
      { status: 200 }
    );

  } catch (error) {
    console.error('Error adding emails to waitlist:', error);
    
    let errorMessage = 'Failed to add emails to waitlist';
    
    if (error instanceof Error) {
      if (error.message.includes('DECODER routines')) {
        errorMessage = 'Invalid private key format. Please check your GOOGLE_PRIVATE_KEY environment variable.';
      } else if (error.message.includes('permission')) {
        errorMessage = 'Permission denied. Make sure the service account has access to the Google Sheet.';
      } else if (error.message.includes('not found')) {
        errorMessage = 'Google Sheet not found. Please check your GOOGLE_SHEET_ID.';
      }
    }
    
    return NextResponse.json(
      { error: errorMessage },
      { status: 500 }
    );
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
} 