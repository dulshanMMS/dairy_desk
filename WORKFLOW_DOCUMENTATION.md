# Dairy Desk - New Workflow Documentation

## Overview
The app now implements a **session-based daily tracking system** that separates product master data from daily business transactions.

## Key Concepts

### 1. **Product Master**
- **Purpose**: Static product information (catalog)
- **Location**: Managed separately in "Product Settings" or similar area
- **Contains**: 
  - Product name
  - Category (dairy, farm, shop)
  - Buy price
  - Sell price
  - Unit (liter, kg, piece, etc.)
  - Active/Inactive status

### 2. **Daily Session**
- **Purpose**: Track daily business activities
- **Unique per**: Business type + Date
- **Contains**: 
  - List of daily product entries
  - Session notes
  - Open/Closed status
  - Creation and closing timestamps

### 3. **Daily Product Entry**
- **Purpose**: Daily transaction data for a specific product
- **Contains**:
  - Product reference (from Product Master)
  - Sent count (items distributed/available at start of day)
  - Return count (items returned at end of day)
  - Sold count (items actually sold)
  - Shop reference (if applicable)
  - Daily notes

## Workflow

### Daily Business Flow

1. **Start of Day**
   - User opens the app
   - App creates or loads today's session for the business type
   - User adds products they're working with today

2. **Adding Daily Data**
   - Select a product from Product Master
   - Enter today's counts:
     - How many sent out/available
     - Expected shop (if distributing)
   
3. **End of Day**
   - Update return counts
   - System automatically calculates:
     - Sold = Sent - Returned
     - Revenue = Sold × Sell Price
     - Profit = (Sell Price - Buy Price) × Sold

4. **Session Close**
   - Mark session as closed
   - Data is saved for analytics

### Product Master Management

- **Add New Products**: In settings/product management page
- **Edit Products**: Update prices, categories, units
- **Deactivate Products**: Soft delete (hide from active lists)
- **View All Products**: See complete catalog

## Benefits

### 1. **Historical Tracking**
- Each day is a separate session
- Can view any past date's activities
- Complete audit trail

### 2. **Analytics Ready**
- Compare performance across dates
- Identify best-selling products
- Track profit trends
- Monthly/yearly summaries

### 3. **Flexible Data Entry**
- Different products on different days
- No need to enter all products daily
- Each shop can have separate entries

### 4. **Clean Data Structure**
- Product prices stored in daily entries (historical accuracy)
- Can change master prices without affecting past data
- Easy to generate reports

## Data Calculations

### Per Product (Daily)
- **Net Count**: Sent - Returned
- **Sold Count**: Actual items sold
- **Revenue**: Sold × Sell Price
- **Cost**: Sold × Buy Price
- **Profit**: Revenue - Cost
- **Profit Margin**: (Profit / Cost) × 100

### Per Session (Daily)
- **Total Items Sent**: Sum of all products sent
- **Total Items Returned**: Sum of all products returned
- **Total Revenue**: Sum of all product revenues
- **Total Cost**: Sum of all product costs
- **Total Profit**: Total Revenue - Total Cost

### Per Business Type (Period)
- **Total Profit**: Sum of all session profits in period
- **Average Daily Revenue**: Total Revenue / Number of Days
- **Best Selling Products**: Products with highest sold count
- **Profit Trends**: Daily/weekly/monthly comparisons

## Database Collections

### `product_master`
```json
{
  "_id": "ObjectId",
  "name": "Full Cream Milk",
  "category": "dairy",
  "buyPrice": 50.0,
  "sellPrice": 60.0,
  "unit": "liter",
  "isActive": true,
  "createdAt": "2025-12-15T...",
  "updatedAt": "2025-12-15T..."
}
```

### `daily_sessions`
```json
{
  "_id": "ObjectId",
  "date": "2025-12-15T00:00:00.000Z",
  "businessType": "dairy",
  "products": [
    {
      "productId": "product_master_id",
      "productName": "Full Cream Milk",
      "sentCount": 100,
      "returnCount": 15,
      "soldCount": 85,
      "buyPrice": 50.0,
      "sellPrice": 60.0,
      "shopId": "shop_id",
      "notes": "Good sales today"
    }
  ],
  "notes": "Normal business day",
  "isClosed": true,
  "createdAt": "2025-12-15T06:00:00.000Z",
  "closedAt": "2025-12-15T20:00:00.000Z"
}
```

## Implementation Status

### ✅ Completed
- [x] Product Master model
- [x] Daily Session model
- [x] Database service methods
- [x] Daily Session service with analytics

### 🔄 In Progress
- [ ] Product Master management UI
- [ ] Daily session entry UI
- [ ] Update existing dairy/farm/shop pages
- [ ] Enhanced analytics dashboard

### 📋 To Do
- [ ] Historical session viewer
- [ ] Date picker for past entries
- [ ] Export reports (PDF/Excel)
- [ ] Offline sync improvements
- [ ] Backup/restore functionality

## Next Steps

1. **Create Product Master Management Page**
   - List all products
   - Add/Edit/Delete products
   - Filter by category
   - Search functionality

2. **Update Dairy/Farm/Shop Pages**
   - Show today's session
   - Quick add daily entries
   - View current day summary

3. **Enhance Analytics Page**
   - Show data from daily sessions
   - Date range selector
   - Profit trends graphs
   - Best performing products

4. **Add Session History Viewer**
   - Calendar view
   - Select any date to view past sessions
   - Edit past entries (with audit trail)

