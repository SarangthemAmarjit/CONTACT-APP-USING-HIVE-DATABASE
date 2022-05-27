
import 'package:hive/hive.dart';

part 'Contactmodal.g.dart';

@HiveType(typeId: 0)



class Contactmodal {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  

  Contactmodal({
    required this.name,
    required this.phone,
    
  });
}
