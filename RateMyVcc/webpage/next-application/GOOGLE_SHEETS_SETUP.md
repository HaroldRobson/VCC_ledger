# Google Sheets Integration Setup Guide

This guide will help you set up Google Sheets integration for your waitlist email collection in production.

## Prerequisites

- Google Account
- Google Cloud Console access
- A Google Sheets document

## Step 1: Create a Google Sheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it "CBX Waitlist" or similar
4. In the first row, add headers:
   - Cell A1: `Email`
   - Cell B1: `Timestamp`
5. Copy the spreadsheet ID from the URL:
   - URL: `https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit`
   - Sheet ID: `1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms`

## Step 2: Set Up Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sheets API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google Sheets API"
   - Click on it and press "Enable"

## Step 3: Create Service Account

1. In Google Cloud Console, go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in the details:
   - Service account name: `cbx-waitlist-service`
   - Service account ID: (auto-generated)
   - Description: `Service account for CBX waitlist Google Sheets integration`
4. Click "Create and Continue"
5. Skip the optional steps and click "Done"

## Step 4: Generate Service Account Key

1. In the "Credentials" page, find your service account
2. Click on the service account email
3. Go to the "Keys" tab
4. Click "Add Key" > "Create new key"
5. Choose "JSON" format
6. Click "Create" - this will download a JSON file

## Step 5: Extract Credentials from JSON

Open the downloaded JSON file and find these values:
- `client_email` - this is your `GOOGLE_SERVICE_ACCOUNT_EMAIL`
- `private_key` - this is your `GOOGLE_PRIVATE_KEY`

## Step 6: Share Sheet with Service Account

1. Go back to your Google Sheet
2. Click the "Share" button
3. Add the service account email (from the JSON file) as an editor
4. Make sure "Notify people" is unchecked
5. Click "Share"

## Step 7: Set Environment Variables

### For Local Development
Create a `.env.local` file in your project root:

```env
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----"
GOOGLE_SHEET_ID=your_google_sheet_id_from_url
```

### For Production (Vercel)
1. Go to your Vercel project settings
2. Navigate to "Environment Variables"
3. Add each variable:
   - `GOOGLE_SERVICE_ACCOUNT_EMAIL`
   - `GOOGLE_PRIVATE_KEY` (make sure to wrap in quotes and include `\n` for line breaks)
   - `GOOGLE_SHEET_ID`

### For Production (Other Platforms)
Set the environment variables according to your hosting platform's documentation.

## Step 8: Test the Integration

1. Start your development server: `npm run dev`
2. Navigate to the waitlist section on your website
3. Submit a test email
4. Check your Google Sheet to see if the email appears

## Troubleshooting

### Common Issues

1. **"Error: No key or keyFile set"**
   - Make sure `GOOGLE_PRIVATE_KEY` is set correctly
   - Ensure the private key includes the `\n` characters for line breaks

2. **"Error: The caller does not have permission"**
   - Make sure you shared the Google Sheet with the service account email
   - Verify the service account has editor permissions

3. **"Error: Requested entity was not found"**
   - Check that the `GOOGLE_SHEET_ID` is correct
   - Ensure the sheet exists and is accessible

4. **"Error: Invalid JWT"**
   - Verify the service account email and private key are correct
   - Make sure there are no extra spaces or characters in the environment variables

### Development vs Production

- The integration works the same in development and production
- Make sure to use different Google Sheets for development and production if needed
- Environment variables must be set in your production hosting environment

## Security Notes

- Never commit the `.env.local` file or actual credentials to version control
- Keep your service account key secure
- Regularly rotate your service account keys
- Only give the service account the minimum permissions needed (editor access to the specific sheet)

## Sheet Structure

The API expects the following column structure:
- Column A: Email addresses
- Column B: Timestamps (automatically added)

You can add additional columns for other data if needed by modifying the API route. 