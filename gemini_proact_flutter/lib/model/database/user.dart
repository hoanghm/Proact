enum UserAttribute {
  email('email'),
  vaultedId('vaultedId');

  final String name;

  const UserAttribute(this.name);

  @override
  String toString() {
    return name;
  }
}

class UserTable {
  static const String name = 'User';
}