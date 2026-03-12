#!/usr/bin/env bash
#
# Autoresearch launcher — crash-resilient outer loop
#
# Spawns a fresh agent instance per experiment iteration so that:
#   - Context window exhaustion doesn't kill the run
#   - Agent crashes don't stop the loop
#   - Each iteration gets clean context, reads state from files
#
# Usage:
#   ./scripts/run.sh                     # Claude Code, default 1000 iterations
#   ./scripts/run.sh --tool codex        # Use Codex CLI
#   ./scripts/run.sh --max 50            # Cap at 50 iterations
#   ./scripts/run.sh --tool amp          # Use Amp
#
# Prerequisites:
#   - program.md must exist (run the skill interview first)
#   - Git repo must be initialized
#   - The chosen CLI tool must be installed and authenticated

set -euo pipefail

TOOL="claude"
MAX_ITERATIONS=1000
SLEEP_BETWEEN=2

usage() {
  echo "Usage: $0 [--tool claude|codex|amp|gemini] [--max N]"
  echo ""
  echo "Options:"
  echo "  --tool TOOL   AI coding agent CLI to use (default: claude)"
  echo "  --max N       Maximum iterations (default: 1000)"
  echo "  --help        Show this help"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool) TOOL="$2"; shift 2 ;;
    --max) MAX_ITERATIONS="$2"; shift 2 ;;
    --help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Validate environment
if [[ ! -f "program.md" ]]; then
  echo "Error: program.md not found. Run the skill interview first."
  echo "  Tell your agent: 'Run autoresearch' to set up the experiment."
  exit 1
fi

if [[ ! -d ".git" ]]; then
  echo "Error: Not a git repository. Run 'git init' first."
  exit 1
fi

if [[ ! -f "results.tsv" ]]; then
  echo "Error: results.tsv not found. Run baseline measurement first."
  exit 1
fi

# Build the prompt for each iteration
PROMPT="$(cat <<'PROMPT_EOF'
You are running one iteration of an autonomous experiment loop.

1. Read `program.md` for the full experiment configuration and rules.
2. Read `results.tsv` for the complete experiment history.
3. Read `findings.md` if it exists for accumulated insights.
4. Identify the current best score.
5. Run exactly ONE experiment following the loop in program.md:
   - Plan a hypothesis based on history
   - Implement a small, focused change
   - Commit, run eval, measure, decide (keep/discard/crash)
   - Log the result to results.tsv and commit
   - Write findings.md if this is a multiple-of-10 experiment
6. After completing the single experiment, stop. The next iteration will continue.

Do NOT ask for user input. Do NOT stop early. Complete exactly one full experiment cycle.
PROMPT_EOF
)"

echo "=== Autoresearch Launcher ==="
echo "Tool:       $TOOL"
echo "Max iter:   $MAX_ITERATIONS"
echo "Program:    program.md"
echo ""

# Count existing experiments to get starting number
START_NUM=$(tail -n +2 results.tsv 2>/dev/null | wc -l)
echo "Resuming from experiment #$START_NUM"
echo ""

for i in $(seq 1 "$MAX_ITERATIONS"); do
  EXPERIMENT_NUM=$((START_NUM + i))
  echo "━━━ Iteration $i (experiment #$EXPERIMENT_NUM) ━━━"
  echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"

  # Run the agent — || true ensures crashes don't break the loop
  case "$TOOL" in
    claude)
      echo "$PROMPT" | claude --dangerously-skip-permissions --print 2>&1 | tee ".run_iteration.log" || true
      ;;
    codex)
      codex --quiet --full-auto "$PROMPT" 2>&1 | tee ".run_iteration.log" || true
      ;;
    amp)
      echo "$PROMPT" | amp --dangerously-allow-all 2>&1 | tee ".run_iteration.log" || true
      ;;
    gemini)
      echo "$PROMPT" | gemini 2>&1 | tee ".run_iteration.log" || true
      ;;
    *)
      echo "Unsupported tool: $TOOL"
      exit 1
      ;;
  esac

  echo "Finished: $(date '+%Y-%m-%d %H:%M:%S')"

  # Show current best from results.tsv
  if [[ -f "results.tsv" ]]; then
    TOTAL=$(tail -n +2 results.tsv | wc -l)
    KEEPS=$(grep -c "	keep	" results.tsv || true)
    echo "Total experiments: $TOTAL | Kept: $KEEPS"
  fi

  echo ""
  sleep "$SLEEP_BETWEEN"
done

echo "=== Reached max iterations ($MAX_ITERATIONS). Done. ==="
