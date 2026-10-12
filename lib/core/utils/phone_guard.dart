/// Detection d'un numero de mobile algerien dans un texte libre.
///
/// Les numeros ne s'echangent qu'apres l'acceptation d'une livraison :
/// firestore.rules refuse tout message, note ou nom qui en contient un
/// (fonction hasPhone, meme motif). Ce test permet d'afficher un message
/// clair avant l'envoi au lieu d'une erreur.
///
/// Reconnait 05/06/07 + 8 chiffres, +213 / 00213 / 213, avec espaces, points
/// ou tirets, en chiffres latins ou arabes.
final RegExp _phonePattern = RegExp(
  r'(0|٠|۰|\+?213|00213)[ .\-]*[5-7٥-٧۵-۷]([ .\-]*[0-9٠-٩۰-۹]){8}',
);

bool containsPhoneNumber(String text) => _phonePattern.hasMatch(text);
