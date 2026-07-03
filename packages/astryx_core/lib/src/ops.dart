/// A declared argument for an operation.
class AstryxArg {
  const AstryxArg(this.name, {this.required = false, this.doc = ''});
  final String name;
  final bool required;
  final String doc;

  Map<String, Object?> toJson() => {
        'name': name,
        'required': required,
        if (doc.isNotEmpty) 'doc': doc,
      };
}

/// A single operation, exposed identically as a CLI command and an MCP tool.
/// Both surfaces derive from this list, so human and agent contracts stay in
/// lock-step by construction (asserted by a contract test).
class AstryxOp {
  const AstryxOp({
    required this.cli,
    required this.mcpTool,
    required this.summary,
    this.args = const [],
    this.responseShape = 'text',
  });

  /// CLI subcommand name (e.g. `component`).
  final String cli;

  /// MCP tool name (e.g. `astryx_get_component`).
  final String mcpTool;
  final String summary;
  final List<AstryxArg> args;

  /// Coarse response shape: 'text' | 'json' | 'code'.
  final String responseShape;

  Map<String, Object?> toJson() => {
        'cli': cli,
        'mcpTool': mcpTool,
        'summary': summary,
        'args': [for (final a in args) a.toJson()],
        'response': responseShape,
      };
}

/// The complete operation surface. Order is display order.
const List<AstryxOp> astryxOps = [
  AstryxOp(
    cli: 'list',
    mcpTool: 'astryx_list_components',
    summary: 'List all components with their category and status.',
    responseShape: 'json',
  ),
  AstryxOp(
    cli: 'component',
    mcpTool: 'astryx_get_component',
    summary: 'Show a component: description, props, a11y role, composition hints and a sample.',
    args: [AstryxArg('name', required: true, doc: 'Component name, e.g. AstryxButton (case-insensitive).')],
    responseShape: 'json',
  ),
  AstryxOp(
    cli: 'template',
    mcpTool: 'astryx_get_template',
    summary: 'Emit a full Flutter screen for a named template.',
    args: [AstryxArg('name', required: true, doc: 'Template name: dashboard | form | settings.')],
    responseShape: 'code',
  ),
  AstryxOp(
    cli: 'theme',
    mcpTool: 'astryx_theme',
    summary: 'List the built-in themes, or show one.',
    args: [AstryxArg('name', doc: 'Optional theme name; omit to list all.')],
    responseShape: 'json',
  ),
  AstryxOp(
    cli: 'swizzle',
    mcpTool: 'astryx_swizzle_component',
    summary: 'Plan ejecting a component: the files to copy and its token/foundation deps.',
    args: [AstryxArg('name', required: true, doc: 'Component to swizzle.')],
    responseShape: 'json',
  ),
  AstryxOp(
    cli: 'manifest',
    mcpTool: 'astryx_manifest',
    summary: 'The machine-readable contract: every command, argument and the full catalog.',
    responseShape: 'json',
  ),
];
