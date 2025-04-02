#!/bin/bash

# Create Grafana data source for Prometheus
cat > prometheus-datasource.json << 'EOL'
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://prometheus:9090",
  "access": "proxy",
  "isDefault": true
}
EOL

# Create Server Monitoring Dashboard
cat > server-dashboard.json << 'EOL'
{
  "dashboard": {
    "id": null,
    "title": "Server Monitoring",
    "tags": ["server", "kubernetes"],
    "timezone": "browser",
    "editable": true,
    "panels": [
      {
        "title": "CPU Usage (High Priority)",
        "type": "timeseries",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "color": "green", "value": null },
                { "color": "yellow", "value": 70 },
                { "color": "red", "value": 85 }
              ]
            }
          }
        }
      },
      {
        "title": "Memory Usage (High Priority)",
        "type": "timeseries",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "100 * (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes",
            "legendFormat": "Memory Usage",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "color": "green", "value": null },
                { "color": "yellow", "value": 70 },
                { "color": "red", "value": 85 }
              ]
            }
          }
        }
      },
      {
        "title": "System Load (High Priority)",
        "type": "timeseries",
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8},
        "targets": [
          {
            "expr": "node_load1",
            "legendFormat": "Load 1m",
            "refId": "A"
          },
          {
            "expr": "node_load5",
            "legendFormat": "Load 5m",
            "refId": "B"
          },
          {
            "expr": "node_load15",
            "legendFormat": "Load 15m",
            "refId": "C"
          }
        ]
      }
    ]
  },
  "overwrite": true
}
EOL

# Create Database Monitoring Dashboard
cat > database-dashboard.json << 'EOL'
{
  "dashboard": {
    "id": null,
    "title": "Database Monitoring",
    "tags": ["database", "rds"],
    "timezone": "browser",
    "editable": true,
    "panels": [
      {
        "title": "Database Connections (High Priority)",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "options": {
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto"
        },
        "targets": [
          {
            "expr": "pg_stat_activity_count",
            "legendFormat": "Active Connections",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Database Size (High Priority)",
        "type": "gauge",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "options": {
          "orientation": "auto",
          "showThresholdLabels": false,
          "showThresholdMarkers": true
        },
        "fieldConfig": {
          "defaults": {
            "unit": "decbytes",
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "color": "green", "value": null },
                { "color": "yellow", "value": 5000000000 },
                { "color": "red", "value": 10000000000 }
              ]
            }
          }
        },
        "targets": [
          {
            "expr": "pg_database_size_bytes{datname=\"postgres\"}",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Database Uptime (Medium Priority)",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        "options": {
          "colorMode": "value",
          "graphMode": "none",
          "justifyMode": "auto"
        },
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "type": "value",
                "options": {
                  "1": { "text": "Up", "color": "green" },
                  "0": { "text": "Down", "color": "red" }
                }
              }
            ]
          }
        },
        "targets": [
          {
            "expr": "up{job=\"rds\"}",
            "refId": "A"
          }
        ]
      }
    ]
  },
  "overwrite": true
}
EOL

# Create Status Page Overview
cat > status-overview-dashboard.json << 'EOL'
{
  "dashboard": {
    "id": null,
    "title": "Status Page Overview",
    "tags": ["overview", "status"],
    "timezone": "browser",
    "editable": true,
    "panels": [
      {
        "title": "Service Status",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "options": {
          "colorMode": "value",
          "graphMode": "none",
          "justifyMode": "auto",
          "text": {}
        },
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "type": "value",
                "options": {
                  "1": { "text": "Online", "color": "green" },
                  "0": { "text": "Offline", "color": "red" }
                }
              }
            ]
          }
        },
        "targets": [
          {
            "expr": "up{job=\"statuspage\"}",
            "legendFormat": "Status Page Service",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Database Status",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "options": {
          "colorMode": "value",
          "graphMode": "none",
          "justifyMode": "auto",
          "text": {}
        },
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "type": "value",
                "options": {
                  "1": { "text": "Online", "color": "green" },
                  "0": { "text": "Offline", "color": "red" }
                }
              }
            ]
          }
        },
        "targets": [
          {
            "expr": "up{job=\"rds\"}",
            "legendFormat": "Database Service",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Server Status",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        "options": {
          "colorMode": "value",
          "graphMode": "none",
          "justifyMode": "auto",
          "text": {}
        },
        "fieldConfig": {
          "defaults": {
            "mappings": [
              {
                "type": "value",
                "options": {
                  "1": { "text": "Online", "color": "green" },
                  "0": { "text": "Offline", "color": "red" }
                }
              }
            ]
          }
        },
        "targets": [
          {
            "expr": "up{job=\"kubernetes-nodes\"}",
            "legendFormat": "Server",
            "refId": "A"
          }
        ]
      },
      {
        "title": "Network Status",
        "type": "stat",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
        "options": {
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto"
        },
        "targets": [
          {
            "expr": "rate(node_network_receive_bytes_total[5m])",
            "legendFormat": "Network Throughput",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "bps",
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "color": "green", "value": null }
              ]
            }
          }
        }
      }
    ]
  },
  "overwrite": true
}
EOL

echo "Created dashboard configuration files. Use these to import dashboards in Grafana."
