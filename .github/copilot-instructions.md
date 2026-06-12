## Context7 MCP Integration (CRITICAL - Read First)

**MANDATORY:** Before starting ANY task, ALWAYS leverage Context7 MCP to gather comprehensive context about the repository, codebase, and related resources.

### Context7 Usage Requirements

1. **Pre-Task Discovery (REQUIRED):**
   - Use Context7 MCP to search for relevant documentation, code patterns, and architectural decisions BEFORE making changes
   - Query Context7 for similar implementations, related VLANs, existing firewall rules, and naming patterns
   - Identify dependencies and cross-references using Context7's semantic search capabilities

2. **Continuous Context Gathering:**
   - Invoke Context7 MCP at every decision point to validate assumptions
   - Use Context7 to find examples of similar changes in repository history
   - Query Context7 for related documentation that might need updating alongside your changes

3. **Context7 Query Patterns:**
   - **For VLAN changes:** "Find all references to VLAN [ID], DHCP scopes, firewall rules, and service definitions"
   - **For firewall updates:** "Show firewall rules involving [source] to [destination], related services, and port definitions"
   - **For naming:** "Find naming patterns for [VLANs/SSIDs/hosts], theme conventions, and similar examples"
   - **For architecture:** "Retrieve architectural decisions, zone models, and related design documents"
   - **For cross-references:** "Find all files mentioning [service/VLAN/host] and their relationships"

4. **Validation Before Commit:**
   - Use Context7 to verify all affected files are identified and updated
   - Query for TODOs, cross-references, and dependencies that might be impacted
   - Ensure consistency across documentation using Context7's semantic analysis

**FAILURE TO USE CONTEXT7 MAY RESULT IN INCOMPLETE CHANGES, BROKEN CROSS-REFERENCES, OR INCONSISTENT DOCUMENTATION.**
