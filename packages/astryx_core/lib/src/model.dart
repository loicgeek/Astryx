/// Machine-readable documentation for a single component prop.
class AstryxProp {
  const AstryxProp(
    this.name,
    this.type, {
    this.required = false,
    this.defaultValue,
    this.doc = '',
  });

  final String name;
  final String type;
  final bool required;
  final String? defaultValue;
  final String doc;

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type,
        'required': required,
        if (defaultValue != null) 'default': defaultValue,
        if (doc.isNotEmpty) 'doc': doc,
      };
}

/// The stability of a component's API.
enum AstryxStatus { stable, beta, experimental }

/// Machine-readable documentation for a component. This is the unit of the
/// registry that the CLI, the MCP server, and `dart doc` all read — so agents
/// and humans work from the exact same contract.
class AstryxComponentDoc {
  const AstryxComponentDoc({
    required this.name,
    required this.category,
    required this.description,
    required this.props,
    required this.sample,
    this.status = AstryxStatus.beta,
    this.a11yRole,
    this.composesWith = const [],
    this.slots = const [],
  });

  final String name;
  final String category;
  final String description;
  final List<AstryxProp> props;

  /// A canonical, copy-pasteable usage snippet.
  final String sample;
  final AstryxStatus status;

  /// The intended a11y semantics role, e.g. 'button', 'checkbox'.
  final String? a11yRole;

  /// Components this one commonly composes with (agent hint).
  final List<String> composesWith;

  /// Named structural builder slots the component exposes.
  final List<String> slots;

  Map<String, Object?> toJson() => {
        'name': name,
        'category': category,
        'status': status.name,
        'description': description,
        if (a11yRole != null) 'a11yRole': a11yRole,
        'props': [for (final p in props) p.toJson()],
        if (composesWith.isNotEmpty) 'composesWith': composesWith,
        if (slots.isNotEmpty) 'slots': slots,
        'sample': sample,
      };
}
