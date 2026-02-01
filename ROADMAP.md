# Roadmap

## Vision

TimeApp is a native iOS time tracking application designed for personal use. The goal is to provide a simple, fast, and privacy-focused way to track time spent on projects without relying on cloud services or subscriptions.

Data stays on your device. Features are added thoughtfully, with emphasis on reliability and ease of use over complexity.

---

## Current Focus

### Phase 1: Core Stability (Now)
- Ensure timer reliability across app lifecycle events
- Improve data persistence and edge case handling
- Refine internationalization (ro, en, de)

---

## Planned Features

### Short Term
- **Input validation**: Prevent invalid states (e.g., end time before start time)
- **Confirmation dialogs**: Add confirmation before destructive actions (delete project/entry)
- **Export**: CSV export for entries in a selected date range

### Mid Term
- **Enhanced reports**: Custom date ranges, charts, visual breakdowns
- **Search & filter**: Quick search in entries and projects
- **Widgets**: iOS home screen widget showing active timer or today's total

### Long Term (Maybe)
- **iCloud sync**: Backup and sync across devices
- **Live Activities**: Dynamic Island / Lock Screen timer integration
- **Dark mode custom theme**: Custom accent colors

---

## Out of Scope

These features are explicitly **not planned** to keep TimeApp focused:

| Feature | Reason |
|---------|--------|
| Multiple concurrent timers | Business rule: one active timer at a time |
| Web application | TimeApp is iOS-native only |
| Backend / cloud API | All data is local on device |
| Team / collaboration features | Personal use only |
| Subscription / monetization | Free and open source |
| Android version | iOS-native architecture |

---

## Notes

This roadmap is a living document. Priorities may change based on user feedback and technical considerations.

For discussions or suggestions, please [open an issue](https://github.com/Dr3ko/TimeApp/issues).
