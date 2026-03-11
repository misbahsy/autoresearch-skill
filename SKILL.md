---
name: autoresearch
version: 1.0.0
description: >
  Universal autonomous experimentation loop inspired by Karpathy's autoresearch.
  Give it any project with a measurable metric and tunable variables, and it runs
  experiments autonomously: modify, measure, keep or discard, repeat. Works for
  landing pages, ad campaigns, prompt engineering, RAG pipelines, checkout flows,
  SEO, API performance, recommendation engines, or any domain with a feedback signal.

  Activate when the user mentions "autoresearch", "experiment loop", "overnight
  optimization", "autonomous testing", or asks to optimize something while they sleep.
---

# Autoresearch: Autonomous Experimentation Skill

## Overview

This skill sets up and runs an autonomous experimentation loop for any project.
The pattern: modify something, measure the outcome, keep improvements, discard
regressions, repeat indefinitely overnight.

Inspired by [github.com/karpathy/autoresearch](https://github.com/karpathy/autoresearch).

---

## Phase 1: Interview (First-Time Setup)

If no `program.md` exists in the project directory, conduct the following interview
to understand the user's domain. Ask questions **one at a time**. Be conversational.
Use what the user tells you to ask smarter follow-up questions.

Do NOT dump all questions at once. Wait for each answer before proceeding.

### Step 1: Understand the Project

Ask: "What project are we optimizing? Describe it in a sentence or two."

Listen for domain signals. If they mention:
- "landing page", "conversion", "signup" → suggest HTML/CSS files, conversion rate metric
- "prompt", "RAG", "LLM" → suggest .md/.txt/.yaml files, accuracy metric
- "ads", "campaign", "ROAS" → suggest config/JSON files, ROAS or CPA metric
- "API", "performance", "latency" → suggest code files, latency/throughput metric
- "checkout", "cart", "e-commerce" → suggest template/config files, completion rate metric
- "SEO", "content", "traffic" → suggest content files, organic CTR or traffic metric
- "email", "outreach", "open rate" → suggest template files, open/reply rate metric
- "ML", "training", "model" → suggest training scripts/configs, loss or accuracy metric

Acknowledge their answer and share what you inferred before moving on.

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

Ask: "Which files should I be allowed to modify during experiments?"

Then ask: "Which files must I NEVER touch? (Usually your eval script, test data, core infrastructure)"

Then ask: "Any files I should read for context but not modify?"

### Step 5: Set Up Evaluation

Ask: "How do I run the evaluation and get a score? Give me the command."

Examples: `python eval.py`, `node test.js`, `./benchmark.sh`, `pytest tests/ -q`

Then ask: "What does the score line look like when it prints to stdout?"

Examples: `accuracy: 0.847`, `conversion_rate=3.2`, `p95_latency: 45.2`

The agent needs this exact pattern to parse the metric from output.

If the user doesn't have an eval script yet, offer to help create one (see Phase 2c).

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

Summarize everything back to the user in a clear table:

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

After the interview, generate these files in the project directory:

### 2a. program.md

Create `program.md` in the project root using the template from `templates/program.template.md`, filled in with the user's answers. This file becomes the persistent instruction file for the experiment loop. It must contain everything needed to resume experiments after an interruption.

### 2b. results.tsv

Create `results.tsv` with a header row. Use tab-separated values:

```
commit	{metric_name}	{secondary_metric_names}	status	description
```

Where `{metric_name}` is the primary metric name and `{secondary_metric_names}` are any secondary metrics the user specified, each as a separate column.

### 2c. Eval Script (if needed)

If the user does not already have an eval script, ask: "Do you already have an eval script, or should I create a starter template?"

If creating one, generate either a Python or shell eval script based on their environment. Reference the templates in `templates/eval_python.md` and `templates/eval_shell.md`. The eval script must:
- Run the actual evaluation or call the user's existing tooling
- Print the primary metric to stdout in the exact agreed-upon format
- Print any secondary metrics in the same format
- Exit 0 on success, non-zero on failure

Mark the eval script as protected immediately after creating it.

### 2d. Git Branch

Verify git is initialized. If not, offer to run `git init`.

Ask: "Give me a short tag for this experiment run (e.g., 'v1', 'headline-tests', 'rag-tuning')"

Create and switch to branch: `autoresearch/{tag}`

Commit the generated files (program.md, results.tsv, eval script if created) as the initial setup commit.

### 2e. Baseline

Run the eval command once to establish the baseline score.

Log it as the first row in results.tsv:

```
baseline	{score}	{secondary_scores}	baseline	Initial baseline measurement
```

Commit this baseline result. Tell the user the baseline score and confirm before starting the loop.

---

## Phase 3: Experiment Loop

Once setup is complete, follow the program.md instructions and run this loop.
**NEVER stop unless the user manually interrupts.**

### Step 1: Plan

- Read the full `results.tsv` to see what has been tried and what the results were
- Analyze patterns: which types of changes helped, which hurt, which crashed
- Identify underexplored dimensions of the problem
- Formulate a specific, testable hypothesis for this experiment
- Prefer exploring different variable categories than recent experiments
- Write a one-line description of what you'll try and why before implementing

### Step 2: Implement

- Make targeted changes to the editable files ONLY
- Keep changes small and focused: **one hypothesis per experiment**
- Do not change multiple independent things at once — you won't know what helped
- Changes should be motivated by the experiment history, not random

### Step 3: Commit

- Stage and commit the changes: `git add -A && git commit -m "[short description of what changed]"`
- The commit message should describe the hypothesis, not just the code change
- This commit is your checkpoint. If the experiment fails, you revert to here.

### Step 4: Run

- Execute the eval command with output capture: `{eval_command} > run.log 2>&1`
- Monitor wall-clock time. If the run exceeds **2x the time budget**, kill it:
  - Kill the process
  - Mark the experiment as `timeout`
  - Revert and move on
- Wait for the command to complete (or timeout)

### Step 5: Measure

- Read `run.log` and extract the score by searching for the agreed-upon pattern
- If the pattern is `metric_name: value`, look for that exact prefix
- If the pattern is `metric_name=value`, look for that exact prefix
- Also extract any secondary metric values
- If the score cannot be parsed from the output, treat as a crash

### Step 6: Decide

Compare the new score against the **current best** (not just the previous experiment):

- **IMPROVED** (and all constraints satisfied):
  - Status: `keep`
  - This commit becomes the new best
  - Do NOT revert
- **SAME or WORSE**:
  - Status: `discard`
  - Revert: `git reset HEAD~1 --hard`
- **CONSTRAINT VIOLATED** (primary improved but secondary constraint broken):
  - Status: `discard`
  - Revert: `git reset HEAD~1 --hard`
  - Note which constraint was violated in the description
- **CRASHED** (non-zero exit, unparseable output):
  - Status: `crash`
  - Revert: `git reset HEAD~1 --hard`
  - If the crash looks like a simple typo or syntax error, fix it and retry **once**
  - If fundamental (missing dependency, logic error), log it and move on
- **TIMEOUT** (exceeded 2x time budget):
  - Status: `timeout`
  - Kill the process
  - Revert: `git reset HEAD~1 --hard`

### Step 7: Log

Append a row to `results.tsv`:

```
{7-char commit hash}	{metric_value}	{secondary_values}	{status}	{description}
```

For crashes and timeouts, use `—` for metric values.

Always save (commit) the updated results.tsv so it's never lost:
`git add results.tsv && git commit -m "log: {status} - {short description}"`

### Step 8: Reflect (every 10 experiments)

After every 10 experiments, write a brief analysis to `findings.md`:

- What categories of changes tend to help vs hurt?
- What is the overall improvement trend? (best score over time)
- Are there diminishing returns?
- What unexplored areas remain?
- What's the single most impactful change so far?
- Any surprising results?

Commit findings.md. This serves as a memory system for long runs.

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

## Phase 4: Resume (if program.md already exists)

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

These rules apply at ALL times during the experiment loop:

1. **ONE hypothesis per experiment.** Keep changes small and isolated so you know what caused the change in the metric.
2. **ALWAYS commit before running eval.** This is how you revert cleanly. No commit = no safety net.
3. **ALWAYS log every experiment**, including crashes and timeouts. The history is how you learn.
4. **NEVER modify protected files** or the eval script during the experiment loop.
5. **NEVER stop the loop** unless the user manually interrupts you.
6. **Simpler changes that achieve the same improvement are always preferred.** Don't over-engineer.
7. **Read the full experiment history** before every new proposal. Learn from what's been tried.
8. **If a change improves the metric but violates a constraint, discard it.** Constraints are hard limits.
9. **After every 10 experiments, write a findings summary.** This is your memory across long runs.
10. **If the eval script doesn't exist yet**, help the user create one before starting the loop.
11. **Never fabricate results.** Only log actual measured values from real eval runs.
12. **Keep results.tsv committed.** After every log entry, commit it so progress is never lost.
