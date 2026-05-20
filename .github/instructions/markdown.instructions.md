---
description: 'Documentation and content creation standards'
applyTo: '**/*.md'
---

## Markdown Content Rules

Ensure compliance with all rules in this document, including the Validation Requirements section.
Apply rules in this priority order: 1) valid Markdown structure, 2) accessibility,
3) readability and style consistency.

1. **Headings**: Use appropriate heading levels (##, ###, ####, etc.) to structure your content. H1 is generated from the page title, so heading hierarchy starts at H2 and proceeds sequentially without skipping levels.
2. **Lists**: Use `-` for bullets and `1.` for numbered lists. Use two spaces for nested list indentation and a single space after list markers.
3. **Code Blocks**: Use fenced code blocks for code snippets. Specify the language for syntax highlighting.
4. **Links**: Use proper markdown syntax for links. Ensure that links are valid and accessible.
5. **Images**: Use proper markdown syntax for images. Include alt text for accessibility.
6. **Tables**: Use markdown tables for tabular data. Ensure proper formatting and alignment.
7. **Line Length**: Follow the repository Markdown validator line-length setting. Break long lines consistently based on that configured limit.
8. **Whitespace**: Use appropriate whitespace to separate sections and improve readability.
9. **Front Matter**: Front matter is optional for standard documentation and required only for file types or validators that explicitly require metadata.
 - For standard documentation files, do not require front matter.
 - For Copilot instruction files and `SKILL.md`, include only the metadata fields required by the relevant tooling.

## Formatting and Structure

Follow these guidelines for formatting and structuring your markdown content:

- **Headings**: Use `##` for H2 and `###` for H3 (H1 is reserved for the page title). Keep heading hierarchy sequential from H2 onward (H2 → H3 → H4) without skipping levels. Recommend restructuring if content includes H4, and more strongly recommend for H5.
- **Lists**: Use `-` for bullet points and `1.` for numbered lists. Indent nested lists with two spaces.
- **Code Blocks**: Use triple backticks (`) to create fenced code blocks. Specify the language after the opening backticks for syntax highlighting (e.g., `csharp).
- **Links**: Use `[link text](URL)` for links. Ensure that the link text is descriptive and the URL is valid.
    - Valid example: `[Project Architecture](docs/Project_Architecture_Blueprint.md)`
    - Invalid example: `[click here](htp://broken-url)`
- **Images**: Use `![alt text](image URL)` for images. Include a brief description of the image in the alt text.
- **Tables**: Use `|` to create tables. Ensure that columns are properly aligned and headers are included.
- **Line Length**: Break lines according to the repository Markdown validator line-length setting. Use soft line breaks for long paragraphs.
- **Whitespace**: Use blank lines to separate sections and improve readability. Avoid excessive whitespace.

## Validation Requirements

Ensure compliance with all rules in this document, including the following validation requirements:

- **Content Rules**: Verify that the content follows the Markdown content rules specified above.
- **Formatting**: Ensure that the content is properly formatted and structured according to the repository guidelines.
- **Front Matter**: For standard documentation, front matter is optional and should not be required. If the file is a Copilot instruction file or `SKILL.md`, include only the metadata fields required by the relevant tooling.
- **Invalid Syntax Handling**: If invalid or malformed Markdown is detected,
  provide a detailed error message that identifies the issue, points to the
  location, and explains how to fix it.
- **Validation**: Run the repository Markdown validation tools to check compliance with these rules and fix issues before finalizing changes.
