# Component Guidelines

## Surfaces

Before creating a rounded container, ask:

"Does this content actually require its own surface?"

Prefer:

Window
├── Sidebar
├── Workspace
└── Inspector

over:

Window
├── Sidebar Card
├── Content Card
└── Settings Card

---

## Cards

Cards are allowed when they represent meaningful independent objects.

Good examples:

- wallpaper library item
- downloadable wallpaper
- recent item
- theme preset

Poor examples:

- entire editor
- entire settings inspector
- ordinary form section
- toolbar
- navigation area

Cards should not be the default layout primitive.

---

## Corner Radius

Use restrained corner radii.

Do not apply the same large radius to every component.

Radius should depend on component semantics.

Native controls should normally retain their system appearance.

---

## Forms

Forms should be compact.

Prefer:

Label
[ Control ]

or appropriate macOS form alignment.

Related controls can be grouped using spacing and section headers.

A separate card is not required for every form section.

---

## Primary Actions

There should usually be a clear primary action when one exists.

However, primary does not mean enormous.

Use native emphasis rather than increasing the control size dramatically.

---

## Empty States

Empty states should explain:

- what is missing
- what the user can do next

Keep them concise.

Avoid turning empty states into marketing pages.

---

## Icons

Prefer SF Symbols when an appropriate symbol exists.

Icons should primarily improve:
- recognition
- navigation
- state communication

Do not add icons purely to decorate every label.

---

## Selection

Selected content must be clearly distinguishable.

Prefer system selection behavior where possible.

Selection should not require excessive shadows or decorative effects.

---

## Feedback

User actions should have visible feedback.

Examples:

- loading indicator during import
- progress during processing
- disabled Apply button when nothing changed
- success/error state after applying
- selected display indication
