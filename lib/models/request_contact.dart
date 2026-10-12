/// Telephones des deux parties d'une livraison acceptee
/// (deliveryRequests/{id}/private/contact, ecrit par le serveur).
class RequestContact {
  const RequestContact({required this.clientPhone, required this.driverPhone});

  final String clientPhone;
  final String driverPhone;

  factory RequestContact.fromMap(Map<String, dynamic>? map) {
    return RequestContact(
      clientPhone: (map?['clientPhone'] as String?) ?? '',
      driverPhone: (map?['driverPhone'] as String?) ?? '',
    );
  }
}
