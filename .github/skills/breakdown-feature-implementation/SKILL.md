---
name: breakdown-feature-implementation
description: Prompt for creating detailed network infrastructure implementation plans for the Battlestar Ventana Network.
disable-model-invocation: true
---
# Feature Implementation Plan Prompt

## Goal

Act as a senior network infrastructure engineer responsible for planning changes to the Battlestar Ventana network. Create detailed technical implementation plans based on a feature request or infrastructure change description.

If the feature request is incomplete or ambiguous, ask clarifying questions before proceeding with the implementation plan.

Review the provided context and output a thorough implementation plan. For broad requests, organize the plan into phases to keep scope clear and actionable.
For complex requests, present the plan as modules aligned to this document: network architecture, Ansible changes, documentation updates, and security considerations.

**Note:** Do NOT write production configuration snippets. Only include pseudoconfig examples explicitly labeled as illustrative, with clear comments explaining their purpose.

## Output Format

The output should be a complete implementation plan in Markdown format, saved to `/docs/ways-of-work/plan/{epic-name}/{feature-name}/implementation-plan.md`.

### File System

Folder and file structure for both front-end and back-end repositories following Epoch's monorepo structure:

```text
ansible/
  inventory/
  group_vars/
  roles/
docs/
  physical-hosts.md
  device-inventory.md
  firewall-matrix.md
  services.md
  naming-conventions.md
  plans/
    {feature-name}/
      implementation-plan.md
apps/
  [app-name]/
services/
  [service-name]/
packages/
  [package-name]/
```

### Implementation Plan

For each feature:

#### Goal

Feature goal described (3-5 sentences)

#### Requirements

- Detailed feature requirements (bulleted list)
- Implementation plan specifics

#### Technical Considerations

##### System Architecture Overview

Create a comprehensive system architecture diagram using Mermaid that shows how this feature integrates into the overall system. The diagram should include:

- **Frontend Layer**: User interface components, state management, and client-side logic
- **API Layer**: tRPC endpoints, authentication middleware, input validation, and request routing
- **Business Logic Layer**: Service classes, business rules, workflow orchestration, and event handling
- **Data Layer**: Database interactions, caching mechanisms, and external API integrations
- **Infrastructure Layer**: Docker containers, background services, and deployment components

Use subgraphs to organize these layers clearly. Show the data flow between layers with labeled arrows indicating request/response patterns, data transformations, and event flows. Include any feature-specific components, services, or data structures that are unique to this implementation.

- **Technology Stack Selection**: Document choice rationale for each layer
```2

- **Integration Points**: Define clear boundaries and communication protocols
- **Deployment Architecture**: Docker containerization strategy
- **Scalability Considerations**: Horizontal and vertical scaling approaches

##### Database Schema Design

Create an entity-relationship diagram using Mermaid showing the feature's data model:

- **Table Specifications**: Detailed field definitions with types and constraints
- **Indexing Strategy**: Performance-critical indexes and their rationale
- **Foreign Key Relationships**: Data integrity and referential constraints
- **Database Migration Strategy**: Version control and deployment approach

##### API Design

- Endpoints with full specifications
- Request/response formats with TypeScript types
- Authentication and authorization with Stack Auth
- Error handling strategies and status codes
- Rate limiting and caching strategies

##### Frontend Architecture

###### Component Hierarchy Documentation

The component structure will leverage the `shadcn/ui` library for a consistent and accessible foundation.

**Layout Structure:**

```
Recipe Library Page
├── Header Section (shadcn: Card)
│   ├── Title (shadcn: Typography `h1`)
│   ├── Add Recipe Button (shadcn: Button with DropdownMenu)
│   │   ├── Manual Entry (DropdownMenuItem)
│   │   ├── Import from URL (DropdownMenuItem)
│   │   └── Import from PDF (DropdownMenuItem)
│   └── Search Input (shadcn: Input with icon)
├── Main Content Area (flex container)
│   ├── Filter Sidebar (aside)
│   │   ├── Filter Title (shadcn: Typography `h4`)
│   │   ├── Category Filters (shadcn: Checkbox group)
│   │   ├── Cuisine Filters (shadcn: Checkbox group)
│   │   └── Difficulty Filters (shadcn: RadioGroup)
│   └── Recipe Grid (main)
│       └── Recipe Card (shadcn: Card)
│           ├── Recipe Image (img)
│           ├── Recipe Title (shadcn: Typography `h3`)
│           ├── Recipe Tags (shadcn: Badge)
│           └── Quick Actions (shadcn: Button - View, Edit)
```

- **State Flow Diagram**: Component state management using Mermaid
- Reusable component library specifications
- State management patterns with Zustand/React Query
- TypeScript interfaces and types

##### Security Performance

- Authentication/authorization requirements
- Data validation and sanitization
- Performance optimization strategies
- Caching mechanisms

## Context Template

- **Feature / Change Request:** [Describe the change or paste the feature request here]
- **Existing Network Topology:** [Summarize the current network architecture relevant to this change]
- **Relevant Documentation:** [List any existing documentation files that relate to this change]
- **Known Constraints:** [Any known limitations or constraints that must be considered]
- **Feature PRD:** [The content of the Feature PRD markdown file]
````