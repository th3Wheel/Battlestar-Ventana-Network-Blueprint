---
description: "Home Assistant Testing and Validation - Unit Tests, Integration Tests, Automation Testing, and Validation Strategies"
applyTo: "**/*.py,**/*.yaml,**/*.js,**/*.sh,**/ha/**,**/*.test.*"
---

# Testing and Validation

## 1. Testing Strategy

**Testing Pyramid for Home Assistant:**
```
┌─────────────────┐
│   End-to-End    │ ← Few tests, high value
│     Tests       │
├─────────────────┤
│ Integration     │ ← Medium tests, medium value
│    Tests        │
├─────────────────┤
│   Unit Tests    │ ← Many tests, low value
│                 │
└─────────────────┘
```

**Testing Principles:**
* Test behavior, not implementation
* Keep tests fast and reliable
* Test one thing at a time
* Use descriptive test names
* Maintain tests as production code

## 2. Unit Testing

**Python Script Testing:**
```python
# tests/test_energy_calculations.py
import pytest
from datetime import datetime, timedelta
from unittest.mock import Mock, patch

def test_calculate_daily_energy_consumption():
    """Test daily energy calculation logic"""
    # Arrange
    energy_readings = [
        {"timestamp": "2024-01-01T00:00:00", "value": 100.0},
        {"timestamp": "2024-01-01T12:00:00", "value": 150.0},
        {"timestamp": "2024-01-01T23:59:59", "value": 200.0}
    ]

    # Act
    daily_consumption = calculate_daily_energy_consumption(energy_readings)

    # Assert
    assert daily_consumption == 100.0  # 200 - 100

def test_calculate_daily_energy_consumption_empty_data():
    """Test handling of empty energy readings"""
    # Arrange
    energy_readings = []

    # Act & Assert
    with pytest.raises(ValueError, match="No energy readings provided"):
        calculate_daily_energy_consumption(energy_readings)

def test_calculate_daily_energy_consumption_single_reading():
    """Test handling of single energy reading"""
    # Arrange
    energy_readings = [
        {"timestamp": "2024-01-01T12:00:00", "value": 150.0}
    ]

    # Act & Assert
    with pytest.raises(ValueError, match="Insufficient data for calculation"):
        calculate_daily_energy_consumption(energy_readings)

@pytest.fixture
def sample_energy_data():
    """Fixture providing sample energy data for tests"""
    return [
        {"timestamp": "2024-01-01T00:00:00", "value": 100.0},
        {"timestamp": "2024-01-01T06:00:00", "value": 120.0},
        {"timestamp": "2024-01-01T12:00:00", "value": 150.0},
        {"timestamp": "2024-01-01T18:00:00", "value": 180.0},
        {"timestamp": "2024-01-02T00:00:00", "value": 200.0}
    ]

def test_energy_trend_analysis(sample_energy_data):
    """Test energy trend analysis with fixture data"""
    # Act
    trend = analyze_energy_trend(sample_energy_data)

    # Assert
    assert trend["direction"] == "increasing"
    assert trend["slope"] > 0
    assert trend["confidence"] > 0.8
```

**Template Testing:**
```python
# tests/test_templates.py
import pytest
from jinja2 import Template

def test_energy_cost_calculation_template():
    """Test Jinja2 template for energy cost calculation"""
    template_str = """
    {% set consumption = states('sensor.energy_consumption') | float(0) %}
    {% set rate = states('input_number.energy_rate') | float(0.12) %}
    {% set daily_cost = consumption * rate %}
    {{ daily_cost | round(2) }}
    """

    template = Template(template_str)

    # Mock states function
    def mock_states(entity_id):
        if entity_id == 'sensor.energy_consumption':
            return '25.5'
        elif entity_id == 'input_number.energy_rate':
            return '0.15'
        return '0'

    # Render template
    result = template.render(states=mock_states)

    # Assert
    assert '3.83' in result.strip()

def test_template_error_handling():
    """Test template error handling"""
    template_str = """
    {% set value = states('sensor.nonexistent') | float(0) %}
    {% if value > 0 %}
      High consumption detected
    {% else %}
      Normal consumption
    {% endif %}
    """

    template = Template(template_str)

    # Mock states function returning invalid data
    def mock_states(entity_id):
        if entity_id == 'sensor.nonexistent':
            return 'invalid'
        return '0'

    # Render template
    result = template.render(states=mock_states)

    # Should handle invalid data gracefully
    assert 'Normal consumption' in result
```

## 3. Integration Testing

**Automation Testing:**
```yaml
# tests/test_automations.yaml
# Integration tests for automations

test_energy_monitoring_automation:
  name: "Test Energy Monitoring Automation"
  description: "Verify energy monitoring automation triggers correctly"

  # Setup test environment
  setup:
    - mock_sensor:
        entity_id: sensor.energy_consumption
        state: "15.5"
        attributes:
          unit_of_measurement: "kWh"
          device_class: energy

    - mock_sensor:
        entity_id: sensor.energy_cost
        state: "2.33"
        attributes:
          unit_of_measurement: "$"
          device_class: monetary

  # Test scenarios
  scenarios:
    - name: "High energy consumption alert"
      trigger:
        entity_id: sensor.energy_consumption
        above: 20.0
      expected:
        - service: notify.telegram
          data:
            message: "High energy consumption detected: 25.5 kWh"

    - name: "Normal energy consumption"
      trigger:
        entity_id: sensor.energy_consumption
        below: 10.0
      expected:
        - service: notify.telegram
          data:
            message: "Energy consumption returned to normal"

test_backup_automation:
  name: "Test Backup Automation"
  description: "Verify backup automation runs and notifies"

  setup:
    - mock_time: "02:00:00"
    - mock_sensor:
        entity_id: sensor.last_backup_age
        state: "2"

  scenarios:
    - name: "Successful backup"
      trigger:
        time: "02:00:00"
      expected:
        - service: shell_command.create_backup
        - service: notify.telegram
          data:
            message: "Daily backup completed successfully"
```

**API Integration Testing:**
```python
# tests/test_api_integration.py
import pytest
import requests
from unittest.mock import Mock, patch

class TestHomeAssistantAPI:
    """Test Home Assistant API integrations"""

    def test_sensor_update_api_call(self):
        """Test REST API call to update sensor"""
        # Arrange
        api_url = "http://localhost:8123/api/states/sensor.test_energy"
        api_token = "test_token_123"
        sensor_data = {
            "state": "15.5",
            "attributes": {
                "unit_of_measurement": "kWh",
                "device_class": "energy"
            }
        }

        # Act
        with patch('requests.post') as mock_post:
            mock_post.return_value.status_code = 200

            response = update_sensor_via_api(api_url, api_token, sensor_data)

            # Assert
            mock_post.assert_called_once_with(
                api_url,
                headers={
                    "Authorization": f"Bearer {api_token}",
                    "Content-Type": "application/json"
                },
                json=sensor_data
            )
            assert response.status_code == 200

    def test_api_error_handling(self):
        """Test API error handling"""
        # Arrange
        api_url = "http://localhost:8123/api/states/sensor.test_energy"
        api_token = "invalid_token"

        # Act & Assert
        with patch('requests.post') as mock_post:
            mock_post.return_value.status_code = 401
            mock_post.return_value.json.return_value = {"error": "Unauthorized"}

            with pytest.raises(APIError, match="Unauthorized"):
                update_sensor_via_api(api_url, api_token, {})

def test_nfs_monitoring_integration():
    """Test NFS monitoring script integration"""
    # Arrange
    test_mount_point = "/tmp/test_nfs"

    # Create test directory
    import os
    os.makedirs(test_mount_point, exist_ok=True)

    # Act
    result = check_nfs_mount(test_mount_point)

    # Assert
    assert result["available"] is True
    assert "total_gb" in result
    assert "used_gb" in result
    assert "free_gb" in result

    # Cleanup
    os.rmdir(test_mount_point)
```

## 4. End-to-End Testing

**Scenario-Based Testing:**
```yaml
# tests/e2e/test_energy_dashboard.yaml
test_energy_dashboard_workflow:
  name: "Energy Dashboard E2E Test"
  description: "Test complete energy monitoring workflow"

  setup:
    # Initialize test environment
    - start_ha_container
    - load_test_configuration
    - mock_energy_sensors:
        - entity_id: sensor.grid_power
          initial_state: "2.5"
          device_class: power
        - entity_id: sensor.solar_power
          initial_state: "3.2"
          device_class: power
        - entity_id: sensor.battery_soc
          initial_state: "85"
          device_class: battery

  test_steps:
    - name: "Verify dashboard loads"
      action: navigate_to_dashboard
      dashboard: energy
      expected:
        - dashboard_title: "Energy Overview"
        - cards_loaded: 5
        - no_errors: true

    - name: "Test energy flow visualization"
      action: simulate_energy_flow
      solar_generation: 4.5
      grid_consumption: 1.2
      expected:
        - sensor.grid_power: "1.2"
        - sensor.solar_power: "4.5"
        - sensor.net_energy: "3.3"
        - dashboard_updates: true

    - name: "Test alert notifications"
      action: trigger_high_consumption
      consumption_threshold: 5.0
      expected:
        - automation_triggered: energy_alert
        - notification_sent: telegram
        - alert_message_contains: "High energy consumption"

    - name: "Test historical data"
      action: check_historical_data
      time_range: "24h"
      expected:
        - data_points: "> 96"  # 15-minute intervals
        - no_data_gaps: true
        - accurate_calculations: true

  teardown:
    - stop_ha_container
    - cleanup_test_data
    - generate_test_report
```

**Performance Testing:**
```python
# tests/performance/test_energy_processing.py
import pytest
import time
from concurrent.futures import ThreadPoolExecutor

class TestEnergyProcessingPerformance:
    """Performance tests for energy processing"""

    def test_energy_calculation_performance(self):
        """Test energy calculation performance under load"""
        # Arrange
        test_data = generate_large_energy_dataset(10000)  # 10k readings

        # Act
        start_time = time.time()
        results = process_energy_data(test_data)
        end_time = time.time()

        # Assert
        processing_time = end_time - start_time
        assert processing_time < 5.0  # Should process in under 5 seconds
        assert len(results) == len(test_data)

    def test_concurrent_sensor_updates(self):
        """Test handling of concurrent sensor updates"""
        # Arrange
        sensor_count = 50
        update_count = 100

        # Act
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = []
            for i in range(sensor_count):
                futures.append(
                    executor.submit(simulate_sensor_updates, f"sensor.energy_{i}", update_count)
                )

            results = [future.result() for future in futures]

        # Assert
        for result in results:
            assert result["success_rate"] > 0.95  # 95% success rate
            assert result["average_response_time"] < 0.5  # Under 500ms

    def test_memory_usage_under_load(self):
        """Test memory usage during high load"""
        import psutil
        import os

        # Arrange
        process = psutil.Process(os.getpid())
        initial_memory = process.memory_info().rss / 1024 / 1024  # MB

        # Act
        run_high_load_energy_simulation()

        # Assert
        final_memory = process.memory_info().rss / 1024 / 1024  # MB
        memory_increase = final_memory - initial_memory
        assert memory_increase < 100  # Less than 100MB increase
```

## 5. Template Validation

**Template Testing Tools:**
```python
# tools/validate_templates.py
import os
import yaml
import jinja2
from pathlib import Path

class TemplateValidator:
    """Validate Jinja2 templates in Home Assistant configuration"""

    def __init__(self, config_path: str):
        self.config_path = Path(config_path)
        self.errors = []
        self.warnings = []

    def validate_all_templates(self):
        """Validate all templates in configuration"""
        for yaml_file in self.config_path.rglob("*.yaml"):
            self.validate_file_templates(yaml_file)

        return {
            "errors": self.errors,
            "warnings": self.warnings,
            "valid": len(self.errors) == 0
        }

    def validate_file_templates(self, file_path: Path):
        """Validate templates in a single file"""
        try:
            with open(file_path, 'r') as f:
                content = f.read()

            # Parse YAML
            config = yaml.safe_load(content)

            # Find all template strings
            self._find_and_validate_templates(config, file_path)

        except Exception as e:
            self.errors.append(f"Failed to parse {file_path}: {str(e)}")

    def _find_and_validate_templates(self, config, file_path, path=""):
        """Recursively find and validate templates"""
        if isinstance(config, dict):
            for key, value in config.items():
                current_path = f"{path}.{key}" if path else key
                self._find_and_validate_templates(value, file_path, current_path)
        elif isinstance(config, list):
            for i, item in enumerate(config):
                current_path = f"{path}[{i}]"
                self._find_and_validate_templates(item, file_path, current_path)
        elif isinstance(config, str):
            if self._is_template_string(config):
                self._validate_template_string(config, file_path, path)

    def _is_template_string(self, text: str) -> bool:
        """Check if string contains Jinja2 template syntax"""
        template_indicators = ['{{', '{%', '{#']
        return any(indicator in text for indicator in template_indicators)

    def _validate_template_string(self, template_str: str, file_path: Path, path: str):
        """Validate a single template string"""
        try:
            # Create Jinja2 environment
            env = jinja2.Environment()

            # Mock common HA functions
            def mock_states(entity_id):
                return "10.5"

            def mock_is_state(entity_id, state):
                return True

            # Add mock functions to environment
            env.globals.update({
                'states': mock_states,
                'is_state': mock_is_state,
            })

            # Parse template
            template = env.from_string(template_str)

            # Try to render with mock data
            result = template.render()

            # Check for common issues
            if 'UndefinedError' in str(result):
                self.warnings.append(f"Potential undefined variable in {file_path}:{path}")

        except jinja2.TemplateSyntaxError as e:
            self.errors.append(f"Template syntax error in {file_path}:{path}: {str(e)}")
        except Exception as e:
            self.errors.append(f"Template validation error in {file_path}:{path}: {str(e)}")

# Usage
if __name__ == "__main__":
    validator = TemplateValidator("/config")
    results = validator.validate_all_templates()

    print(f"Validation complete: {len(results['errors'])} errors, {len(results['warnings'])} warnings")

    for error in results['errors']:
        print(f"ERROR: {error}")

    for warning in results['warnings']:
        print(f"WARNING: {warning}")
```

**Template Testing in HA:**
```yaml
# Developer tools template testing
# Use HA Developer Tools > Template to test templates

# Test energy calculation template
{% set consumption = states('sensor.energy_consumption') | float(0) %}
{% set rate = states('input_number.energy_rate') | float(0.12) %}
{% set daily_cost = consumption * rate %}
Daily energy cost: ${{ daily_cost | round(2) }}

# Test sensor availability template
{% set sensor_available = has_value('sensor.energy_consumption') %}
{% set sensor_is_number = is_number(states('sensor.energy_consumption')) %}
Sensor status: {{ 'Available' if sensor_available and sensor_is_number else 'Unavailable' }}

# Test conditional logic
{% if states('sensor.energy_consumption') | float(0) > 20 %}
  ⚠️ High energy consumption detected
{% elif states('sensor.energy_consumption') | float(0) < 5 %}
  ✅ Low energy consumption
{% else %}
  ℹ️ Normal energy consumption
{% endif %}
```

## 6. Automation Testing

**Automation Test Framework:**
```python
# tests/test_automations.py
import pytest
from unittest.mock import Mock, patch
import yaml

class AutomationTester:
    """Test Home Assistant automations"""

    def __init__(self, automation_config_path: str):
        self.automations = self._load_automations(automation_config_path)

    def _load_automations(self, path: str):
        """Load automation configuration"""
        with open(path, 'r') as f:
            config = yaml.safe_load(f)
        return config.get('automation', [])

    def test_automation_triggers(self):
        """Test automation trigger conditions"""
        for automation in self.automations:
            automation_name = automation.get('alias', 'Unnamed')

            # Test trigger validation
            triggers = automation.get('trigger', [])
            assert len(triggers) > 0, f"Automation '{automation_name}' has no triggers"

            for trigger in triggers:
                self._validate_trigger(trigger, automation_name)

    def _validate_trigger(self, trigger: dict, automation_name: str):
        """Validate individual trigger configuration"""
        trigger_type = trigger.get('platform')

        if trigger_type == 'time':
            assert 'at' in trigger, f"Time trigger in '{automation_name}' missing 'at' field"

        elif trigger_type == 'numeric_state':
            assert 'entity_id' in trigger, f"Numeric state trigger in '{automation_name}' missing entity_id"
            assert 'above' in trigger or 'below' in trigger, f"Numeric state trigger in '{automation_name}' missing threshold"

        elif trigger_type == 'state':
            assert 'entity_id' in trigger, f"State trigger in '{automation_name}' missing entity_id"
            assert 'to' in trigger or 'from' in trigger, f"State trigger in '{automation_name}' missing state condition"

    def test_automation_actions(self):
        """Test automation action configurations"""
        for automation in self.automations:
            automation_name = automation.get('alias', 'Unnamed')

            # Test action validation
            actions = automation.get('action', [])
            assert len(actions) > 0, f"Automation '{automation_name}' has no actions"

            for action in actions:
                self._validate_action(action, automation_name)

    def _validate_action(self, action: dict, automation_name: str):
        """Validate individual action configuration"""
        if 'service' in action:
            # Service action
            service = action['service']
            assert '.' in service, f"Service '{service}' in '{automation_name}' is not properly formatted"

            # Check service data
            if 'data' in action:
                self._validate_service_data(action['data'], automation_name)

        elif 'condition' in action:
            # Condition action
            self._validate_condition(action['condition'], automation_name)

    def _validate_service_data(self, data: dict, automation_name: str):
        """Validate service call data"""
        # Check for common issues
        if 'message' in data and '{{' in str(data['message']):
            # Template in message - should be validated
            pass

    def _validate_condition(self, condition: dict, automation_name: str):
        """Validate condition configuration"""
        condition_type = condition.get('condition')

        if condition_type == 'numeric_state':
            assert 'entity_id' in condition, f"Numeric condition in '{automation_name}' missing entity_id"
        elif condition_type == 'state':
            assert 'entity_id' in condition, f"State condition in '{automation_name}' missing entity_id"

def test_energy_automations():
    """Test energy monitoring automations"""
    tester = AutomationTester('/config/automations/energy.yaml')

    # Test triggers
    tester.test_automation_triggers()

    # Test actions
    tester.test_automation_actions()

    # Test specific energy automation logic
    energy_automation = next(
        (a for a in tester.automations if 'energy' in a.get('alias', '').lower()),
        None
    )

    assert energy_automation is not None, "Energy automation not found"

    # Verify energy-specific triggers and actions
    triggers = energy_automation.get('trigger', [])
    has_energy_trigger = any(
        'energy' in str(trigger.get('entity_id', '')) for trigger in triggers
    )
    assert has_energy_trigger, "Energy automation missing energy sensor trigger"
```

## 7. Validation Best Practices

**Configuration Validation:**
```bash
# Validate configuration before restart
hass --config /config --script check_config

# Check for YAML syntax errors
python3 -c "import yaml; yaml.safe_load(open('/config/configuration.yaml'))"

# Validate template syntax
python3 -c "
import jinja2
template = jinja2.Template(open('/config/templates/test.jinja2').read())
print('Template syntax is valid')
"
```

**Automated Validation:**
```yaml
# CI/CD validation pipeline
name: "Validate HA Configuration"

on:
  push:
    paths:
      - 'config/**'
      - '.github/workflows/**'

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'

      - name: Install dependencies
        run: |
          pip install PyYAML jinja2

      - name: Validate YAML syntax
        run: |
          find config -name "*.yaml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;

      - name: Validate templates
        run: |
          python3 tools/validate_templates.py

      - name: Run configuration check
        run: |
          docker run --rm -v $(pwd)/config:/config homeassistant/home-assistant:stable hass --config /config --script check_config

      - name: Run tests
        run: |
          python3 -m pytest tests/ -v
```

**Testing Checklist:**
- [ ] Unit tests for all custom functions
- [ ] Integration tests for automations
- [ ] End-to-end tests for critical workflows
- [ ] Template validation for all Jinja2 code
- [ ] Configuration validation before deployment
- [ ] Performance testing under load
- [ ] Security testing for sensitive operations
- [ ] Documentation updated with test results

**Continuous Testing:**
* Run tests on every configuration change
* Monitor test success rates and fix failures immediately
* Include performance benchmarks in testing
* Automate testing in CI/CD pipeline
* Review test coverage regularly
* Update tests when functionality changes