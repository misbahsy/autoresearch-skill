# Autoresearch

Universal autonomous experimentation loop for AI coding agents. Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch).

Give it any project with a measurable metric and tunable variables, and it runs experiments autonomously: modify, measure, keep or discard, repeat. You go to sleep and wake up to a log of experiments and a better system.

## How It Works

```
┌─────────────────────────────────────────────┐
│  1. PLAN     Read history, form hypothesis  │
│  2. IMPLEMENT  Edit allowed files only      │
│  3. COMMIT     Git checkpoint               │
│  4. RUN        Execute eval, enforce timeout │
│  5. MEASURE    Parse metric from stdout      │
│  6. DECIDE     Keep improvement, or revert   │
│  7. LOG        Append to results.tsv         │
│  8. REPEAT     Forever                       │
└─────────────────────────────────────────────┘
```

The agent modifies your code/config, runs your eval script, measures the result, keeps improvements (git commit stays), discards regressions (git reset), and logs everything to `results.tsv`. Every 10 experiments it writes a `findings.md` summary of what it's learned.

## Quick Start

1. Copy this skill into your agent's skill directory (or reference it from your config)
2. Tell your agent: "Run autoresearch" or "Set up an experiment loop"
3. Answer the interview questions (project, metric, files, eval command)
4. Walk away. Come back to a log of experiments and improved code.

## What It Works For

Any domain with a **measurable outcome** and **tunable variables**:

| Domain | Metric | Variables |
|--------|--------|-----------|
| Landing pages | conversion_rate | headline, CTA, layout, colors |
| RAG pipelines | accuracy | chunk_size, top_k, prompt_template |
| API performance | p95_latency_ms | cache TTL, pool size, query structure |
| Ad campaigns | roas | bids, copy, targeting, schedule |
| Prompt engineering | task_accuracy | system prompt, examples, format |
| ML training | val_loss | learning rate, batch size, architecture |
| Email campaigns | open_rate | subject line, send time, content |
| Checkout flows | completion_rate | form layout, steps, payment options |
| SEO content | organic_ctr | titles, meta descriptions, structure |

## File Structure

```
autoresearch/
  SKILL.md                    # The skill itself (interview + loop + rules)
  templates/
    program.template.md       # Template for generated experiment config
    eval_python.md            # Reference eval script in Python
    eval_shell.md             # Reference eval script in shell
  README.md                   # This file
```

When the skill runs, it generates these files in your project:

```
your-project/
  program.md                  # Experiment config (generated from interview)
  results.tsv                 # Experiment log (append-only)
  findings.md                 # Periodic analysis (written every 10 experiments)
  run.log                     # Output from the most recent eval run
```

## The Interview

On first run, the agent asks you about your project one question at a time:

1. **Project** — What are we optimizing?
2. **Metric** — What number tells you things got better? Higher or lower?
3. **Variables** — What knobs should the agent turn?
4. **Files** — Which files can it edit? Which are off-limits?
5. **Evaluation** — What command runs the eval? What does the score output look like?
6. **Time budget** — How long per experiment? Any secondary constraints?
7. **Rules** — Any hard constraints to follow?
8. **Confirm** — Summary review before starting

After confirmation, it generates `program.md`, `results.tsv`, establishes a baseline, and starts the loop.

## The Experiment Loop

Each experiment follows a strict protocol:

1. **Plan** — Read full history, analyze patterns, form a hypothesis
2. **Implement** — Make one small, focused change to allowed files
3. **Commit** — Git checkpoint (safety net for revert)
4. **Run** — Execute eval command with timeout enforcement
5. **Measure** — Parse metric from stdout
6. **Decide** — Improved? Keep. Worse? `git reset HEAD~1 --hard`. Crashed? Log and revert.
7. **Log** — Append row to results.tsv, commit it
8. **Reflect** — Every 10 experiments, write findings.md
9. **Repeat** — Forever, until interrupted

## Resume Support

If `program.md` already exists, the agent skips the interview and picks up where it left off. It reads the full experiment history, identifies the current best, and continues experimenting.

## Example: results.tsv

```
commit	accuracy	cost_per_query	status	description
baseline	0.721	0.042	baseline	Initial baseline measurement
a3f8b21	0.735	0.041	keep	Increased chunk overlap from 50 to 100 tokens
b7c2e19	0.728	0.039	discard	Switched to smaller embedding model
c91d4a5	—	—	crash	Invalid YAML syntax in config
d2e6f33	0.742	0.044	keep	Added reranking step with cross-encoder
e8a1b77	0.738	0.061	discard	Doubled top_k to 20 (cost constraint violated)
f4c9d82	0.751	0.043	keep	Restructured prompt with explicit instructions
```

## Example: findings.md

After 10 experiments, the agent writes something like:

> **Experiments 1–10 Summary**
>
> Best score: accuracy=0.751 (experiment #6, commit f4c9d82)
> Improvement over baseline: +4.2%
>
> What works: Prompt restructuring and reranking had the biggest impact.
> Increasing chunk overlap helped moderately.
>
> What doesn't work: Changing the embedding model hurt accuracy.
> Increasing top_k improved recall but violated the cost constraint.
>
> Unexplored: Temperature tuning, few-shot examples, chunk size reduction.
> Next direction: Try combining reranking with prompt improvements.

## Design Principles

- **No external dependencies.** The skill is just markdown files. Any agent that reads SKILL.md can use it.
- **Platform-neutral.** Works with Claude Code, Codex, Gemini CLI, Cursor, or any agent that supports skill files. Instructions are plain English, not API-specific.
- **Git is the only hard dependency.** Used for checkpointing experiments. Everything else is the user's existing tooling.
- **One hypothesis per experiment.** Small changes so you know what caused the metric to move.
- **Never lose data.** results.tsv is committed after every experiment. findings.md captures insights. Git history preserves every attempt.

## Requirements

- Git (for experiment checkpointing)
- An eval script that prints a metric to stdout
- An AI coding agent that supports SKILL.md files

## License

MIT
