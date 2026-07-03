/// Machine-readable metadata attached to each Astryx component. The J7 registry
/// generator (`tool/gen_registry.dart`) harvests these annotations **plus** the
/// constructor parameters (via the analyzer) into `registry.g.json`, the single
/// source of truth the CLI, MCP server, and `dart doc` all read. Props come from
/// the analyzer, so the registry can never drift from the real widget API.
class AstryxComponent {
  const AstryxComponent({
    required this.category,
    this.status = AstryxStatus.stable,
    this.a11yRole,
    this.composesWith = const [],
    this.slots = const [],
    this.sample,
  });

  /// Astryx category, e.g. 'Action', 'Data Input', 'Overlay'.
  final String category;
  final AstryxStatus status;

  /// The intended semantics role, e.g. 'button', 'checkbox'.
  final String? a11yRole;

  /// Component names this one commonly composes with (agent hint).
  final List<String> composesWith;

  /// Named structural builder slots the component exposes.
  final List<String> slots;

  /// A canonical usage snippet.
  final String? sample;
}

enum AstryxStatus { stable, beta, experimental }
