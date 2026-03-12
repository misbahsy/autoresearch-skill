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

Ask: "What is the single number that tells you things got better? Give it a name and tell me whether higher or lower is better."

Examples to offer if they're unsure:
- `conversion_rate` (higher is better)
- `p95_latency_ms` (lower is better)
- `accuracy` (higher is better)
- `cost_per_acquisition` (lower is better)
- `roas` (higher is better)
- `val_loss` (lower is better)
- `throughput_rps` (higher is better)

Follow up: "Do you know the current baseline value? If not, we'll measure it before starting."

### Step 3: Identify the Variables

Ask: "What are the main knobs I should be turning? List the things you'd normally experiment with manually."

Suggest examples based on their domain:
- **Landing page**: headline, subheading, CTA text, button color/style, form fields, social proof, layout, hero image
- **RAG pipeline**: chunk_size, overlap, top_k, embedding_model, reranking_threshold, prompt_template
- **Ads**: keyword bids, match types, ad copy, audience targeting, placement, schedule
- **API**: cache TTL, connection pool size, query structure, batch sizes, retry logic, indexing
- **Prompt engineering**: system prompt, few-shot examples, temperature, output format, chain-of-thought structure
- **ML training**: learning rate, batch size, architecture choices, regularization, data augmentation

### Step 4: Define the Files

Ask three questions:
1. "Which files should I be allowed to modify during experiments?"
2. "Which files must I NEVER touch?"
3. "Any files I should read for context but not modify?"

### Step 5: Set Up Evaluation

Ask: "How do I run the evaluation and get a score? Give me the command."

Examples: `python eval.py`, `node test.js`, `./benchmark.sh`, `pytest tests/ -q`

Then ask: "What does the score line look like when it prints to stdout?"

Examples: `accuracy: 0.847`, `conversion_rate=3.2`, `p95_latency: 45.2`

The agent needs this exact pattern to parse the metric from output.

If the user doesn't have an eval script yet, offer to help create one. Reference
templates in `references/eval-python.md` and `references/eval-shell.md`.

### Step 6: Time and Constraints

Ask: "How long should each experiment take to run? Default is 5 minutes."

Adjust guidance based on domain:
- Prompt/config changes: 1–2 minutes might be enough
- Code changes needing compilation/startup: 5 minutes
- Experiments needing real-world data collection (ads, analytics): 30–60 minutes

Ask: "Any secondary metrics to track? Things that must NOT get worse even if the primary metric improves."

Examples:
- "API cost must stay under $0.05/query"
- "Page load under 3 seconds"
- "Error rate under 0.1%"
- "VRAM usage under 24GB"

### Step 7: Rules and Constraints

Ask: "Any hard rules I must follow during experiments?"

Examples:
- "Never change brand colors"
- "Keep the page under 100KB"
- "Don't modify the tokenizer"
- "Always use batch mode for API calls"
- "Don't add new dependencies"

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
- Read the full `results.tsv` to see what has been tried and what the results were
- Analyze patterns: which types of changes helped, which hurt, which crashed
- Identify underexplored dimensions of the problem
- Formulate a specific, testable hypothesis for this experiment
- Prefer exploring different variable categories than recent experiments
- Write a one-line description of what you'll try and why before implementing

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
Go back to Step 1. **Do not stop. Do not ask for permission.**

If you run out of ideas:
- Combine two previously successful changes that haven't been tried together
- Try the **opposite** of a previously failed change
- Try a completely different dimension of the problem
- Revert to baseline and make one large, bold change
- Re-read any context files for fresh inspiration
- Try an unconventional or creative approach
- Look at what the best-performing experiments have in common
- Try smaller/larger variations of the most successful change

---

## Phase 4: Resume

If `program.md` already exists when the skill is activated:

1. Read `program.md` for the full experiment configuration
2. Read `results.tsv` for the complete experiment history
3. Read `findings.md` if it exists for accumulated insights
4. Analyze what has been tried, what worked, what didn't
5. Identify the current best score and which commit achieved it
6. Verify the working tree is clean (if not, ask the user what to do)
7. Tell the user: "Resuming from experiment #{N}. Current best: {metric}={value}. I see {patterns}. Continuing."
8. Continue the experiment loop from Phase 3, Step 1
9. Do NOT re-run the interview

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
