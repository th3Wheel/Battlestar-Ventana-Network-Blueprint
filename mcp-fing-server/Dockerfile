# Fing Local API MCP Server - Dockerfile
# Minimal Python image for local-only MCP server

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies first (for better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY pyproject.toml .
COPY README.md .

# Install the package
RUN pip install --no-cache-dir -e .

# Set environment variables
ENV FING_API_URL=http://localhost:48080
ENV PYTHONUNBUFFERED=1

# No ports exposed - this is a local-only stdio MCP server

# Run the MCP server
CMD ["python", "-m", "mcp_fing_server.server"]
