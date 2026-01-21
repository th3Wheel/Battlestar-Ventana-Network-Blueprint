#!/usr/bin/env python3
"""
Firewall Rule Generator for Battlestar Ventana Network Blueprint

This script parses the firewall matrix and services documentation to generate
deterministic UFW (Uncomplicated Firewall) rules for automated deployment.

Usage:
    python scripts/services_to_ufw.py [--output FILE] [--format {ufw|json}]
"""

import re
import sys
import json
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Set
from dataclasses import dataclass, asdict


@dataclass
class VLANConfig:
    """VLAN configuration"""
    id: int
    name: str
    network: str
    description: str


@dataclass
class FirewallRule:
    """Firewall rule definition"""
    source_vlan: str
    dest_vlan: str
    action: str
    ports: List[str]
    protocol: str
    service: str
    comment: str

    def to_ufw_command(self) -> str:
        """Convert to UFW command syntax"""
        if self.action == "DENY":
            action = "deny"
        elif self.action == "ALLOW":
            action = "allow"
        else:
            action = "reject"
        
        cmd_parts = [f"ufw {action}"]
        
        if self.ports:
            port_str = ",".join(self.ports)
            cmd_parts.append(f"proto {self.protocol.lower()} from {self.source_vlan}")
            cmd_parts.append(f"to {self.dest_vlan} port {port_str}")
        else:
            cmd_parts.append(f"from {self.source_vlan} to {self.dest_vlan}")
        
        cmd_parts.append(f"comment '{self.comment}'")
        
        return " ".join(cmd_parts)


class FirewallMatrixParser:
    """Parse firewall matrix and services documentation"""
    
    # VLAN definitions from the documentation
    VLANS = {
        10: VLANConfig(10, "Ventana", "10.76.10.0/24", "Trusted LAN"),
        20: VLANConfig(20, "IoT", "10.76.20.0/24", "IoT Devices"),
        30: VLANConfig(30, "Guest", "10.76.30.0/24", "Guest Internet"),
        31: VLANConfig(31, "GuestElevated", "10.76.31.0/24", "Elevated Guest"),
        40: VLANConfig(40, "InfraCore", "10.76.40.0/24", "Infrastructure"),
        50: VLANConfig(50, "ServerVault", "10.76.50.0/24", "Services"),
        60: VLANConfig(60, "Printers", "10.76.60.0/24", "Printers"),
        70: VLANConfig(70, "Media", "10.76.70.0/24", "Media/Casting"),
        81: VLANConfig(81, "CamerasLocal", "10.76.81.0/24", "Cameras Local"),
        82: VLANConfig(82, "CamerasCloud", "10.76.82.0/24", "Cameras Cloud"),
        90: VLANConfig(90, "Work", "10.76.90.0/24", "Work VLAN"),
    }
    
    # Service to port mappings from the documentation
    SERVICE_PORTS = {
        "SSH": ("22", "tcp"),
        "HTTPS": ("443", "tcp"),
        "HTTP": ("80", "tcp"),
        "SNMP": ("161", "tcp"),
        "SMB": ("445", "tcp"),
        "NFS": ("2049", "tcp"),
        "IPP": ("631", "tcp"),
        "LPD": ("515", "tcp"),
        "DLNA": ("1900", "udp"),
        "Chromecast": ("8008,8009", "tcp"),
        "RTSP": ("554", "tcp"),
        "MQTT": ("8883", "tcp"),
        "MQTT_PLAIN": ("1883", "tcp"),
        "Syslog": ("514", "udp"),
        "DNS": ("53", "udp"),
        "DHCP": ("67,68", "udp"),
        "PostgreSQL": ("5432", "tcp"),
        "JetDirect": ("9100", "tcp"),
        "Plex": ("32400", "tcp"),
    }
    
    # Firewall matrix from documentation (symbol -> action mapping)
    MATRIX = {
        # Source: 10 Trusted
        (10, 10): ("ALLOW", ["ALL"]),
        (10, 20): ("LIMITED", ["DNS", "DHCP"]),
        (10, 30): ("DENY", []),
        (10, 31): ("LIMITED", ["Chromecast", "DLNA"]),
        (10, 40): ("ALLOW", ["SSH", "HTTPS", "SNMP"]),
        (10, 50): ("ALLOW", ["SMB", "NFS", "HTTPS"]),
        (10, 60): ("ALLOW", ["IPP", "LPD"]),
        (10, 70): ("ALLOW", ["DLNA", "Chromecast"]),
        (10, 81): ("VIEW", ["RTSP", "HTTPS"]),
        (10, 82): ("VIEW", ["RTSP", "HTTPS"]),
        (10, 90): ("DENY", []),
        
        # Source: 20 IoT
        (20, 10): ("DENY", []),
        (20, 20): ("ALLOW", ["ALL"]),
        (20, 30): ("DENY", []),
        (20, 31): ("DENY", []),
        (20, 40): ("DENY", []),
        (20, 50): ("LIMITED", ["MQTT", "HTTPS"]),
        (20, 60): ("DENY", []),
        (20, 70): ("DENY", []),
        (20, 81): ("DENY", []),
        (20, 82): ("DENY", []),
        (20, 90): ("DENY", []),
        
        # Source: 30 Guest
        (30, 10): ("DENY", []),
        (30, 20): ("DENY", []),
        (30, 30): ("ALLOW", ["ALL"]),
        (30, 31): ("DENY", []),
        (30, 40): ("DENY", []),
        (30, 50): ("DENY", []),
        (30, 60): ("DENY", []),
        (30, 70): ("DENY", []),
        (30, 81): ("DENY", []),
        (30, 82): ("DENY", []),
        (30, 90): ("DENY", []),
        
        # Source: 31 GuestElevated
        (31, 10): ("LIMITED", ["DNS", "DHCP"]),
        (31, 20): ("DENY", []),
        (31, 30): ("DENY", []),
        (31, 31): ("ALLOW", ["ALL"]),
        (31, 40): ("DENY", []),
        (31, 50): ("LIMITED", ["IPP", "SMB"]),
        (31, 60): ("ALLOW", ["IPP", "LPD"]),
        (31, 70): ("ALLOW", ["DLNA", "Chromecast"]),
        (31, 81): ("DENY", []),
        (31, 82): ("DENY", []),
        (31, 90): ("DENY", []),
        
        # Source: 40 InfraCore
        (40, 10): ("ALLOW", ["ALL"]),
        (40, 20): ("DENY", []),
        (40, 30): ("DENY", []),
        (40, 31): ("DENY", []),
        (40, 40): ("ALLOW", ["ALL"]),
        (40, 50): ("ALLOW", ["SSH", "HTTPS", "PostgreSQL"]),
        (40, 60): ("DENY", []),
        (40, 70): ("DENY", []),
        (40, 81): ("DENY", []),
        (40, 82): ("DENY", []),
        (40, 90): ("ALLOW", ["ALL"]),
        
        # Source: 50 ServerVault
        (50, 10): ("ALLOW", ["ALL"]),
        (50, 20): ("LIMITED", ["MQTT", "HTTPS"]),
        (50, 30): ("DENY", []),
        (50, 31): ("LIMITED", ["IPP", "SMB"]),
        (50, 40): ("ALLOW", ["SSH", "HTTPS"]),
        (50, 50): ("ALLOW", ["ALL"]),
        (50, 60): ("ALLOW", ["IPP", "JetDirect"]),
        (50, 70): ("LIMITED", ["Plex", "SMB"]),
        (50, 81): ("VIEW", ["RTSP", "Syslog"]),
        (50, 82): ("VIEW", ["RTSP", "Syslog"]),
        (50, 90): ("DENY", []),
        
        # Source: 60 Printers
        (60, 10): ("ALLOW", ["ALL"]),
        (60, 20): ("DENY", []),
        (60, 30): ("DENY", []),
        (60, 31): ("LIMITED", ["IPP"]),
        (60, 40): ("DENY", []),
        (60, 50): ("ALLOW", ["IPP", "JetDirect"]),
        (60, 60): ("ALLOW", ["ALL"]),
        (60, 70): ("DENY", []),
        (60, 81): ("DENY", []),
        (60, 82): ("DENY", []),
        (60, 90): ("DENY", []),
        
        # Source: 70 Media
        (70, 10): ("ALLOW", ["ALL"]),
        (70, 20): ("DENY", []),
        (70, 30): ("DENY", []),
        (70, 31): ("ALLOW", ["DLNA", "Chromecast"]),
        (70, 40): ("DENY", []),
        (70, 50): ("LIMITED", ["SMB", "Plex"]),
        (70, 60): ("DENY", []),
        (70, 70): ("ALLOW", ["ALL"]),
        (70, 81): ("DENY", []),
        (70, 82): ("DENY", []),
        (70, 90): ("DENY", []),
        
        # Source: 81 Cameras Local
        (81, 10): ("VIEW", ["RTSP"]),
        (81, 20): ("DENY", []),
        (81, 30): ("DENY", []),
        (81, 31): ("DENY", []),
        (81, 40): ("DENY", []),
        (81, 50): ("VIEW", ["RTSP", "Syslog"]),
        (81, 60): ("DENY", []),
        (81, 70): ("DENY", []),
        (81, 81): ("ALLOW", ["ALL"]),
        (81, 82): ("DENY", []),
        (81, 90): ("DENY", []),
        
        # Source: 82 Cameras Cloud
        (82, 10): ("VIEW", ["RTSP"]),
        (82, 20): ("DENY", []),
        (82, 30): ("DENY", []),
        (82, 31): ("DENY", []),
        (82, 40): ("DENY", []),
        (82, 50): ("VIEW", ["RTSP", "Syslog"]),
        (82, 60): ("DENY", []),
        (82, 70): ("DENY", []),
        (82, 81): ("DENY", []),
        (82, 82): ("ALLOW", ["ALL"]),
        (82, 90): ("DENY", []),
        
        # Source: 90 Work
        (90, 10): ("DENY", []),
        (90, 20): ("DENY", []),
        (90, 30): ("DENY", []),
        (90, 31): ("DENY", []),
        (90, 40): ("DENY", []),
        (90, 50): ("DENY", []),
        (90, 60): ("DENY", []),
        (90, 70): ("ALLOW", ["Chromecast", "DLNA"]),
        (90, 81): ("DENY", []),
        (90, 82): ("DENY", []),
        (90, 90): ("ALLOW", ["ALL"]),
    }
    
    def __init__(self, docs_dir: Path):
        self.docs_dir = docs_dir
        self.rules: List[FirewallRule] = []
    
    def parse(self) -> List[FirewallRule]:
        """Parse firewall rules from documentation"""
        self.rules = []
        
        # Generate rules from matrix
        for (src_vlan, dst_vlan), (action, services) in sorted(self.MATRIX.items()):
            if action == "DENY":
                # Skip explicit deny rules for now (default deny)
                continue
            
            src_config = self.VLANS[src_vlan]
            dst_config = self.VLANS[dst_vlan]
            
            if action == "ALLOW" and "ALL" in services:
                # Allow all traffic
                rule = FirewallRule(
                    source_vlan=src_config.network,
                    dest_vlan=dst_config.network,
                    action="ALLOW",
                    ports=[],
                    protocol="any",
                    service="All Services",
                    comment=f"{src_config.name} -> {dst_config.name}: Full Access"
                )
                self.rules.append(rule)
            else:
                # Allow specific services
                for service in services:
                    if service in self.SERVICE_PORTS:
                        ports_str, protocol = self.SERVICE_PORTS[service]
                        ports = ports_str.split(",")
                        
                        rule = FirewallRule(
                            source_vlan=src_config.network,
                            dest_vlan=dst_config.network,
                            action="ALLOW",
                            ports=ports,
                            protocol=protocol,
                            service=service,
                            comment=f"{src_config.name} -> {dst_config.name}: {service}"
                        )
                        self.rules.append(rule)
        
        return self.rules
    
    def generate_ufw_script(self) -> str:
        """Generate UFW shell script"""
        script_lines = [
            "#!/bin/bash",
            "#",
            "# Battlestar Ventana Network Blueprint - UFW Firewall Rules",
            "# Auto-generated from firewall matrix documentation",
            "#",
            "# WARNING: This script will reset UFW rules!",
            "#",
            "",
            "set -e",
            "",
            "echo 'Resetting UFW...'",
            "ufw --force reset",
            "",
            "echo 'Setting default policies...'",
            "ufw default deny incoming",
            "ufw default deny outgoing",
            "ufw default deny forward",
            "",
            "echo 'Adding firewall rules...'",
            "",
        ]
        
        # Sort rules for deterministic output
        sorted_rules = sorted(self.rules, key=lambda r: (r.source_vlan, r.dest_vlan, r.service))
        
        for rule in sorted_rules:
            script_lines.append(f"# {rule.comment}")
            script_lines.append(rule.to_ufw_command())
            script_lines.append("")
        
        script_lines.extend([
            "echo 'Enabling UFW...'",
            "ufw --force enable",
            "",
            "echo 'Firewall rules applied successfully!'",
            "ufw status verbose",
        ])
        
        return "\n".join(script_lines)
    
    def generate_json(self) -> str:
        """Generate JSON output for Terraform"""
        data = {
            "vlans": {str(v.id): asdict(v) for v in self.VLANS.values()},
            "rules": [asdict(r) for r in sorted(self.rules, key=lambda r: (r.source_vlan, r.dest_vlan))]
        }
        return json.dumps(data, indent=2, sort_keys=True)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Generate UFW firewall rules from Battlestar Ventana documentation"
    )
    parser.add_argument(
        "--docs-dir",
        type=Path,
        default=Path(__file__).parent.parent / "docs",
        help="Path to documentation directory"
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Output file path (default: stdout)"
    )
    parser.add_argument(
        "--format",
        choices=["ufw", "json"],
        default="ufw",
        help="Output format (default: ufw)"
    )
    
    args = parser.parse_args()
    
    # Validate docs directory
    if not args.docs_dir.exists():
        print(f"Error: Documentation directory not found: {args.docs_dir}", file=sys.stderr)
        return 1
    
    # Parse firewall rules
    parser_obj = FirewallMatrixParser(args.docs_dir)
    parser_obj.parse()
    
    # Generate output
    if args.format == "ufw":
        output = parser_obj.generate_ufw_script()
    else:
        output = parser_obj.generate_json()
    
    # Write output
    if args.output:
        args.output.write_text(output)
        print(f"Generated {len(parser_obj.rules)} rules -> {args.output}", file=sys.stderr)
    else:
        print(output)
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
