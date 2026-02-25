# Global Search Feature - Implementation Guide

## Overview
A comprehensive global search feature has been added to your CRM application. The search bar is positioned in the center of the navbar and provides real-time search across all entities with role-based access control.

## Features Implemented

### 1. **Search Entities**
The global search covers the following entities:
- **Leads** - Search by name, contact, email
- **Properties** - Search by project name, location
- **Agents** - Search by name, contact, email (Admin/Manager/Partner only)
- **Bookings** - Search by booking number, lead name
- **Agent Documents** - Search by document name, type, filename (Admin/Manager/Partner only)
- **Property Documents** - Search by filename, document type
- **Partner Documents** - Search by document name, type, filename (Admin only)

### 2. **Role-Based Access Control**
The search respects user roles and permissions:
- **Admin**: Can search across all entities
- **Partner**: Can search within their channel partner data
- **Manager**: Can search within their channel partner data
- **Sales/Agent**: Can search their assigned leads and accessible properties

### 3. **User Interface**
- **Search Bar**: Centered in the navbar with a clean, modern design
- **Real-time Results**: Displays results as you type (with 300ms debounce)
- **Visual Indicators**: Each result shows an icon, title, subtitle, and type badge
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Dark Mode Support**: Fully compatible with your existing dark mode

### 4. **Search Results Display**
Each search result shows:
- **Icon**: Visual indicator based on entity type
- **Title**: Primary identifier (name, project name, etc.)
- **Subtitle**: Additional context (contact, location, status)
- **Type Badge**: Entity type (Lead, Property, Document, etc.)
- **Clickable**: Direct navigation to the detail page

## Files Created/Modified

### New Files:
1. **Controllers/SearchController.cs**
   - Backend API endpoint for global search
   - Role-based filtering logic
   - Returns JSON results

2. **Views/Shared/_GlobalSearch.cshtml**
   - Search bar UI component
   - JavaScript for real-time search
   - Styling for results dropdown

### Modified Files:
1. **Views/Shared/_Layout.cshtml**
   - Added global search partial view to navbar
   - Updated navbar flexbox layout

2. **Models/PropertyDocumentModel.cs**
   - Added navigation property for Property entity

## How It Works

### Backend (SearchController.cs)
```csharp
[HttpGet]
public async Task<IActionResult> GlobalSearch(string query)
{
    // 1. Validate query (minimum 2 characters)
    // 2. Get current user's role and channel partner ID
    // 3. Search across all entities with role-based filtering
    // 4. Return top 20 results (5 per entity type)
}
```

### Frontend (_GlobalSearch.cshtml)
```javascript
// 1. Listen for input changes
// 2. Debounce search (300ms delay)
// 3. Call API endpoint
// 4. Display results in dropdown
// 5. Handle click to navigate
```

## Usage

### For End Users:
1. After login, locate the search bar in the center of the navbar
2. Type at least 2 characters to start searching
3. Results appear in real-time below the search bar
4. Click any result to navigate to its detail page
5. Press ESC to clear the search
6. Click outside to close the dropdown

### For Developers:
To add more searchable entities:

1. **Update SearchController.cs**:
```csharp
// Add new entity search
var newEntities = await _context.NewEntities
    .Where(e => /* role-based filter */ && 
                e.Name.ToLower().Contains(query))
    .Take(5)
    .Select(e => new SearchResult
    {
        Id = e.Id,
        Title = e.Name,
        Subtitle = e.Description,
        Type = "New Entity",
        Icon = "icon-name",
        Url = "/Controller/Action/" + e.Id
    }).ToListAsync();
results.AddRange(newEntities);
```

2. **Update CSS in _GlobalSearch.cshtml** (if needed):
```css
.search-result-icon.new-entity { 
    background: #color; 
    color: #color; 
}
```

## Customization Options

### 1. Change Search Debounce Time
In `_GlobalSearch.cshtml`, modify:
```javascript
searchTimeout = setTimeout(() => {
    // API call
}, 300); // Change 300 to desired milliseconds
```

### 2. Change Results Limit
In `SearchController.cs`, modify:
```csharp
.Take(5) // Change to desired number per entity
```

### 3. Add More Search Fields
In `SearchController.cs`, add more conditions:
```csharp
.Where(l => l.Name.ToLower().Contains(query) || 
            l.Contact.Contains(query) ||
            l.NewField.ToLower().Contains(query)) // Add new field
```

### 4. Customize Result Display
In `_GlobalSearch.cshtml`, modify the `displayResults` function:
```javascript
html += `
    <a href="${result.url}" class="search-result-item">
        <!-- Customize HTML structure here -->
    </a>
`;
```

## Performance Considerations

1. **Debouncing**: 300ms delay prevents excessive API calls
2. **Result Limiting**: Maximum 5 results per entity type (20 total)
3. **Indexed Columns**: Ensure database columns used in search are indexed
4. **Async Operations**: All database queries use async/await

## Security Features

1. **Role-Based Access**: Users only see data they have permission to access
2. **SQL Injection Prevention**: Entity Framework parameterized queries
3. **XSS Prevention**: Results are properly escaped in HTML
4. **Authentication Required**: Search endpoint requires logged-in user

## Browser Compatibility

- Chrome/Edge: ✅ Fully supported
- Firefox: ✅ Fully supported
- Safari: ✅ Fully supported
- Mobile browsers: ✅ Fully supported

## Troubleshooting

### Search not working:
1. Check browser console for JavaScript errors
2. Verify SearchController is accessible at `/Search/GlobalSearch`
3. Ensure user is logged in with valid JWT token

### No results appearing:
1. Verify database has data matching search query
2. Check role-based permissions in SearchController
3. Ensure minimum 2 characters are entered

### Styling issues:
1. Clear browser cache
2. Check for CSS conflicts with existing styles
3. Verify dark mode classes are applied correctly

## Future Enhancements

Potential improvements:
1. **Search History**: Store recent searches
2. **Advanced Filters**: Filter by entity type, date range
3. **Keyboard Navigation**: Arrow keys to navigate results
4. **Search Analytics**: Track popular searches
5. **Fuzzy Matching**: Handle typos and partial matches
6. **Full-Text Search**: Use database full-text search capabilities

## Support

For issues or questions:
1. Check this documentation
2. Review the code comments in SearchController.cs
3. Test with different user roles to verify permissions
4. Check browser console for errors

---

**Implementation Date**: January 2025
**Version**: 1.0
**Status**: Production Ready ✅
