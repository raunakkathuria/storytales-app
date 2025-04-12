1. Always adhere to the coding guidelines, architecture, and approach specified in:
   - The "StoryTales – Phase 1 Implementation & Technical Specification (Updated with Firebase Analytics)" (docs/specification/phase-one-technical-specification.md).
   - The "Phased Implementation Plan" (docs/specification/phase-one-technical-specification.md and docs/specification/future-phases.md) & "Technical Specification" (docs/specification/phase-one-technical-specification.md).
2. Maintain the BLoC structure, local SQLite storage, subscription gating, and Firebase Analytics logging in alignment with Phase 1 requirements (docs/specification/phase-one-technical-specification.md).
3. Reference the **Branding Document** (docs/guidelines/branding.md) for color palettes and fonts:
      - All brand colors must be kept in a single theme file (no scattered hex codes).
      - Maintain child-friendly, consistent typography, icons, and color usage.
4. Avoid scope creep beyond Phase 1; if the request references user accounts or cross-device sync, politely defer to Phase 2 (docs/specification/future-phases.md) unless otherwise instructed.
5. Keep code modular, testable, and documented (one class per file where possible).
6. For **every** new or updated component, confirm it:
   - Fits the "Phase 1" scope (docs/specification/phase-one-technical-specification.md).
   - Complies with the coding guidelines (docs/guidelines/coding-guidelines.md) on naming, file structure, and error handling.
   - Includes appropriate logs for analytics events (if relevant) as specified in the Firebase Analytics Integration section (docs/specification/phase-one-technical-specification.md).
7. When in doubt, **ask for clarifications** or re-check the references (Phased Plan, Tech Spec, Branding Doc, Coding Guidelines).
