## Summary

<!-- One-sentence summary of changes -->

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)

## Changes

<!-- List the specific changes made -->

- 

## Testing

<!-- How did you test these changes? -->

- [ ] `swift build` succeeds
- [ ] `make test` passes
- [ ] Manually tested with: <!-- describe -->

## Checklist

### Code Quality
- [ ] Code follows existing patterns in the codebase
- [ ] No raw `print()` calls (use `Output.json()` or `Output.error()`)
- [ ] No `fatalError()` in production paths
- [ ] Errors return proper JSON with machine-readable `code`

### Contract Compliance
- [ ] Stdout is JSON-only (no logs, banners, human text)
- [ ] Exit codes follow the documented table in AGENTS.md
- [ ] If new exit code added: updated AGENTS.md and docs/error-codes.md

### Documentation
- [ ] If JSON output changed: updated AGENTS.md "Output Contract" section
- [ ] If new command added: added docs/commands/{command}.md
- [ ] Updated CHANGELOG.md under [Unreleased]
- [ ] If session complete: added docs/sessions/session-NN.md

### Agent Readability
- [ ] Changes are discoverable via AGENTS.md decision tree
- [ ] No implicit knowledge required to understand the change

## Related Issues

<!-- Link any related issues: Fixes #123, Related to #456 -->

## Notes for Reviewers

<!-- Any context that would help reviewers -->
