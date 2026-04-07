# sources.json Schema

The `.vault/sources.json` file tracks which research MCP servers are configured for this vault. It is created by `vault init` (empty) and populated by `/knowledge-vault:setup-sources`.

## Schema

```json
{
  "version": 1,
  "configured_sources": [
    {
      "id": "string — unique server identifier (e.g., 'pubmed-builtin', 'consensus', 'arxiv-mcp-server')",
      "name": "string — human-readable name (e.g., 'PubMed (Claude.ai)')",
      "type": "string — 'builtin' | 'stdio' | 'http'",
      "enabled": "boolean — true if active, false if disabled",
      "tools": ["string — MCP tool names exposed by this server (e.g., 'mcp__pubmed__search_articles')"],
      "add_command": "string | null — the claude mcp add command used (null for builtins)",
      "added": "string — ISO 8601 UTC timestamp when configured"
    }
  ],
  "last_configured": "string | null — ISO 8601 UTC timestamp of last setup-sources run"
}
```

## Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique server identifier |
| `name` | string | yes | Human-readable display name |
| `type` | string | yes | `"builtin"`, `"stdio"`, or `"http"` |
| `enabled` | boolean | yes | `true` = active, `false` = disabled by user |
| `tools` | string[] | yes | MCP tool names this server exposes |
| `add_command` | string/null | yes | The `claude mcp add` command used (`null` for builtins) |
| `added` | string | yes | ISO 8601 UTC timestamp when configured |

## Example

```json
{
  "version": 1,
  "configured_sources": [
    {
      "id": "pubmed-builtin",
      "name": "PubMed (Claude.ai)",
      "type": "builtin",
      "enabled": true,
      "tools": ["mcp__claude_ai_PubMed__search_articles", "mcp__claude_ai_PubMed__get_article_metadata"],
      "add_command": null,
      "added": "2026-04-03T14:00:00Z"
    },
    {
      "id": "scholar-gateway",
      "name": "Scholar Gateway (Claude.ai)",
      "type": "builtin",
      "enabled": true,
      "tools": ["mcp__claude_ai_Scholar_Gateway__semanticSearch"],
      "add_command": null,
      "added": "2026-04-03T14:00:00Z"
    },
    {
      "id": "consensus",
      "name": "Consensus",
      "type": "http",
      "enabled": true,
      "tools": ["mcp__consensus__search"],
      "add_command": "claude mcp add --transport http consensus https://mcp.consensus.app/mcp",
      "added": "2026-04-03T14:05:00Z"
    },
    {
      "id": "arxiv-mcp-server",
      "name": "arXiv",
      "type": "stdio",
      "enabled": true,
      "tools": ["mcp__arxiv-mcp-server__search_papers"],
      "add_command": "claude mcp add arxiv-mcp-server -- uvx arxiv-mcp-server --storage-path .vault/raw/arxiv-papers",
      "added": "2026-04-03T14:05:00Z"
    }
  ],
  "last_configured": "2026-04-03T14:05:00Z"
}
```

## Empty State

Created by `vault init`:

```json
{
  "version": 1,
  "configured_sources": [],
  "last_configured": null
}
```

## Enabled Values

| Value | Meaning |
|-------|---------|
| `true` | Server is configured and available for use |
| `false` | Server was configured but has been disabled by user |

To check if a server is responding, scripts should attempt to call one of its `tools` and handle errors. The `enabled` field reflects user intent, not runtime availability.

## Usage

- **Read by**: `/knowledge-vault:collect` (to know which servers to search), `/knowledge-vault:setup-sources` (to show current state), `detect-mcp-sources.sh` (to compare detected vs configured), `vault-status.sh` (filters on `enabled`)
- **Written by**: `/knowledge-vault:setup-sources` (after user approves server additions)
- **Location**: `.vault/sources.json` (project-scoped, not global)
