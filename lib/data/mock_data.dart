class MockData {
  static List<Map<String, dynamic>> lostItems = [
    {
      'id': '1',
      'title': 'iPhone 13 Pro',
      'category': 'Electrónicos',
      'description': 'Cor azul, capa preta.',
      'date_lost': '2024-05-10',
      'status': 'lost',
    },
    {
      'id': '2',
      'title': 'Chaves de Casa',
      'category': 'Outros',
      'description': 'Porta-chaves com boneco.',
      'date_lost': '2024-05-11',
      'status': 'lost',
    },
  ];

  static List<Map<String, dynamic>> foundItems = [
    {
      'id': '3',
      'title': 'Carteira de Pele',
      'category': 'Documentos',
      'description': 'Encontrada no parque.',
      'date_found': '2024-05-12',
      'status': 'found',
    },
  ];
}
