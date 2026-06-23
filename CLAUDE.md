# CLAUDE.md — Project Workflow Rules

## Bug Fixing & Testing Protocol

- After every change, **retest the entire affected flow** until no errors occur.
- Do not mark a task complete until the full system runs without errors.
- Iterate: fix → test → fix → test → repeat until clean.
- Direct check through on frontend functions also by running .\run.bat with login acc chewxs-wp23@student.tarc.edu.my , Sheng7807.

## Cross-File Impact Check

- Whenever any file is changed, **scan all related files** to determine if they also need to be updated.
- Check imports, references, API contracts, shared types, config, and any dependent logic.
- Never assume a change is isolated — always verify downstream and upstream impact.
- IF any SQL changes must follow up the schema.sql