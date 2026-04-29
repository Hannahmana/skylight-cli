# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Nothing yet

### Changed
- Nothing yet

### Fixed
- Nothing yet

---

## [0.1.0] - 2024-XX-XX

### Added

#### Core Commands
- `screenshot` - Capture window with optional SoM overlay
  - `--mode raw` - Plain screenshot
  - `--mode som` - Set-of-Marks numbered badges
  - `--mode grid` - Fallback grid overlay
  - `--include-tree` - Include AX element data in JSON response
  - `--dry-run` - Return JSON without writing PNG
- `click` - Click element by index using SkyLight private API
  - Falls back to CGEvent if SkyLight unavailable
- `wait-for-selector` - Poll for AX element matching role/label
  - Configurable timeout and poll interval
- `get-window-state` - Return window frame and frontmost status
- `list-elements` - Dump accessibility tree as JSON
- `version` - Print version info as JSON
- `help` - Print usage information

#### Architecture
- `WindowCapture.swift` - CGWindowList-based window capture by PID
- `AXElementFinder.swift` - Recursive accessibility tree walker
- `SoMOverlay.swift` - Badge rendering with collision avoidance
- `SkyLightClicker.swift` - dlopen-based SkyLight framework access
- `Utils.swift` - Argument parsing, JSON output, error handling

#### Documentation
- `AGENTS.md` - Entry point for AI agents with decision tree
- `llms.txt` - LLM context file following convention
- `CLI_REFERENCE.md` - Complete command reference
- `CONTRIBUTING.md` - Contribution guidelines
- `docs/architecture.md` - System architecture overview
- `docs/brain.md` - Design philosophy and decisions
- `docs/handoff.md` - Agent session state tracking
- `docs/recovery-mode.md` - Troubleshooting guide
- `docs/stealth-triade.md` - Multi-CLI ecosystem docs
- `docs/error-codes.md` - Machine-readable error reference

#### Tooling
- `Makefile` - Build, install, test targets
- `scripts/doctor.sh` - Diagnostic checks
- `scripts/smoke-test.sh` - Basic functionality tests
- `scripts/install.sh` - One-line installer
- `scripts/grant-permissions.sh` - macOS permission helper
- `.github/workflows/build.yml` - CI workflow
- `.github/ISSUE_TEMPLATE/` - Bug and agent-confusion templates
- `.github/PULL_REQUEST_TEMPLATE.md` - PR checklist

### Technical Notes
- macOS 12+ required (Monterey)
- No external dependencies (SPM manifest is clean)
- All SkyLight access via dlopen (no static linking)
- Stdout is always valid JSON
- Exit codes follow documented contract
