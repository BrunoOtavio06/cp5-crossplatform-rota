import '../models/models.dart';

abstract class DeliveryRepository {
  Future<List<Delivery>> fetchAll();
  Future<void> saveAll(List<Delivery> deliveries);
}
