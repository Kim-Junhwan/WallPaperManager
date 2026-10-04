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

### Replace Media

`Replace…` changes the image or video being edited without leaving the
wallpaper editor.

- Open the macOS file picker for supported image and video formats.
- If the user cancels the file picker, keep the current media and all editor
  state unchanged.
- After a successful replacement, update the preview to the new media and
  reset media-dependent state, including position, scale, fit mode, playback
  state, duration, and media metadata.
- Preserve workflow-level values that are not tied to the media, including the
  wallpaper name and target display.
- Do not navigate through the empty import state during replacement.

### Cancel Editing

`Cancel` abandons the current, unapplied add-wallpaper editing session.

- Discard the draft media and all unapplied editor changes.
- Return to the empty Import Wallpaper screen.
- If the user has changed any editor value, ask for confirmation before
  discarding the draft. If nothing has changed, return immediately.
- Do not show `Cancel` after the wallpaper has been successfully applied; the
  applied state remains in the editor and uses normal navigation to leave it.
- Escape performs the same action as `Cancel`, including the discard
  confirmation when required.

`Replace…` and `Cancel` are not equivalent: replacement keeps the editing
workflow active with a different source file, while cancellation ends the
unapplied workflow and removes its draft state.

### Per Display Draft Workflow

After a supported image or video finishes importing, navigate to the editor
with `Per Display` selected by default.

- When only one display is connected, hide the display-mode control.
- When multiple displays are connected, offer `Per Display` and `Span All`.
- Initialize every connected display with an independent draft assignment of
  the imported media and the default transform.
- Draft assignments update only the editor preview. Do not change the desktop
  wallpaper until the user chooses `Apply Changes`.
- Select the primary display when the editor first opens.
- Selecting a display changes the inspector context without changing the other
  draft assignments.
- `Change Media…` replaces media only for the selected display and resets only
  that display's media-dependent state.
- `Keep Current Wallpaper` removes the selected display from the pending change
  set and preserves its currently applied wallpaper.
- Show the number of displays that will change near the workspace and the
  apply action.
- Apply the pending display changes atomically. Roll back the entire operation
  if any target display fails.

Do not show a global `Replace…` action in Per Display mode because its target is
ambiguous. Span mode may show `Replace Media…` because it has one shared media
assignment.

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
