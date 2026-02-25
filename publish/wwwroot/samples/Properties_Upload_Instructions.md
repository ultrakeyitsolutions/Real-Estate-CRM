# Properties Bulk Upload Sample

## Excel Structure (Properties_Sample.xlsx)

### Sheet 1: Properties
Columns:
- Property Name
- Builder Name
- Location
- Area Sqft
- Price
- Purchase Type (Rent/Sale/Lease)
- Flat Number
- Floor Number
- Unit
- Group
- Inventory
- Assigned To (Sales Person Email)

### Sheet 2: Property Flats
Columns:
- Property Name
- Block Name
- Floor Name
- Flat Name
- BHK (1BHK/2BHK/3BHK/4BHK/5BHK)
- Property Type (Standalone/Flat/Villa/Apartment)
- Group
- Area Sqft
- Location
- Bedroom Count
- Bathroom Count
- Parking Available (Yes/No)
- Flat Status (Available/Booked/Sold)
- Price

## Sample Data

### Properties Sample:
```
Property Name            | Builder Name    | Location           | Area Sqft | Price      | Purchase Type | Flat Number | Floor Number | Unit | Group    | Inventory | Assigned To
Prestige Lakeside Habitat| Prestige Group  | Varthur, Bangalore | 1200      | 7500000    | Sale          | A-101       | 1            | 2BHK | Premium  | 50        | sales@example.com
Sobha Dream Acres        | Sobha Limited   | Panathur, Bangalore| 1500      | 9000000    | Sale          | B-201       | 2            | 3BHK | Luxury   | 30        | sales@example.com
Brigade Cornerstone      | Brigade Group   | Whitefield         | 1800      | 12000000   | Sale          | C-301       | 3            | 3BHK | Premium  | 40        | sales@example.com
```

### Flats Sample:
```
Property Name            | Block | Floor | Flat Name | BHK  | Property Type | Group   | Area Sqft | Location          | Bedrooms | Bathrooms | Parking | Status
Prestige Lakeside Habitat| A     | 1     | A-101     | 2BHK | Apartment     | Premium | 1200      | Varthur          | 2        | 2         | Yes     | Available
Prestige Lakeside Habitat| A     | 1     | A-102     | 2BHK | Apartment     | Premium | 1250      | Varthur          | 2        | 2         | Yes     | Available
Sobha Dream Acres        | B     | 2     | B-201     | 3BHK | Apartment     | Luxury  | 1500      | Panathur         | 3        | 2         | Yes     | Booked
```

NOTE: When uploading, ensure column names match exactly as shown above.
