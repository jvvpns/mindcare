class PhilippineSchool {
  final String name;
  final String logoUrl;
  final String id;
  final String affiliatedHospital;
  final String supportContact;

  const PhilippineSchool({
    required this.name,
    required this.logoUrl,
    required this.id,
    required this.affiliatedHospital,
    required this.supportContact,
  });
}

class AppSchools {
  AppSchools._();

  static const List<PhilippineSchool> capizNursingSchools = [
    PhilippineSchool(
      id: 'fcu',
      name: 'Filamer Christian University, Inc.',
      logoUrl: 'assets/images/schools/fcu.png',
      affiliatedHospital: 'Capiz Emmanuel Hospital',
      supportContact: 'College of Nursing Office',
    ),
    PhilippineSchool(
      id: 'uph',
      name: 'University of Perpetual Help System Pueblo de Panay Campus',
      logoUrl: 'assets/images/schools/uph.jpeg',
      affiliatedHospital: 'UPH Designated Clinical Hospital',
      supportContact: 'Guidance and Counseling Center',
    ),
    PhilippineSchool(
      id: 'sacri',
      name: 'St. Anthony College of Roxas City, Inc.',
      logoUrl: 'assets/images/schools/sacri.PNG',
      affiliatedHospital: 'St. Anthony College Hospital',
      supportContact: 'Student Affairs Office',
    ),
    PhilippineSchool(
      id: 'csj',
      name: 'College of St. John - Roxas',
      logoUrl: 'assets/images/schools/csj.jpeg',
      affiliatedHospital: 'CSJ Designated Clinical Partner',
      supportContact: 'Student Support Services',
    ),
  ];

  static const List<String> yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];
}
