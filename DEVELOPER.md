
## Rules Management for AI Agents

To support the AI coding assistant's "Rules Sage" persona, we maintain a text-based reference of the D&D 2024 rules.

### Setup
1.  **Obtain PDFs:** Place your legally obtained D&D 2024 Core Rulebook PDFs into the `rules_reference/` directory.
    *   *Note:* This directory is `.gitignored` to prevent copyright infringement. Do not commit these files.
2.  **Extract Text:** Run the extraction script to convert PDFs to lightweight text files.
    ```bash
    ruby extract_rules.rb
    ```
    *   This requires the `pdf-reader` gem (`bundle install` or `gem install pdf-reader`).

### How it Works
*   The `.cursorrules` file instructs the AI to read `rules_reference/*.txt` when answering rules questions.
*   This ensures the AI uses the actual text of the rules rather than potentially hallucinated or outdated training data.
