# News API Integration

## Overview
This document describes the integration of external news data into the Agamudayar Admin application. The integration allows administrators to fetch news from an external API and import it into the application's database.

## Features
- Fetch news data from an external API
- View news data before importing
- Import news data into the Firestore database
- Avoid duplicate news entries

## Implementation Details

### API Model
The external API provides news data in the following JSON format:
```json
{
  "title": "Breaking News",
  "subtitle": "Flutter 4.0 Released",
  "image": "https://example.com/flutter.jpg",
  "color": "0xFF1E88E5",
  "content_message": "Flutter 4.0 introduces performance improvements, new widgets, and enhanced DevTools support.",
  "timestamp": 1691606400000
}
```

### Components

1. **NewsApiModel**
   - Handles parsing of JSON data from the API
   - Provides conversion to the application's internal NewsModel format

2. **NewsApiService**
   - Manages HTTP requests to the external API
   - Handles error cases and response parsing

3. **NewsRepository**
   - Extended to include API-related methods
   - Manages the import process and prevents duplicates

4. **NewsBloc**
   - New events: `FetchNewsFromApi`, `ImportNewsFromApi`
   - New states: `ApiNewsLoading`, `ApiNewsLoaded`, `ApiNewsImported`

5. **NewsApiScreen**
   - UI for fetching and importing news from the API
   - Displays news items with preview before import

## Usage

1. Navigate to "News API" in the sidebar
2. Click "Fetch News" to retrieve the latest news from the API
3. Review the news items displayed on the screen
4. Click "Import to Database" to add the news items to the Firestore database
5. The imported news will appear in the regular News Approval section with a status of "pending"

## Configuration

The API base URL is configured in the `NewsApiService` class. Update the `baseUrl` property to point to your actual API endpoint.

```dart
final String baseUrl = 'https://example.com/api'; // Replace with actual API URL
```

## Error Handling

The integration includes error handling for:
- Network connectivity issues
- Invalid API responses
- Duplicate news items during import

Errors are displayed to the user via snackbar notifications.