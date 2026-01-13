# Home Assistant Templates

This directory contains reusable templates for Home Assistant documentation and configuration.

## Available Templates

### Documentation Templates

- **[README.template.md](README.template.md)** - Project README template with sections for overview, architecture, features, and maintenance
- **[package-documentation.template.md](package-documentation.template.md)** - Package documentation template for energy monitoring and other packages

### Configuration Templates

- **[configuration.template.yaml](configuration.template.yaml)** - Main Home Assistant configuration file with comments and best practices
- **[energy-cost.template.yaml](energy-cost.template.yaml)** - Jinja2 template for energy cost calculations

### Script Templates

- **[energy_analysis.template.py](energy_analysis.template.py)** - Python script template for energy consumption analysis

## Usage

### Using Documentation Templates

Copy the template and customize it for your use case:

```bash
# For project README
cp ha/templates/README.template.md README.md

# For package documentation
cp ha/templates/package-documentation.template.md packages/my-package.md
```

### Using Configuration Templates

Reference templates in your configuration or copy and adapt:

```bash
# Copy configuration template
cp ha/templates/configuration.template.yaml config/configuration.yaml

# Edit with your specific settings
nano config/configuration.yaml
```

### Using Script Templates

Copy and customize for your automation needs:

```bash
# Copy script template
cp ha/templates/energy_analysis.template.py scripts/energy_analysis.py

# Make executable
chmod +x scripts/energy_analysis.py
```

## Template Guidelines

When creating new templates:

1. **Include comprehensive comments** - Explain the purpose and usage
2. **Provide examples** - Show practical implementations
3. **Use placeholders** - Mark areas that need customization (e.g., `!secret`, `CHANGEME`)
4. **Follow conventions** - Adhere to Home Assistant and project naming standards
5. **Version templates** - Include version history and last updated date

## Contributing

To add new templates:

1. Create the template file in this directory
2. Add entry to this README with description
3. Include usage examples
4. Submit pull request with documentation

---

*For more information, see [Documentation Standards](../guidelines/10-documentation-standards.md)*
