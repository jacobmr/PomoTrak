# Release Notes Guide

This repository uses a custom release notes system that allows you to write detailed release notes for each version.

## How It Works

1. **Edit `RELEASE_NOTES.md`** - Update this file with your custom release notes before creating a new release
2. **Create a new release** - The GitHub release will use your custom notes
3. **Automatic fallback** - If no `RELEASE_NOTES.md` exists, it will use a default template

## Release Notes Format

The `RELEASE_NOTES.md` file should contain your release notes in Markdown format. Follow this structure:

```markdown
# Release Notes

## What's New in vX.Y.Z

### 🌟 New Features
- Feature 1
- Feature 2

### 🔧 Improvements
- Improvement 1
- Improvement 2

### 🐛 Bug Fixes
- Fix 1
- Fix 2
```

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for added functionality in a backward-compatible manner
- **PATCH** version for backward-compatible bug fixes
