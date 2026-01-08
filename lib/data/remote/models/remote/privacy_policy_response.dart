class PolicyResponse {
  final Metadata metadata;
  final Header header;
  final List<Section> sections;
  final HighlightedBox? highlightedBox;
  final ContactSection? contactSection;
  final Footer footer;

  PolicyResponse({
    required this.metadata,
    required this.header,
    required this.sections,
    this.highlightedBox,
    this.contactSection,
    required this.footer,
  });

  PolicyResponse copyWith({
    Metadata? metadata,
    Header? header,
    List<Section>? sections,
    HighlightedBox? highlightedBox,
    ContactSection? contactSection,
    Footer? footer,
  }) =>
      PolicyResponse(
        metadata: metadata ?? this.metadata,
        header: header ?? this.header,
        sections: sections ?? this.sections,
        highlightedBox: highlightedBox ?? this.highlightedBox,
        contactSection: contactSection ?? this.contactSection,
        footer: footer ?? this.footer,
      );

  factory PolicyResponse.fromJson(Map<String, dynamic> json) => PolicyResponse(
    metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    header: Header.fromJson(json['header'] as Map<String, dynamic>),
    sections: json['sections'] != null
        ? (json['sections'] as List)
        .map((item) => Section.fromJson(item as Map<String, dynamic>))
        .toList()
        : [],
    highlightedBox: json['highlightedBox'] != null
        ? HighlightedBox.fromJson(
        json['highlightedBox'] as Map<String, dynamic>)
        : null,
    contactSection: json['contactSection'] != null
        ? ContactSection.fromJson(
        json['contactSection'] as Map<String, dynamic>)
        : null,
    footer: Footer.fromJson(json['footer'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'header': header.toJson(),
    'sections': sections.map((item) => item.toJson()).toList(),
    'highlightedBox': highlightedBox?.toJson(),
    'contactSection': contactSection?.toJson(),
    'footer': footer.toJson(),
  };
}

class ContactSection {
  final int id;
  final String title;
  final String subtitle;
  final String company;
  final String companyAz;
  final String email;
  final String website;
  final String location;
  final String responseNote;

  ContactSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.company,
    required this.companyAz,
    required this.email,
    required this.website,
    required this.location,
    required this.responseNote,
  });

  ContactSection copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? company,
    String? companyAz,
    String? email,
    String? website,
    String? location,
    String? responseNote,
  }) =>
      ContactSection(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        company: company ?? this.company,
        companyAz: companyAz ?? this.companyAz,
        email: email ?? this.email,
        website: website ?? this.website,
        location: location ?? this.location,
        responseNote: responseNote ?? this.responseNote,
      );

  factory ContactSection.fromJson(Map<String, dynamic> json) => ContactSection(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    company: json['company'] as String? ?? '',
    companyAz: json['companyAz'] as String? ?? '',
    email: json['email'] as String? ?? '',
    website: json['website'] as String? ?? '',
    location: json['location'] as String? ?? '',
    responseNote: json['responseNote'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'company': company,
    'companyAz': companyAz,
    'email': email,
    'website': website,
    'location': location,
    'responseNote': responseNote,
  };
}

class Footer {
  final String consentText;

  Footer({required this.consentText});

  Footer copyWith({String? consentText}) =>
      Footer(consentText: consentText ?? this.consentText);

  factory Footer.fromJson(Map<String, dynamic> json) =>
      Footer(consentText: json['consentText'] as String? ?? '');

  Map<String, dynamic> toJson() => {'consentText': consentText};
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

class HighlightedBox {
  final String id;
  final String title;
  final String content;
  final String icon;

  HighlightedBox({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
  });

  HighlightedBox copyWith({
    String? id,
    String? title,
    String? content,
    String? icon,
  }) =>
      HighlightedBox(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        icon: icon ?? this.icon,
      );

  factory HighlightedBox.fromJson(Map<String, dynamic> json) => HighlightedBox(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
  );

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'content': content, 'icon': icon};
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
  final String responseTime;

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
    required this.responseTime,
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
    String? responseTime,
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
        responseTime: responseTime ?? this.responseTime,
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
    responseTime: json['responseTime'] as String? ?? '',
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
    'responseTime': responseTime,
  };
}

class Section {
  final int id;
  final String title;
  final String content;
  final String icon;
  final bool highlighted;
  final List<DataRight> dataRights;

  Section({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.highlighted,
    required this.dataRights,
  });

  Section copyWith({
    int? id,
    String? title,
    String? content,
    String? icon,
    bool? highlighted,
    List<DataRight>? dataRights,
  }) =>
      Section(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        icon: icon ?? this.icon,
        highlighted: highlighted ?? this.highlighted,
        dataRights: dataRights ?? this.dataRights,
      );

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json['id'] as int? ?? 0,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
    highlighted: json['highlighted'] as bool? ?? false,
    dataRights: json['dataRights'] != null
        ? (json['dataRights'] as List)
        .map((item) => DataRight.fromJson(item as Map<String, dynamic>))
        .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'icon': icon,
    'highlighted': highlighted,
    'dataRights': dataRights.map((item) => item.toJson()).toList(),
  };
}

class DataRight {
  final String icon;
  final String title;
  final String description;

  DataRight({
    required this.icon,
    required this.title,
    required this.description,
  });

  DataRight copyWith({String? icon, String? title, String? description}) =>
      DataRight(
        icon: icon ?? this.icon,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  factory DataRight.fromJson(Map<String, dynamic> json) => DataRight(
    icon: json['icon'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );

  Map<String, dynamic> toJson() =>
      {'icon': icon, 'title': title, 'description': description};
}