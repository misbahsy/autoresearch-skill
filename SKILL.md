---
name: autoresearch
description: >
  Autonomous experimentation loop that optimizes any project with a measurable
  metric. TRIGGER when users mention "autoresearch", "experiment loop",
  "autonomous testing", "overnight optimization", "run experiments", "optimize
  while I sleep", or ask to improve a metric automatically. Also trigger when
  users want to A/B test, hill-climb, or iteratively tune landing pages, RAG
  pipelines, prompts, APIs, ML configs, ads, or any system with a feedback
  signal. This skill handles the full lifecycle: interview, setup, and
  continuous experiment loop.
license: MIT
metadata:
  author: misbahsy
  version: 2.0.0
  inspiration: https://github.com/karpathy/autoresearch
---

# Autoresearch: Autonomous Experimentation Skill

Modify, measure, keep or discard, repeat. Works for any domain with a measurable
outcome and tunable variables: landing pages, RAG pipelines, prompts, APIs, ML
training, ads, checkout flows, SEO, and more.

## Phase 1: Interview (First-Time Setup)

If no `program.md` exists in the project directory, conduct an interactive
interview to understand the user's domain. Ask questions **one at a time**. Be
conversational. Use answers to ask smarter follow-ups.

### Step 1: Understand the Project

Ask: "What project are we optimizing? Describe it in a sentence or two."

Listen for domain signals:
- "landing page", "conversion", "signup" → HTML/CSS files, conversion rate
- "prompt", "RAG", "LLM" → .md/.txt/.yaml files, accuracy
- "ads", "campaign", "ROAS" → config/JSON files, ROAS or CPA
- "API", "performance", "latency" → code files, latency/throughput
- "checkout", "cart", "e-commerce" → template/config files, completion rate
- "SEO", "content", "traffic" → content files, organic CTR
- "email", "outreach", "open rate" → template files, open/reply rate
- "ML", "training", "model" → training scripts/configs, loss or accuracy

Acknowledge and share what you inferred before moving on.

### Step 2: Define the Metric

Ask: "What is the single number that tells you things got better? Give it a
name and tell me whether higher or lower is better."

Examples if unsure: `conversion_rate` (higher), `p95_latency_ms` (lower),
`accuracy` (higher), `cost_per_acquisition` (lower), `val_loss` (lower).

Follow up: "Do you know the current baseline value? If not, we'll measure it."

### Step 3: Identify the Variables

Ask: "What are the main knobs I should be turning?"

Suggest domain-specific examples. See `references/program-template.md` for the
full variable taxonomy.

### Step 4: Define the Files

Ask three questions:
1. "Which files should I be allowed to modify during experiments?"
2. "Which files must I NEVER touch?"
3. "Any files I should read for context but not modify?"

### Step 5: Set Up Evaluation

Ask: "How do I run the evaluation and get a score? Give me the command."

Then: "What does the score line look like when it prints to stdout?"
(e.g., `accuracy: 0.847`, `conversion_rate=3.2`)

If the user doesn't have an eval script, offer to create one. Reference
templates in `references/eval-python.md` and `references/eval-shell.md`.

### Step 6: Time and Constraints

Ask: "How long should each experiment take to run? Default is 5 minutes."

Ask: "Any secondary metrics that must NOT get worse even if the primary
metric improves?" (e.g., "API cost under $0.05/query", "page load under 3s")

### Step 7: Rules and Constraints

Ask: "Any hard rules I must follow during experiments?"
(e.g., "Never change brand colors", "Don't add new dependencies")

Ask: "Any setup commands I need to run first? (npm install, pip install, etc.)"

### Step 8: Confirm and Generate

Summarize everything in a clear table:

- **Project**: [description]
- **Metric**: `[name]` ([direction] is better), baseline: [value or "TBD"]
- **Variables**: [list]
- **Editable files**: [list]
- **Protected files**: [list]
- **Context files**: [list]
- **Eval command**: `[command]`
- **Score pattern**: `[pattern]`
- **Time budget**: [N] minutes per experiment
- **Constraints**: [list]
- **Rules**: [list]
- **Prerequisites**: [commands or "none"]

Ask: "Does this look right? Anything to change before we start?"

Once confirmed, proceed to Phase 2.

---

## Phase 2: Generate Experiment Files

### 2a. program.md

Create `program.md` using the template from `references/program-template.md`,
filled with the user's answers. This file is the persistent instruction set for
the experiment loop.

### 2b. results.tsv

Create `results.tsv` with a tab-separated header:

```
commit	{metric_name}	{secondary_metric_names}	status	description
```

### 2c. Eval Script (if needed)

If creating one, use `references/eval-python.md` or `references/eval-shell.md`
as the starting point. The eval script must:
- Print the primary metric to stdout in the agreed format
- Print any secondary metrics in the same format
- Exit 0 on success, non-zero on failure

Mark the eval script as protected immediately after creating it.

### 2d. Git Branch

Verify git is initialized. Ask for an experiment tag (e.g., "v1",
"headline-tests"). Create branch: `autoresearch/{tag}`. Commit generated files.

### 2e. Baseline

Run the eval command once. Log the baseline as the first row in results.tsv.
Commit. Tell the user the baseline score and confirm before starting the loop.

---

## Phase 3: Experiment Loop

Once setup is complete, follow program.md and run this loop.
**NEVER stop unless the user manually interrupts.**

### Step 1: Plan
- Read `results.tsv` to see what's been tried
- Analyze patterns: which changes helped, hurt, or crashed
- Formulate a specific, testable hypothesis
- Prefer underexplored dimensions
- Write a one-line description before implementing

### Step 2: Implement
- Make targeted changes to editable files ONLY
- **One hypothesis per experiment** — don't change multiple things at once

### Step 3: Commit
- `git add -A && git commit -m "[hypothesis description]"`

### Step 4: Run
- `{eval_command} > run.log 2>&1`
- Kill if exceeding **2x the time budget**

### Step 5: Measure
- Parse `run.log` for the agreed score pattern
- Extract secondary metrics if applicable
- If unparseable, treat as crash

### Step 6: Decide

| Result | Status | Action |
|--------|--------|--------|
| Improved + constraints met | `keep` | Keep commit |
| Same or worse | `discard` | `git reset HEAD~1 --hard` |
| Constraint violated | `discard` | `git reset HEAD~1 --hard` |
| Crashed | `crash` | Revert (retry once if simple fix) |
| Timed out | `timeout` | Kill + revert |

### Step 7: Log
Append row to `results.tsv`:
```
{7-char hash}	{metric}	{secondary}	{status}	{description}
```
Then: `git add results.tsv && git commit -m "log: {status} - {description}"`

### Step 8: Reflect (every 10 experiments)
Write to `findings.md`: what works, what doesn't, trends, unexplored areas.
Commit.

### Step 9: Continue
Go to Step 1. **Do not stop. Do not ask for permission.**

If stuck: combine successful changes, try opposites, try bold changes, re-read
context files, look at what top experiments share.

---

## Phase 4: Resume

If `program.md` already exists when activated:

1. Read `program.md`, `results.tsv`, and `findings.md` (if it exists)
2. Identify current best score and which commit achieved it
3. Verify clean working tree
4. Tell user: "Resuming from experiment #{N}. Current best: {metric}={value}."
5. Continue from Phase 3, Step 1. Do NOT re-run the interview.

---

## Rules

1. **ONE hypothesis per experiment.** Small, isolated changes.
2. **ALWAYS commit before running eval.** No commit = no safety net.
3. **ALWAYS log every experiment**, including crashes and timeouts.
4. **NEVER modify protected files** or the eval script during the loop.
5. **NEVER stop the loop** unless the user manually interrupts.
6. **Simpler changes are preferred.** Don't over-engineer.
7. **Read the full history** before every new proposal.
8. **Constraints are hard limits.** Discard if violated.
9. **Write findings every 10 experiments.** This is memory for long runs.
10. **Never fabricate results.** Only log actual measured values.
11. **Keep results.tsv committed.** Progress must never be lost.

---

## Overnight Runs

For long runs, use the crash-resilient launcher in `scripts/run.sh`. It spawns
a fresh agent per experiment so context exhaustion and crashes don't kill the
run. State persists via files (results.tsv, findings.md, git history).

```bash
./scripts/run.sh                  # Claude Code, default 1000 iterations
./scripts/run.sh --tool codex     # Use Codex CLI
./scripts/run.sh --tool amp       # Use Amp
./scripts/run.sh --max 50         # Cap at 50 iterations
```
