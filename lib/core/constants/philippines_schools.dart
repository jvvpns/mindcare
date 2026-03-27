class PhilippineSchool {
  final String name;
  final String logoUrl;
  final String id;

  const PhilippineSchool({
    required this.name,
    required this.logoUrl,
    required this.id,
  });
}

class AppSchools {
  AppSchools._();

  static const List<PhilippineSchool> capizNursingSchools = [
    PhilippineSchool(
      id: 'fcu',
      name: 'Filamer Christian University (FCU)',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/en/b/b3/Filamer_Christian_University_logo.png', // Fallback URL, assuming standard wiki presence or local asset
    ),
    PhilippineSchool(
      id: 'capsu',
      name: 'Capiz State University (CapSU)',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e4/Capiz_State_University_logo.png',
    ),
    PhilippineSchool(
      id: 'cpc',
      name: 'Colegio dela Purisima Concepcion (CPC)',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/4b/Colegio_de_la_Purisima_Concepcion.png',
    ),
    PhilippineSchool(
      id: 'sacri',
      name: 'St. Anthony College of Roxas City (SACRI)',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/en/a/ad/St._Anthony_College_of_Roxas_City_logo.png',
    ),
  ];

  static const List<String> yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];
}
