# Workflow Diagrams

This folder contains Mermaid diagram files (`.mmd`) that visualize the n8n Jira automation workflow.

---

## 📊 Available Diagrams

### 1. **workflow-main-flow.mmd**
Complete end-to-end automation flow from trigger to completion.

### 2. **workflow-breakdown-logic.mmd**
Task breakdown logic showing how tasks are split into subtasks based on keywords.

### 3. **architecture.mmd**
System architecture showing n8n, APIs, and data flow.

---

## 🎨 Viewing Diagrams

### Option 1: GitHub (Automatic)
GitHub automatically renders `.mmd` files. Just click on any file to view.

### Option 2: VS Code
Install the **Mermaid Preview** extension:
```bash
code --install-extension bierner.markdown-mermaid
```

### Option 3: Online Viewer
Copy diagram content to: https://mermaid.live

---

## 🖼️ Generate Images

Convert `.mmd` files to images (PNG/SVG/PDF) using the included script.

### Prerequisites

Install Mermaid CLI:
```bash
npm install -g @mermaid-js/mermaid-cli
```

Or use Docker:
```bash
docker pull minlag/mermaid-cli
```

### Usage

Generate PNG images (default):
```bash
./scripts/generate-diagrams.sh
```

Generate SVG images:
```bash
./scripts/generate-diagrams.sh svg
```

Generate PDF:
```bash
./scripts/generate-diagrams.sh pdf
```

### Output

Images will be saved to: `diagrams/images/`

---

## 📝 Editing Diagrams

1. Open any `.mmd` file in your editor
2. Modify the Mermaid syntax
3. Preview changes (VS Code extension or mermaid.live)
4. Regenerate images: `./scripts/generate-diagrams.sh`

---

## 🔗 Mermaid Syntax Reference

- **Flowchart**: https://mermaid.js.org/syntax/flowchart.html
- **Sequence**: https://mermaid.js.org/syntax/sequenceDiagram.html
- **Graph**: https://mermaid.js.org/syntax/flowchart.html

---

## 📦 Integration with Documentation

Add generated images to README or other docs:

```markdown
![Main Workflow](diagrams/images/workflow-main-flow.png)
```

Or link to live Mermaid files:

```markdown
[View Workflow Diagram](diagrams/workflow-main-flow.mmd)
```

---

**Note**: Mermaid files are text-based and version control friendly! 🎯
