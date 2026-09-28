# macOS UI Guidelines

LiveWallpaper is a native macOS application.

Native macOS conventions should be preferred over custom UI patterns.

---

## Window Structure

Use established macOS structures where appropriate:

- Titlebar
- Toolbar
- Sidebar
- Content area
- Inspector
- Split views
- Sheets
- Popovers
- Context menus

The window should feel structurally similar to real desktop software,
not a webpage rendered inside a macOS window.

---

## SwiftUI

Prefer native SwiftUI components when they satisfy the requirement.

Examples:

- NavigationSplitView
- NavigationStack
- List
- Form
- Section
- Toolbar
- Button
- Picker
- Menu
- Slider
- Toggle
- ControlGroup
- Divider
- Table
- ScrollView

Use `.sidebar` list styling where appropriate.

Use `.controlSize(.small)` or `.controlSize(.regular)` when appropriate
for desktop interfaces.

Avoid recreating native controls using custom rounded rectangles unless
there is a clear product requirement.

---

## Typography

Prefer the macOS system font.

Typography should communicate hierarchy without excessive size differences.

Typical hierarchy:

Window / screen title
Section heading
Primary label
Secondary label
Supporting text

Avoid large web-style hero headings.

Avoid excessive bold text.

---

## Buttons

Buttons should use normal macOS sizing.

Primary actions may use prominent styling when appropriate.

Avoid full-width CTA buttons unless the interaction genuinely requires one.

Examples of normal actions:

Cancel
Apply
Reset
Choose File
Remove
Done

These should look like desktop controls rather than mobile buttons.

---

## Sidebar

The sidebar is primarily navigation.

Keep rows compact.

Use:
- SF Symbols
- labels
- selection state
- optional badges when useful

Avoid placing sidebar navigation items inside individual cards.

Avoid oversized icons.

---

## Toolbar

Frequently used global or contextual actions should be considered for the
toolbar.

Good candidates include:

- importing media
- selecting displays
- zoom controls
- view modes
- navigation
- contextual actions

Do not create a toolbar merely to fill space.

---

## Inspector

Use an inspector for properties belonging to the currently selected content.

Inspector sections should generally use:

Section title
Control
Control
Divider
Section title
Control

Do not wrap the entire inspector in a large rounded card.

The inspector itself is already a visual region.

---

## Menus and Context Menus

Secondary actions should often be placed in:

- menus
- context menus
- toolbar menus
- ellipsis menus

Do not permanently display every possible action.

---

## Window Resizing

Every major screen must account for resizing.

Consider:

- minimum window size
- sidebar collapse behavior
- inspector visibility
- content scaling
- truncation
- scroll behavior

Avoid relying on arbitrary fixed-width cards when flexible layout is possible.

The UI should continue to look intentional when the window becomes wider.
