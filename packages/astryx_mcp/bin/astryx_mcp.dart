import 'dart:convert';
import 'dart:io';

import 'package:astryx_mcp/src/server.dart';

/// Astryx MCP server over stdio. Reads newline-delimited JSON-RPC requests on
/// stdin and writes responses on stdout (the MCP stdio transport). Shares
/// astryx_core with the CLI, so the agent and human surfaces stay in lock-step.
Future<void> main(List<String> args) async {
  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  await for (final line in lines) {
    if (line.trim().isEmpty) continue;
    Map<String, Object?> request;
    try {
      request = (jsonDecode(line) as Map).cast<String, Object?>();
    } catch (_) {
      continue; // ignore malformed input
    }
    final response = handleMcp(request);
    if (response != null) {
      stdout.writeln(jsonEncode(response));
    }
  }
}
