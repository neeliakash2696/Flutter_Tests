enum SellerType {
  manufacturer,
  exporter,
  wholesaler,
  retailer,
}

class SellerTypeInfo {
  final String name;
  final String id;

  const SellerTypeInfo(this.name, this.id);
}

class SellerTypeData {
  static const Map<SellerType, SellerTypeInfo> _data = {
    SellerType.manufacturer: SellerTypeInfo("Manufacturer", "10"),
    SellerType.exporter: SellerTypeInfo("Exporter", "20"),
    SellerType.wholesaler: SellerTypeInfo("Wholesaler", "30"),
    SellerType.retailer: SellerTypeInfo("Retailer", "40"),
  };

  static SellerTypeInfo getInfo(SellerType type) {
    return _data[type] ?? SellerTypeInfo("", "");
  }
  static String getNameOfSellerType(String value) {
    if (value != null) {
      for (var entry in _data.entries) {
        if (value.toLowerCase() == entry.value.id) {
          return entry.value.name;
        }
      }
    }
    return "null";
  }
}
