# Sysconfd

A system configuration daemon that generates configuration files based on templates and system information. It was specifically designed for Yocto-based Linux systems to configure services at boot time based on key-value stores.

## Purpose

This daemon is primarily intended for embedded Linux systems built with Yocto, where it helps to:
- Configure services during system boot
- Generate configuration files based on device-specific information
- Handle different hardware variants through templates
- Support key-value store based configuration (e.g., from device tree or other sources)

The daemon may contain specific code and assumptions, as it's designed to work within the Yocto ecosystem.

## Features

- Automatic generation of configuration files from templates
- Access to system information in templates:
  - Hardware information (board, vendor, etc.)
  - Network interface information (MAC addresses)
  - Environment variables
- Support for conditional template processing
- Systemd integration with watchdog support
- Integration with Yocto's device tree and system information

## Installation

The daemon is installed as a systemd service and starts automatically on system boot. In a Yocto-based system, it's typically included in the image through a custom layer.

## Configuration

Configuration is done through service definitions in the `/usr/lib/sysconfd/services` directory (or another configured directory). Each service requires its own subdirectory with at least a `config.json` file.

### Service Structure

```
/usr/lib/sysconfd/services/
└── my-service/
    ├── config.json
    └── templates/
        ├── template1.conf.eex
        └── template2.conf.eex
```

### Configuration File (config.json)

```json
{
  "templates": [
    {
      "template": "templates/template1.conf.eex",
      "target": "/etc/my-service/config1.conf",
      "condition": "sys[\"board_name\"] == \"MyBoard\"",
      "delete_missing": true
    }
  ],
  "data_sources": [
    {
      "key": "custom",
      "path": "data/custom.json",
      "type": "json"
    }
  ]
}
```

#### Template Configuration

- `template`: Path to the template file (relative to the service directory)
- `target`: Target path for the generated configuration file
- `condition`: Optional condition for template processing
- `delete_missing`: If `true`, the target file will be deleted if the condition is not met

#### Available Data in Templates

- `sys`: System information
  - `board_name`: Board name
  - `board_vendor`: Board vendor
  - `image_version`: System image version
- `net`: Network information
  - `interfaces`: Map with interface information (MAC addresses)
- `env`: Environment variables
- `data`: Custom data from data_sources

### Template Example

```elixir
# Configuration for <%= sys["board_name"] %>
# MAC: <%= net["interfaces"]["eth0"]["mac"] %>

<%= if sys["board_vendor"] == "MyVendor" do %>
  # Special configuration for MyVendor
<% end %>
```

## Data Source Types

- `json`: JSON files
- `env`: Environment variable files
- `text`: Simple text files

## Configuration Options

The daemon can be configured through environment variables:

- `SYSCONFD_SERVICES_DIR`: Directory for service configurations (default: `/usr/lib/sysconfd/services`)
- `SYSCONFD_SYSTEMD_ENABLED`: Enable systemd integration (default: `false`)
- `SYSCONFD_WATCHDOG_INTERVAL`: Watchdog interval in seconds (default: `15`)
- `SYSCONFD_LOG_LEVEL`: Log level (default: `info`)

## Yocto Integration

When building with Yocto:
- The daemon is typically included in a custom layer
- The daemon runs early in the boot process to configure services

## Logging

Logs are output through systemd-journald or stdout/stderr, depending on the runtime environment. 
