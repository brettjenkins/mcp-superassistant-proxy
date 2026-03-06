# MCP SuperAssistant Proxy (brettjenkins fork)

> **Fork of [leeroybrun/mcp-superassistant-proxy](https://github.com/leeroybrun/mcp-superassistant-proxy)**
>
> This fork makes two changes to the original:
>
> **1. Fix tool name dots** — The original uses `serverName.toolName` as the composite tool name (e.g. `github-brettjenkins.create_issue`). Many MCP clients, including claude.ai, only allow `[a-zA-Z0-9_-]` in tool names and reject dots. This fork replaces the dot separator with an underscore using a registry map for unambiguous reverse lookup on `tools/call`, so `github-brettjenkins.create_issue` becomes `github-brettjenkins_create_issue`.
>
> **2. Docker image** — A `Dockerfile` and GitHub Actions workflow are included to build and publish the image to GHCR (`ghcr.io/brettjenkins/mcp-superassistant-proxy`), making it easy to self-host as a Kubernetes deployment without relying on `npx` at runtime.
>
> A PR has been raised against the upstream repo. In the meantime this fork is used in production.

---

A **bulletproof proxy server** for MCP (Model Context Protocol) that aggregates multiple MCP servers with comprehensive memory leak prevention and reliable HTTP/SSE transport. Perfect for Chrome extensions and web applications.

**🚀 Features:**
- **🛡️ Memory-Safe** - Comprehensive memory leak prevention and automatic cleanup
- **⚡ Bulletproof** - Robust error handling and resource management
- **🌐 Multi-Transport** - HTTP and SSE support for maximum compatibility
- **🔧 Cross-Platform** - Works on macOS, Linux, and Windows
- **📊 Data Flow Optimization** - Data passes through without being cached in memory
- **🎯 Chrome Extension Ready** - Optimized for browser extension communication

## Installation & Usage

### Quick Start

```bash
# Install globally for easy access
npm install -g @leeroy/mcp-superassistant-proxy

# Or run directly with npx
npx -y @leeroy/mcp-superassistant-proxy@latest --config config.json --port 3006
```

### Recommended Setup

```bash
# Create config directory
mkdir -p ~/.mcp-superassistant

# Create your config file
echo '{"mcpServers": {}}' > ~/.mcp-superassistant/config.json

# Run the proxy
mcp-superassistant-proxy --config ~/.mcp-superassistant/config.json --port 3006
```

### CLI Options

- `--config, -c <path>`: **(required)** Path to a JSON configuration file (see below)
- `--port <number>`: Port to run the HTTP server on (default: `3006`)
- `--logLevel <info|none>`: Set logging level (default: `info`)
- `--timeout <ms>`: Connection timeout in milliseconds (default: `30000`)

### Available Endpoints

When running, the proxy exposes:
- **Modern HTTP**: `http://localhost:<port>/mcp` - Streamable HTTP transport (recommended)
- **Legacy SSE**: `http://localhost:<port>/sse` - Server-Sent Events transport
- **Health Check**: `http://localhost:<port>/health` - Returns server status

## Configuration File

The configuration file is a JSON file specifying which MCP servers to connect to. Each server can be either a stdio-based server (run as a subprocess) or a remote HTTP/SSE server.

### Example `config.json`

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
      "env": {}
    },
    "notion": {
      "command": "npx",
      "args": ["-y", "@suekou/mcp-notion-server"],
      "env": {
        "NOTION_API_TOKEN": "<your_notion_token_here>"
      }
    },
    "remote-server": {
      "url": "https://your-remote-mcp-server.com/mcp"
    },
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander"]
    }
  }
}
```

### Configuration Options

- **For stdio servers**: Use `command`, `args`, and optionally `env`
- **For remote servers**: Use `url` pointing to the MCP endpoint
- Each key under `mcpServers` is a unique name for the server

## Memory Safety & Reliability

This proxy is designed to be **bulletproof** with comprehensive memory leak prevention:

### 🛡️ Memory Management
- **Automatic session cleanup** - Stale sessions cleaned every 2 minutes
- **Data flow optimization** - Data passes through without being cached in memory
- **Resource tracking** - All intervals, timeouts, and connections tracked
- **Graceful shutdown** - Complete cleanup on exit
- **Reference clearing** - Explicit garbage collection hints

### ⚡ Reliability Features
- **Connection stability** - Robust error handling and recovery
- **Timeout protection** - All operations have timeouts to prevent hanging
- **Transport fallback** - Automatic fallback from modern to legacy transports
- **Process monitoring** - Automatic cleanup of disconnected child processes
- **Error boundaries** - Isolated error handling prevents cascading failures

### 📊 Data Flow Optimization
- **Zero data caching** - Large data objects pass through without being stored
- **Immediate cleanup** - References cleared immediately after data transfer
- **Memory monitoring** - Proactive memory leak prevention
- **Performance tracking** - Built-in performance monitoring

## Transport Compatibility

The proxy provides **automatic backwards compatibility** between different MCP transport versions:

### Client-Side Compatibility
- **Modern clients** → Connect to `/mcp` for Streamable HTTP transport
- **Legacy clients** → Connect to `/sse` for Server-Sent Events transport
- **Automatic fallback** → Clients can try modern first, fall back to legacy

### Server-Side Compatibility
- **Remote HTTP servers** → Tries Streamable HTTP first, falls back to SSE
- **Stdio servers** → Native subprocess communication
- **Mixed environments** → Seamlessly handles different server types

## Quick Example

1. **Create a config file**:
   ```bash
   mkdir -p ~/.mcp-superassistant
   cat > ~/.mcp-superassistant/config.json << 'EOF'
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
       }
     }
   }
   EOF
   ```

2. **Run the proxy**:
   ```bash
   npx -y @leeroy/mcp-superassistant-proxy@latest --config ~/.mcp-superassistant/config.json --port 3006
   ```

3. **Connect your client** to `http://localhost:3006/mcp`

## Why MCP?

[Model Context Protocol](https://spec.modelcontextprotocol.io/) standardizes how AI tools exchange data. This proxy allows you to:

- **Aggregate multiple MCP servers** behind a single endpoint
- **Bridge different transports** (stdio ↔ HTTP/SSE)
- **Ensure reliability** with bulletproof memory management
- **Scale safely** with built-in monitoring and limits

## Advanced Features

### Automatic Protocol Detection
- **JSON-RPC version** automatically derived from requests
- **Transport negotiation** between client and server
- **Backwards compatibility** maintained across MCP versions

### Production Ready
- **Memory leak prevention** - Comprehensive resource management
- **Error isolation** - Failures don't cascade between servers
- **Performance monitoring** - Built-in metrics and logging
- **Graceful degradation** - Continues working when individual servers fail

### Chrome Extension Optimized
- **Content script proxy pattern** - Reliable browser networking
- **Zero data retention** - Large data flows through without caching
- **Timeout handling** - No hanging requests
- **Reference cleanup** - Explicit garbage collection

---

## Version History

### v0.1.0 - Memory Safety Release
- ✅ **Comprehensive memory leak fixes**
- ✅ **WebSocket removal** (HTTP/SSE only)
- ✅ **Data flow optimization** - No data caching/retention
- ✅ **Bulletproof resource management**
- ✅ **Chrome extension reliability improvements**

---

For more details, see the [Model Context Protocol documentation](https://modelcontextprotocol.io/).

