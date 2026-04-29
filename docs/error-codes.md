# Error Codes Reference

> Machine-readable error codes returned in JSON `code` field. Use these for programmatic error handling.

## Error Code Format

All errors return:
```json
{
  "status": "error",
  "code": "<error_code>",
  "message": "<human_readable_message>"
}
```

**Important:** Branch on `code`, not `message`. Messages may change; codes are stable.

---

## Error Codes

### Argument Errors (Exit Code 2)

| Code | Meaning | Fix |
|------|---------|-----|
| `unknown_command` | Command not recognized | Check spelling, use `help` for list |
| `missing_pid` | `--pid` flag required but not provided | Add `--pid <number>` |
| `invalid_pid` | PID is not a valid integer | Ensure PID is numeric |
| `missing_index` | `--index` flag required for click | Add `--index <number>` |
| `invalid_index` | Index is not a valid integer | Ensure index is numeric |
| `missing_output` | `--output` flag required | Add `--output <path>` |
| `invalid_mode` | `--mode` value not recognized | Use `raw`, `som`, or `grid` |
| `invalid_timeout` | Timeout is not a valid number | Use positive integer (ms) |

### Window/Element Errors (Exit Code 3)

| Code | Meaning | Fix |
|------|---------|-----|
| `no_windows` | PID has no visible windows | Check if app is running, has UI |
| `window_not_found` | Could not find suitable window | App may be minimized or on other space |
| `element_not_found` | No element at given index | Re-run `screenshot --include-tree` to refresh indices |
| `selector_not_found` | `wait-for-selector` found no match | Check role/label criteria, extend timeout |
| `ax_access_denied` | Accessibility API rejected request | Grant Terminal accessibility permissions |

### I/O Errors (Exit Code 4)

| Code | Meaning | Fix |
|------|---------|-----|
| `write_failed` | Could not write PNG to disk | Check path permissions, disk space |
| `click_rejected` | SkyLight refused to post event | Try fallback method, check TCC permissions |
| `capture_failed` | CGWindowListCreateImage returned nil | Window may have closed during capture |

### Timeout Errors (Exit Code 5)

| Code | Meaning | Fix |
|------|---------|-----|
| `timeout` | `wait-for-selector` deadline exceeded | Increase `--timeout`, verify element exists |

### Internal Errors (Exit Code 1)

| Code | Meaning | Fix |
|------|---------|-----|
| `internal_error` | Unexpected exception | Report bug with full output |
| `skylight_load_failed` | Could not dlopen SkyLight.framework | macOS version incompatible? |
| `symbol_not_found` | SkyLight symbol missing | macOS version changed private API |

---

## Exit Code Summary

| Exit Code | Category | Retry Strategy |
|-----------|----------|----------------|
| 0 | Success | — |
| 1 | Internal | Do not retry, report bug |
| 2 | Arguments | Do not retry, fix call site |
| 3 | Not found | Re-screenshot, retry once |
| 4 | I/O/Click | Try fallback or report |
| 5 | Timeout | Extend timeout or re-plan |

---

## Orchestrator Decision Tree

```
if exit_code == 0:
    proceed with response
elif exit_code == 2:
    LLM made invalid call → fix prompt/args
elif exit_code == 3:
    window/element changed → re-screenshot → retry
elif exit_code == 4:
    click failed → try keyboard nav fallback
elif exit_code == 5:
    page didn't load expected element → ask LLM to re-plan
else:  # exit_code == 1
    internal error → log and escalate
```
