---
name: live-wallpaper-design
description: Read and apply LiveWallpaper's project design guidance whenever designing or modifying user-facing UI. Do not use for changes that do not affect the UI.
---

# LiveWallpaper Design Skill

Use this skill whenever designing or modifying user-facing UI.

## Before designing

Read:

- Docs/Design/README.md
- Docs/Design/DESIGN_PRINCIPLES.md
- Docs/Design/MACOS_GUIDELINES.md
- Docs/Design/COMPONENTS.md
- Docs/Design/INTERACTION_GUIDELINES.md
- Docs/Design/REFERENCES.md
- Docs/Design/VISUAL_LANGUAGE.md

Do not begin implementation before understanding these guidelines.

## Design process

For every UI task:

1. Identify the user's primary task.
2. Identify the primary workspace.
3. Determine appropriate macOS navigation structure.
4. Identify persistent vs contextual controls.
5. Define important UI states.
6. Design interaction behavior.
7. Apply the project's visual language.
8. Verify the result against the Design guidelines.
9. Only then implement the UI.

## Before finishing

Verify:

- Does this look like a shipping macOS application?
- Does the window behave as a workspace rather than a dashboard?
- Are unnecessary cards being used?
- Are controls appropriately sized for macOS?
- Is information density appropriate for desktop?
- Are native controls used where appropriate?
- Does resizing work?
- Are hover, selection, loading, empty, disabled and error states handled?
- Are contextual controls actually contextual?

If the UI resembles a SaaS dashboard, mobile UI enlarged for desktop,
or a Figma/Penpot concept mockup, reconsider the design before finishing.
