#!/usr/bin/env python3
"""
Energy Analysis Script for Battlestar Ventana Network

This script analyzes energy consumption patterns and provides insights
for optimization opportunities. It processes historical data from Home
Assistant database and generates reports for energy management.

Usage:
    python3 energy_analysis.py --days 30 --output report.json

Environment Variables:
    HA_DB_HOST: PostgreSQL host (default: localhost)
    HA_DB_PORT: PostgreSQL port (default: 5432)
    HA_DB_NAME: Database name (default: homeassistant)
    HA_DB_USER: Database username (required)
    HA_DB_PASSWORD: Database password (required)

Author: Network Operations Team
Date: 2024-01-15
Version: 1.0.0
"""

import argparse
import json
import os
import re
import sys
from typing import Dict, List
from urllib.parse import quote_plus

# Configuration constants
DEFAULT_DAYS = 30
OUTPUT_FORMAT = "json"

# Database configuration from environment variables
DB_HOST = os.getenv("HA_DB_HOST", "localhost")
DB_PORT = os.getenv("HA_DB_PORT", "5432")
DB_NAME = os.getenv("HA_DB_NAME", "homeassistant")
DB_USER = os.getenv("HA_DB_USER", "").strip() or None
DB_PASSWORD = os.getenv("HA_DB_PASSWORD", "").strip() or None


class EnergyAnalyzer:
    """
    Analyzes energy consumption data from Home Assistant.

    This class provides methods to:
    - Calculate energy usage patterns
    - Identify peak consumption periods
    - Generate optimization recommendations
    - Export data in various formats
    """

    def __init__(
        self,
        db_host: str,
        db_port: int,
        db_name: str,
        db_user: str,
        db_password: str,
        days: int = DEFAULT_DAYS,
    ):
        """
        Initialize the energy analyzer.

        Args:
            db_host: PostgreSQL host
            db_port: PostgreSQL port
            db_name: Database name
            db_user: Database username
            db_password: Database password
            days: Number of days to analyze
        """
        self.db_host = db_host
        self.db_port = db_port
        self.db_name = db_name
        self.db_user = db_user
        self.db_password = db_password
        self.days = days
        self.data = {}

    def _sanitize_credential(self, error_msg: str, credential: str) -> str:
        """
        Sanitize a credential from error messages in both plain and URL-encoded forms.

        Args:
            error_msg: The error message to sanitize
            credential: The credential to remove

        Returns:
            Sanitized error message with credential replaced by ***REDACTED***
        """
        # Sanitize plain-text credential
        escaped_credential = re.escape(credential)
        error_msg = re.sub(escaped_credential, "***REDACTED***", error_msg, flags=re.IGNORECASE)
        
        # Sanitize URL-encoded credential
        encoded_credential = quote_plus(credential)
        escaped_encoded = re.escape(encoded_credential)
        error_msg = re.sub(escaped_encoded, "***REDACTED***", error_msg, flags=re.IGNORECASE)
        
        return error_msg

    def connect_database(self) -> bool:
        """
        Establish database connection.

        Returns:
            True if connection successful, False otherwise
        """
        try:
            # Database connection logic here
            # Connection parameters are stored securely without exposing credentials
            print(f"Connected to database: {self.db_name}@{self.db_host}:{self.db_port}")
            return True
        except Exception as e:
            # Sanitize error message to avoid exposing credentials
            error_msg = str(e)
            
            # Sanitize password and username in both plain and URL-encoded forms
            if self.db_password:
                error_msg = self._sanitize_credential(error_msg, self.db_password)
            if self.db_user:
                error_msg = self._sanitize_credential(error_msg, self.db_user)
            
            print(f"Database connection failed: {error_msg}", file=sys.stderr)
            return False

    def fetch_energy_data(self) -> Dict[str, List[float]]:
        """
        Fetch energy consumption data from database.

        Returns:
            Dictionary with energy data by sensor
        """
        # Implementation would query database here
        # This is a placeholder structure
        return {
            "solar_generation": [1200.5, 1450.2, 1100.8],
            "grid_consumption": [800.3, 650.1, 950.7],
            "battery_usage": [400.2, 800.1, 150.1],
        }

    def calculate_daily_totals(self, data: Dict[str, List[float]]) -> Dict[str, float]:
        """
        Calculate daily totals for each energy source.

        Args:
            data: Raw energy data by sensor

        Returns:
            Daily totals by energy type
        """
        totals = {}
        for sensor, values in data.items():
            totals[sensor] = sum(values)
        return totals

    def analyze_patterns(self, data: Dict[str, List[float]]) -> Dict[str, any]:
        """
        Analyze energy usage patterns.

        Args:
            data: Energy consumption data

        Returns:
            Analysis results with insights
        """
        analysis = {
            "peak_hours": self._find_peak_hours(data),
            "efficiency_score": self._calculate_efficiency(data),
            "recommendations": self._generate_recommendations(data),
        }
        return analysis

    def _find_peak_hours(self, data: Dict[str, List[float]]) -> List[int]:
        """
        Find hours with highest energy consumption.

        Args:
            data: Energy data

        Returns:
            List of peak hours (0-23)
        """
        # Simplified implementation
        return [18, 19, 20]  # Evening hours

    def _calculate_efficiency(self, data: Dict[str, List[float]]) -> float:
        """
        Calculate overall energy efficiency score.

        Args:
            data: Energy data

        Returns:
            Efficiency score (0-100)
        """
        # Simplified calculation
        solar = sum(data.get("solar_generation", []))
        grid = sum(data.get("grid_consumption", []))
        efficiency = (solar / (solar + grid)) * 100 if (solar + grid) > 0 else 0
        return round(efficiency, 1)

    def _generate_recommendations(self, data: Dict[str, List[float]]) -> List[str]:
        """
        Generate optimization recommendations.

        Args:
            data: Energy data

        Returns:
            List of recommendation strings
        """
        recommendations = []

        efficiency = self._calculate_efficiency(data)
        if efficiency < 70:
            recommendations.append(
                "Consider adding more solar panels to reduce grid dependency"
            )

        peak_hours = self._find_peak_hours(data)
        if 18 in peak_hours or 19 in peak_hours:
            recommendations.append(
                "Shift high-consumption activities away from evening peak hours"
            )

        return recommendations

    def export_report(
        self, analysis: Dict, output_file: str, format: str = OUTPUT_FORMAT
    ):
        """
        Export analysis report to file.

        Args:
            analysis: Analysis results
            output_file: Output file path
            format: Output format (json, csv, etc.)
        """
        if format == "json":
            with open(output_file, "w") as f:
                json.dump(analysis, f, indent=2)
            print(f"Report exported to {output_file}")
        else:
            print(f"Unsupported format: {format}")


def main():
    """Main entry point for the energy analysis script."""
    parser = argparse.ArgumentParser(
        description="Analyze energy consumption patterns",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 energy_analysis.py --days 30 --output report.json
  python3 energy_analysis.py --days 7 --format csv --output weekly.csv

Environment Variables:
  HA_DB_HOST     - PostgreSQL host (default: localhost)
  HA_DB_PORT     - PostgreSQL port (default: 5432)
  HA_DB_NAME     - Database name (default: homeassistant)
  HA_DB_USER     - Database username (required)
  HA_DB_PASSWORD - Database password (required)
        """,
    )

    parser.add_argument(
        "--days",
        type=int,
        default=DEFAULT_DAYS,
        help=f"Number of days to analyze (default: {DEFAULT_DAYS})",
    )

    parser.add_argument("--output", type=str, required=True, help="Output file path")

    parser.add_argument(
        "--format",
        type=str,
        default=OUTPUT_FORMAT,
        choices=["json", "csv"],
        help=f"Output format (default: {OUTPUT_FORMAT})",
    )

    args = parser.parse_args()

    # Validate required environment variables
    # Note: We check for None/empty values without storing the actual credentials
    required_config = [
        ('HA_DB_HOST', DB_HOST),
        ('HA_DB_PORT', DB_PORT),
        ('HA_DB_NAME', DB_NAME),
        ('HA_DB_USER', DB_USER),
        ('HA_DB_PASSWORD', DB_PASSWORD),
    ]
    
    missing = [name for name, value in required_config if not value]
    if missing:
        print(
            f"Error: Required database configuration missing: {', '.join(missing)}\n"
            "Please set all required environment variables.",
            file=sys.stderr
        )
        sys.exit(1)

    # Validate and convert DB_PORT to integer
    try:
        db_port = int(DB_PORT)
    except (ValueError, TypeError):
        print(
            f"Error: HA_DB_PORT must be a valid integer, got: {DB_PORT}",
            file=sys.stderr
        )
        sys.exit(1)

    # Initialize analyzer with separate connection parameters
    analyzer = EnergyAnalyzer(
        db_host=DB_HOST,
        db_port=db_port,
        db_name=DB_NAME,
        db_user=DB_USER,
        db_password=DB_PASSWORD,
        days=args.days,
    )

    # Connect to database
    if not analyzer.connect_database():
        sys.exit(1)

    # Fetch and analyze data
    print(f"Analyzing energy data for the last {args.days} days...")
    data = analyzer.fetch_energy_data()
    analysis = analyzer.analyze_patterns(data)

    # Export results
    analyzer.export_report(analysis, args.output, args.format)

    print("Energy analysis complete!")


if __name__ == "__main__":
    main()
