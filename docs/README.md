# D&D 2024 Combat Simulator Documentation

This directory contains the architectural decisions and requirement specifications for the project.

## Structure

- `adrs/`: Architecture Decision Records (MADR format).
- `openspec/`: Formal requirement specifications and technical designs (OpenSpec format).
- `portal/`: A Docusaurus-based web portal for professional rendering of documentation and simulation results.

## Running the Documentation Portal

The portal transforms the raw Markdown files in `adrs/` and `openspec/` into an interactive web site.

### Prerequisites
- Node.js (v18+)
- npm

### Setup & Build
1. Navigate to the portal directory:
   ```bash
   cd docs/portal
   ```
2. Install dependencies (first time only):
   ```bash
   npm install
   ```
3. Transform the documentation:
   ```bash
   node scripts/build-docs.js
   ```

### Local Development
To run the portal locally with live reload:
```bash
cd docs/portal
npm run start
```

### Static Build
To build the static site for deployment:
```bash
cd docs/portal
npm run build
```
The output will be in `docs/portal/build`.
