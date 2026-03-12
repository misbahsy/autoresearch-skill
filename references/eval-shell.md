# Shell Evaluation Template

Use this as a starting point for a shell-based eval script. Adapt it to your project.

```bash
#!/usr/bin/env bash
# Autoresearch evaluation script.
# DO NOT MODIFY during the experiment loop. The agent modifies the editable files only.
set -euo pipefail

# ============================================================
# Replace the section below with your actual evaluation logic.
# The script must print metrics to stdout in the format:
#   metric_name: value
# Exit 0 on success, non-zero on failure.
# ============================================================

START_TIME=$(date +%s)

# --- Example: HTTP endpoint benchmark ---
# RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:3000)
# echo "response_time: ${RESPONSE_TIME}"

# --- Example: Run test suite and extract pass rate ---
# RESULTS=$(pytest tests/ -q 2>&1)
# PASSED=$(echo "$RESULTS" | grep -oP '\d+(?= passed)')
# TOTAL=$(echo "$RESULTS" | grep -oP '\d+(?= passed)' ; echo "$RESULTS" | grep -oP '\d+(?= failed)')
# echo "pass_rate: $(echo "scale=3; $PASSED / ($PASSED + $FAILED)" | bc)"

# --- Example: Run a benchmark script ---
# ./run_benchmark.sh | tail -1

# --- Placeholder (remove and replace) ---
echo "ERROR: Replace this with your evaluation logic" >&2
exit 1

# --- Print eval time ---
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo "eval_time_seconds: ${ELAPSED}"
```

## Guidelines

- Print each metric on its own line in the format `metric_name: value`.
- Use `set -euo pipefail` so the script fails fast on errors.
- Exit 0 on success, non-zero on failure. The agent treats non-zero exits as crashes.
- Keep the eval fast. The time budget covers the full experiment including eval.
- If shelling out to other tools, capture their output and extract the relevant metric.
