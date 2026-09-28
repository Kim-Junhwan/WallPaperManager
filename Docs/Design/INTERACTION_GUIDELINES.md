# Interaction Guidelines

The application must be designed as stateful software rather than a collection
of static screens.

Every feature should consider relevant states.

---

## Common States

Consider:

- empty
- idle
- hover
- selected
- focused
- pressed
- disabled
- loading
- success
- failure

Do not design only the ideal state.

---

## Wallpaper Import

Possible states include:

1. Nothing selected
2. Dragging media over the application
3. Importing
4. Processing
5. Image loaded
6. Video loaded
7. Unsupported format
8. Failed import

The interface should respond appropriately to each state.

---

## Wallpaper Editing

When content is loaded, prioritize direct interaction.

Potential interactions:

- drag to reposition
- scroll/pinch to zoom
- double-click to reset where appropriate
- keyboard shortcuts
- contextual menu
- alignment guides
- zoom indicator

Avoid requiring multiple dialogs for simple visual adjustments.

---

## Controls

Controls should only be enabled when the corresponding action is valid.

Example:

Apply Wallpaper:
disabled when no valid wallpaper exists.

Playback settings:
hidden or disabled for static images.

Reset:
disabled when there is nothing to reset.

---

## Hover

Desktop interfaces have a pointer.

Use hover states where useful.

Hover may reveal:
- secondary actions
- tooltips
- controls
- selection affordances

Do not design interactions solely around touch assumptions.

---

## Keyboard

Consider keyboard interaction for common actions.

Examples:

Command + O
Import / Open

Command + Z
Undo where applicable

Escape
Cancel or dismiss transient UI

Return
Confirm appropriate actions

Do not invent shortcuts that conflict with established macOS conventions.

---

## Animation

Animation should communicate state changes.

Keep transitions restrained.

Avoid decorative animation that slows down frequent workflows.

Prefer short, subtle transitions for:
- inspector changes
- hover controls
- selection
- appearing/disappearing contextual UI
- loading completion

The application should feel responsive rather than animated.
