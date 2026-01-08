class TermsConditionsResponse {
  final Metadata metadata;
  final Header header;
  final List<Section> sections;
  final Footer footer;

  TermsConditionsResponse({
    required this.metadata,
    required this.header,
    required this.sections,
    required this.footer,
  });

  TermsConditionsResponse copyWith({
    Metadata? metadata,
    Header? header,
    List<Section>? sections,
    Footer? footer,
  }) =>
      TermsConditionsResponse(
        metadata: metadata ?? this.metadata,
        header: header ?? this.header,
        sections: sections ?? this.sections,
        footer: footer ?? this.footer,
      );

  factory TermsConditionsResponse.fromJson(Map<String, dynamic> json) =>
      TermsConditionsResponse(
        metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
        header: Header.fromJson(json['header'] as Map<String, dynamic>),
        sections: json['sections'] != null
            ? (json['sections'] as List)
            .map((item) => Section.fromJson(item as Map<String, dynamic>))
            .toList()
            : [],
        footer: Footer.fromJson(json['footer'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'header': header.toJson(),
    'sections': sections.map((item) => item.toJson()).toList(),
    'footer': footer.toJson(),
  };
}

class Footer {
  final String acceptanceText;

  Footer({required this.acceptanceText});

  Footer copyWith({String? acceptanceText}) =>
      Footer(acceptanceText: acceptanceText ?? this.acceptanceText);

  factory Footer.fromJson(Map<String, dynamic> json) =>
      Footer(acceptanceText: json['acceptanceText'] as String? ?? '');

  Map<String, dynamic> toJson() => {'acceptanceText': acceptanceText};
}

class Header {
  final String title;
  final String subtitle;

  Header({required this.title, required this.subtitle});

  Header copyWith({String? title, String? subtitle}) =>
      Header(title: title ?? this.title, subtitle: subtitle ?? this.subtitle);

  factory Header.fromJson(Map<String, dynamic> json) => Header(
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'title': title, 'subtitle': subtitle};
}

class Metadata {
  final String lastUpdated;
  final String version;
  final String language;
  final String company;
  final String companyAz;
  final String email;
  final String website;
  final String location;
  final String country;

  Metadata({
    required this.lastUpdated,
    required this.version,
    required this.language,
    required this.company,
    required this.companyAz,
    required this.email,
    required this.website,
    required this.location,
    required this.country,
  });

  Metadata copyWith({
    String? lastUpdated,
    String? version,
    String? language,
    String? company,
    String? companyAz,
    String? email,
    String? website,
    String? location,
    String? country,
  }) =>
      Metadata(
        lastUpdated: lastUpdated ?? this.lastUpdated,
        version: version ?? this.version,
        language: language ?? this.language,
        company: company ?? this.company,
        companyAz: companyAz ?? this.companyAz,
        email: email ?? this.email,
        website: website ?? this.website,
        location: location ?? this.location,
        country: country ?? this.country,
      );

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    lastUpdated: json['lastUpdated'] as String? ?? '',
    version: json['version'] as String? ?? '',
    language: json['language'] as String? ?? '',
    company: json['company'] as String? ?? '',
    companyAz: json['companyAz'] as String? ?? '',
    email: json['email'] as String? ?? '',
    website: json['website'] as String? ?? '',
    location: json['location'] as String? ?? '',
    country: json['country'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'lastUpdated': lastUpdated,
    'version': version,
    'language': language,
    'company': company,
    'companyAz': companyAz,
    'email': email,
    'website': website,
    'location': location,
    'country': country,
  };
}

class Section {
  final int id;
  final String title;
  final String content;
  final Contact? contact;

  Section({
    required this.id,
    required this.title,
    required this.content,
    this.contact,
  });

  Section copyWith({
    int? id,
    String? title,
    String? content,
    Contact? contact,
  }) =>
      Section(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        contact: contact ?? this.contact,
      );

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    contact: json['contact'] != null
        ? Contact.fromJson(json['contact'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'contact': contact?.toJson(),
  };
}

class Contact {
  final String companyEn;
  final String companyAz;
  final String email;
  final String website;
  final String location;

  Contact({
    required this.companyEn,
    required this.companyAz,
    required this.email,
    required this.website,
    required this.location,
  });

  Contact copyWith({
    String? companyEn,
    String? companyAz,
    String? email,
    String? website,
    String? location,
  }) =>
      Contact(
        companyEn: companyEn ?? this.companyEn,
        companyAz: companyAz ?? this.companyAz,
        email: email ?? this.email,
        website: website ?? this.website,
        location: location ?? this.location,
      );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    companyEn: json['companyEn'] as String? ?? '',
    companyAz: json['companyAz'] as String? ?? '',
    email: json['email'] as String? ?? '',
    website: json['website'] as String? ?? '',
    location: json['location'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'companyEn': companyEn,
    'companyAz': companyAz,
    'email': email,
    'website': website,
    'location': location,
  };
}