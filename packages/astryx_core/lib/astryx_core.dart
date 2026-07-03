/// Shared Astryx tooling core. Defines the component registry (the single
/// source of truth), the operation surface, the manifest builder, and the
/// template/swizzle services consumed identically by the CLI and the MCP server.
library astryx_core;

export 'src/model.dart';
export 'src/ops.dart';
export 'src/registry.dart' show astryxRegistry;
export 'src/services.dart';
export 'src/templates.dart';
