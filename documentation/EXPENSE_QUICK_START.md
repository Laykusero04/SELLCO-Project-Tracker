# Expense Management - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
1. Flutter app is running
2. Firebase is configured
3. User is authenticated

### First Time Setup

#### 1. Configure Firebase Indexes
Go to Firebase Console → Firestore → Indexes and create:

```
Collection: expenses
Fields: is_deleted (Ascending), expense_date (Descending)

Collection: expenses
Fields: is_deleted (Ascending), category (Ascending), expense_date (Descending)

Collection: expenses
Fields: is_deleted (Ascending), status (Ascending), expense_date (Descending)
```

#### 2. Update Firebase Security Rules
Add to Firestore rules:
```javascript
match /expenses/{expenseId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update: if request.auth != null;
  allow delete: if request.auth != null;
}
```

Add to Storage rules:
```javascript
match /expenses/receipts/{expenseId}/{fileName} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
  allow delete: if request.auth != null;
}
```

---

## 📱 Using the App

### Opening Expense Management
1. Open the app
2. Tap the hamburger menu (☰)
3. Select **"Expenses"**

### Adding Your First Expense

**Quick Steps:**
1. Tap the **"Add Expense"** button (bottom right)
2. Enter title (e.g., "MacBook Pro M3")
3. Select category (e.g., "Equipment")
4. Select subcategory (e.g., "Computer Hardware")
5. Enter amount (e.g., "2499.00")
6. Select date
7. Choose payment method
8. Tap **"Add Expense"**

**With Receipt:**
1. Follow steps above
2. Scroll to "Receipt" section
3. Tap **"Choose Image"** or **"Take Photo"**
4. Select/capture receipt image
5. Tap **"Add Expense"**

### Searching & Filtering

**Search:**
- Type in search bar at top
- Searches: titles, descriptions, vendors, tags

**Filter:**
1. Tap filter icon (⚡)
2. Select category, status, or date range
3. Tap **"Apply"**
4. Remove filters by tapping chip or **"Clear All"**

### Managing Expenses

**View Details:**
- Tap any expense card

**Edit Expense:**
1. Open expense details
2. Tap three-dot menu (⋮)
3. Select **"Edit"**
4. Make changes
5. Tap **"Update Expense"**

**Change Status:**
1. Open expense details
2. Tap three-dot menu (⋮)
3. Select **"Change Status"**
4. Choose: Approve, Mark as Paid, or Reject

**Delete Expense:**
1. Open expense details
2. Tap three-dot menu (⋮)
3. Select **"Delete"**
4. Confirm deletion

---

## 💡 Tips & Tricks

### Best Practices
- ✅ Always attach receipts for tracking
- ✅ Use descriptive titles
- ✅ Add vendor information when possible
- ✅ Use tags for better organization
- ✅ Set recurring for subscriptions
- ✅ Approve expenses promptly

### Organization Tips
- Use consistent naming: "Category - Item - Vendor"
- Tag by project: "project-alpha", "project-beta"
- Tag by urgency: "urgent", "quarterly-review"
- Tag by department: "engineering", "marketing"

### Common Categories

**Equipment:**
- Laptops, monitors, keyboards, mice
- Office furniture, desk accessories
- Phones, tablets, accessories

**Software:**
- GitHub, VS Code extensions
- Figma, Adobe Creative Cloud
- AWS, Google Cloud, Azure
- Slack, Notion, productivity tools

**Business:**
- Office supplies, printer paper
- Internet, electricity bills
- Google Ads, social media ads
- Client meetings, conferences

---

## 🔄 Recurring Expenses

### Setting Up Recurring
1. Create expense normally
2. Toggle **"This is a recurring expense"**
3. Select frequency:
   - Monthly (e.g., subscriptions)
   - Quarterly (e.g., tax payments)
   - Yearly (e.g., annual licenses)
4. Set next occurrence date
5. Save expense

### Examples of Recurring Expenses
- GitHub subscription: $40/month
- Adobe Creative Cloud: $55/month
- AWS hosting: varies monthly
- Office rent: fixed monthly
- Insurance: quarterly or yearly

---

## 📊 Understanding Status

### Status Types

**🟠 Pending**
- Newly created expenses
- Awaiting review
- Default status

**🔵 Approved**
- Reviewed and approved
- Ready for payment
- Can be marked as paid

**🟢 Paid**
- Payment completed
- Final status for expense
- Tracked in reports

**🔴 Rejected**
- Not approved
- Requires reason
- Can be edited and resubmitted

### Status Workflow
```
Pending → Approved → Paid
   ↓
Rejected (with reason)
```

---

## 🎯 Common Workflows

### Workflow 1: Quick Expense Entry
```
1. Tap "Add Expense"
2. Fill required fields (title, category, amount)
3. Tap "Add Expense"
4. Done! (2 minutes)
```

### Workflow 2: Complete Expense with Receipt
```
1. Tap "Add Expense"
2. Fill all details
3. Take photo of receipt
4. Add tags and notes
5. Tap "Add Expense"
6. Done! (5 minutes)
```

### Workflow 3: Monthly Review
```
1. Open Expenses
2. Tap filter → This Month
3. Review all expenses
4. Approve legitimate ones
5. Reject questionable ones
6. Export for accounting
```

### Workflow 4: Recurring Subscription Setup
```
1. Add new expense (e.g., "GitHub Team Plan")
2. Amount: $40
3. Toggle recurring: ON
4. Frequency: Monthly
5. Next date: Next month same day
6. Save
7. System auto-creates monthly
```

---

## 🐛 Troubleshooting

### Issue: Can't add expense
**Solution:**
- Check internet connection
- Verify you're authenticated
- Ensure required fields filled

### Issue: Receipt won't upload
**Solution:**
- Check image size (must be < 5MB)
- Try different image format
- Check storage permissions
- Compress image if needed

### Issue: Expenses not showing
**Solution:**
- Pull down to refresh
- Check filters (clear all)
- Verify date range
- Check Firebase connection

### Issue: Search not working
**Solution:**
- Type at least 2 characters
- Check spelling
- Try different search terms
- Clear filters first

---

## 📱 Keyboard Shortcuts

### Form Navigation
- **Tab** - Next field
- **Shift+Tab** - Previous field
- **Enter** - Submit form (when valid)

### List Navigation
- **↑/↓** - Scroll list
- **/** - Focus search
- **Esc** - Clear search/close dialog

---

## 💬 Need Help?

### Quick Links
- [Full Documentation](./EXPENSE_MANAGEMENT_IMPLEMENTATION.md)
- [Planning Document](./SELLCO_Project_Tracker_Documentation.md)

### Support Channels
- Ask team lead
- Check documentation
- Review error messages
- Test with sample data first

---

## 📈 Next Steps After Setup

1. **Week 1:**
   - Add historical expenses
   - Upload existing receipts
   - Set up recurring expenses
   - Train team members

2. **Week 2:**
   - Review and approve expenses
   - Export first report
   - Adjust categories if needed
   - Refine tagging system

3. **Week 3:**
   - Analyze spending patterns
   - Set up budgets (future feature)
   - Optimize workflows
   - Collect feedback

4. **Ongoing:**
   - Weekly expense review
   - Monthly approval cycle
   - Quarterly financial reports
   - Annual tax preparation

---

## ✨ Pro Tips

1. **Batch Processing:** Review and approve multiple expenses at once
2. **Smart Tags:** Create tag conventions for your team
3. **Receipt Quality:** Take clear, well-lit receipt photos
4. **Consistent Timing:** Process expenses weekly to avoid backlog
5. **Regular Backups:** Export data monthly for records
6. **Team Training:** Ensure everyone knows the workflow

---

**Remember:** The system is designed for internal company use. All expenses are tracked and auditable. Be accurate and timely with entries!

---

## 🎉 You're Ready!

You now have everything you need to manage company expenses effectively. Start with simple expenses, then gradually use more advanced features.

**Happy expense tracking!** 💰📊
