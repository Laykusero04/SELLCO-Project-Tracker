import 'package:flutter/material.dart';

class ExpenseCategories {
  // Main categories
  static const String equipment = 'equipment';
  static const String software = 'software';
  static const String business = 'business';
  static const String other = 'other';

  // Equipment subcategories
  static const String computerHardware = 'computer_hardware';
  static const String peripherals = 'peripherals';
  static const String officeFurniture = 'office_furniture';
  static const String mobileDevices = 'mobile_devices';
  static const String networkingEquipment = 'networking_equipment';
  static const String otherEquipment = 'other_equipment';

  // Software subcategories
  static const String developmentTools = 'development_tools';
  static const String aiTools = 'ai_tools';
  static const String designSoftware = 'design_software';
  static const String cloudServices = 'cloud_services';
  static const String productivityTools = 'productivity_tools';
  static const String securitySoftware = 'security_software';
  static const String otherSoftware = 'other_software';

  // Business subcategories
  static const String officeSupplies = 'office_supplies';
  static const String utilities = 'utilities';
  static const String marketing = 'marketing';
  static const String travel = 'travel';
  static const String professionalServices = 'professional_services';
  static const String insurance = 'insurance';
  static const String licensesPermits = 'licenses_permits';
  static const String otherBusiness = 'other_business';

  // Payment methods
  static const String cash = 'cash';
  static const String creditCard = 'credit_card';
  static const String debitCard = 'debit_card';
  static const String bankTransfer = 'bank_transfer';
  static const String companyCard = 'company_card';

  // Status
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String paid = 'paid';
  static const String rejected = 'rejected';

  // Recurrence periods
  static const String monthly = 'monthly';
  static const String quarterly = 'quarterly';
  static const String yearly = 'yearly';

  // Category display data
  static final Map<String, Map<String, dynamic>> categoryData = {
    equipment: {
      'name': 'Equipment',
      'icon': Icons.computer,
      'color': Colors.blue,
    },
    software: {
      'name': 'Software & Subscriptions',
      'icon': Icons.cloud_outlined,
      'color': Colors.purple,
    },
    business: {
      'name': 'Business Expenses',
      'icon': Icons.business_center,
      'color': Colors.green,
    },
    other: {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  };

  // Subcategory display names
  static final Map<String, String> subcategoryNames = {
    // Equipment
    computerHardware: 'Computer Hardware',
    peripherals: 'Peripherals',
    officeFurniture: 'Office Furniture',
    mobileDevices: 'Mobile Devices',
    networkingEquipment: 'Networking Equipment',
    otherEquipment: 'Other Equipment',
    // Software
    developmentTools: 'Development Tools',
    aiTools: 'AI Tools',
    designSoftware: 'Design Software',
    cloudServices: 'Cloud Services',
    productivityTools: 'Productivity Tools',
    securitySoftware: 'Security Software',
    otherSoftware: 'Other Software',
    // Business
    officeSupplies: 'Office Supplies',
    utilities: 'Utilities',
    marketing: 'Marketing',
    travel: 'Travel',
    professionalServices: 'Professional Services',
    insurance: 'Insurance',
    licensesPermits: 'Licenses & Permits',
    otherBusiness: 'Other Business',
  };

  // Subcategories by category
  static final Map<String, List<String>> subcategoriesByCategory = {
    equipment: [
      computerHardware,
      peripherals,
      officeFurniture,
      mobileDevices,
      networkingEquipment,
      otherEquipment,
    ],
    software: [
      developmentTools,
      aiTools,
      designSoftware,
      cloudServices,
      productivityTools,
      securitySoftware,
      otherSoftware,
    ],
    business: [
      officeSupplies,
      utilities,
      marketing,
      travel,
      professionalServices,
      insurance,
      licensesPermits,
      otherBusiness,
    ],
    other: [],
  };

  // Payment method display names
  static final Map<String, String> paymentMethodNames = {
    cash: 'Cash',
    creditCard: 'Credit Card',
    debitCard: 'Debit Card',
    bankTransfer: 'Bank Transfer',
    companyCard: 'Company Card',
  };

  // Status display names and colors
  static final Map<String, Map<String, dynamic>> statusData = {
    pending: {
      'name': 'Pending',
      'color': Colors.orange,
      'icon': Icons.pending,
    },
    approved: {
      'name': 'Approved',
      'color': Colors.blue,
      'icon': Icons.check_circle_outline,
    },
    paid: {
      'name': 'Paid',
      'color': Colors.green,
      'icon': Icons.check_circle,
    },
    rejected: {
      'name': 'Rejected',
      'color': Colors.red,
      'icon': Icons.cancel,
    },
  };

  // Recurrence period display names
  static final Map<String, String> recurrencePeriodNames = {
    monthly: 'Monthly',
    quarterly: 'Quarterly',
    yearly: 'Yearly',
  };

  // Helper methods
  static String getCategoryName(String category) {
    return categoryData[category]?['name'] ?? 'Unknown';
  }

  static IconData getCategoryIcon(String category) {
    return categoryData[category]?['icon'] ?? Icons.help_outline;
  }

  static Color getCategoryColor(String category) {
    return categoryData[category]?['color'] ?? Colors.grey;
  }

  static String getSubcategoryName(String subcategory) {
    return subcategoryNames[subcategory] ?? subcategory;
  }

  static String getPaymentMethodName(String method) {
    return paymentMethodNames[method] ?? method;
  }

  static String getStatusName(String status) {
    return statusData[status]?['name'] ?? status;
  }

  static Color getStatusColor(String status) {
    return statusData[status]?['color'] ?? Colors.grey;
  }

  static IconData getStatusIcon(String status) {
    return statusData[status]?['icon'] ?? Icons.help_outline;
  }

  static String getRecurrencePeriodName(String period) {
    return recurrencePeriodNames[period] ?? period;
  }

  static List<String> getSubcategoriesForCategory(String category) {
    return subcategoriesByCategory[category] ?? [];
  }

  static List<String> getAllCategories() {
    return [equipment, software, business, other];
  }

  static List<String> getAllPaymentMethods() {
    return [cash, creditCard, debitCard, bankTransfer, companyCard];
  }

  static List<String> getAllStatuses() {
    return [pending, approved, paid, rejected];
  }

  static List<String> getAllRecurrencePeriods() {
    return [monthly, quarterly, yearly];
  }
}
