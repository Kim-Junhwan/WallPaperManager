# Design Principles

## 1. Design a Product, Not a Mockup

Every screen must look and behave like a shipping macOS application.

Do not design interfaces primarily for:
- screenshots
- portfolios
- Dribbble-style presentation
- Figma/Penpot concept boards
- design-system showcases

The UI must represent software that can actually be used.

Always consider:

- What is the user trying to accomplish?
- What is the primary workspace?
- What controls are necessary in the current state?
- What happens when the window is resized?
- What changes when content is selected?
- What happens during loading, failure, or empty states?
- Which actions should be contextual rather than permanently visible?

---

## 2. Workspace First

Treat the application window as a functional workspace.

Prefer structures such as:

Sidebar | Content

Sidebar | Workspace | Inspector

Sidebar | Content | Detail

Do not automatically divide the window into floating cards.

The primary content should normally occupy the available workspace directly.

For example, an editor should feel like:

Sidebar | Editor | Inspector

rather than:

Sidebar | Editor Card | Settings Card

---

## 3. Avoid the SaaS Dashboard Look

This is a native desktop utility, not a web dashboard.

Avoid:

- card grids
- nested cards
- excessive rounded rectangles
- large floating panels
- oversized whitespace
- giant CTA buttons
- decorative containers without functional meaning
- mobile/tablet layouts stretched to desktop dimensions

Do not place every logical group inside a card.

Use hierarchy created by:

- spacing
- alignment
- separators
- sidebar backgrounds
- inspector backgrounds
- typography
- grouping
- window structure

before introducing additional containers.

---

## 4. Use Space Efficiently

macOS applications should have realistic desktop information density.

Avoid excessively large:
- padding
- controls
- headings
- buttons
- navigation rows
- form fields

Whitespace should clarify hierarchy, not dominate the interface.

The interface should remain comfortable at typical desktop window sizes.

---

## 5. Visual Restraint

Use visual decoration only when it communicates something.

Corner radius should communicate containment rather than being applied
automatically.

Shadows should be subtle and uncommon.

Borders and separators are often preferable to floating surfaces.

Accent colors should communicate:
- selection
- state
- primary actions
- progress
- important interactive elements

Do not use accent colors merely as decoration.

---

## 6. Hierarchy Before Decoration

When an interface feels unclear, first improve:

1. layout
2. grouping
3. alignment
4. typography
5. spacing
6. separators

Only then consider additional visual decoration.

---

## 7. Direct Manipulation

Whenever possible, users should interact directly with the content.

For wallpaper editing, examples include:

- dragging the wallpaper to reposition it
- scrolling or pinching to zoom
- selecting the target display directly
- seeing changes immediately in the preview

Prefer direct manipulation over unnecessary configuration dialogs.

---

## 8. Progressive Disclosure

Do not expose every option at all times.

Show controls when they become relevant.

For example:

Image selected:
- image positioning controls
- scale
- fit mode

Video selected:
- playback controls
- mute
- looping
- playback-related options

Unsupported content:
- relevant explanation and recovery action

The interface should respond to context.
