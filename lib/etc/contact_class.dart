class Contact {
  final int id;
  final String title;

  Contact({required this.id, required this.title});

  factory Contact.fromJson(Map<String, dynamic> data) {
    // note the explicit cast to String
    // this is required if robust lint rules are enabled
    final id = data['id'] as int;
    final title = data['title'] as String;
    return Contact(id: id, title: title);
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
  };
}