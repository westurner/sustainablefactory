# CLI Reference

The `sfcli` tool allows you to interact with the factory process data.

## Commands

### `parse`
Parses a MyST markdown file and prints discovered processes.
```bash
sfcli parse paper.md
```

### `batch-export`
Processes a directory of chat logs or papers and generates a unified RDF-star graph.
```bash
sfcli batch-export ./data/chats -o all_processes.ttl
```

### `info`
Displays tool version information.
```bash
sfcli info
```
