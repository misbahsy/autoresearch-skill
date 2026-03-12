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

## Installation

### Claude Code

```bash
# Option A: Add to your project's skill directory
mkdir -p .claude/skills
cp -r /path/to/autoresearch-skill .claude/skills/autoresearch

# Option B: Symlink for shared use across projects
mkdir -p .claude/skills
ln -s /path/to/autoresearch-skill .claude/skills/autoresearch

# Option C: Global install
ln -s /path/to/autoresearch-skill ~/.claude/skills/autoresearch
```

### Codex

```bash
# Add SKILL.md content to your project's AGENTS.md or codex configuration
cp /path/to/autoresearch-skill/SKILL.md ./AGENTS.md
```

### Amp

```bash
cp -r /path/to/autoresearch-skill .amp/skills/autoresearch
```

### Other Agents

Any agent that reads markdown instruction files can use this skill. Copy `SKILL.md` to wherever your agent looks for instructions (e.g., `AGENTS.md`, `.cursor/rules/`, etc.).

## Quick Start

1. Install the skill using one of the methods above
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

## Overnight Runs: The Launcher

For long overnight runs, the prompt-based "never stop" loop can fail if the agent hits context limits or crashes. The `scripts/run.sh` launcher solves this with a crash-resilient outer loop:

```bash
# Run with Claude Code (default)
./scripts/run.sh

# Run with a different tool
./scripts/run.sh --tool codex
./scripts/run.sh --tool amp
./scripts/run.sh --tool gemini

# Cap at 50 iterations
./scripts/run.sh --max 50
```

How it works:
- Spawns a **fresh agent instance** per experiment (clean context every time)
- Agent crashes don't break the loop (`|| true`)
- State persists via files: `results.tsv`, `findings.md`, git history
- Each iteration reads `program.md`, does one experiment, then exits

You still need to run the skill interview first to generate `program.md`. The launcher just makes the loop more robust.

## Skill Structure

```
autoresearch-skill/
├── SKILL.md                         # Skill instructions (interview + loop + rules)
├── scripts/
│   └── run.sh                       # Crash-resilient launcher for overnight runs
├── references/
│   ├── program-template.md          # Template for generated experiment config
│   ├── eval-python.md               # Reference eval script in Python
│   └── eval-shell.md                # Reference eval script in shell
├── LICENSE
└── README.md
```

When the skill runs, it generates these files in your project:

```
your-project/
├── program.md                       # Experiment config (generated from interview)
├── results.tsv                      # Experiment log (append-only)
├── findings.md                      # Periodic analysis (every 10 experiments)
└── run.log                          # Output from the most recent eval run
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

## Resume Support

If `program.md` already exists, the agent skips the interview and picks up where it left off. It reads the full experiment history, identifies the current best, and continues experimenting.

## Design Principles

- **No external dependencies.** The skill is just markdown files. Any agent that reads SKILL.md can use it.
- **Platform-neutral.** Works with Claude Code, Codex, Gemini CLI, Cursor, or any agent that supports skill files.
- **Git is the only hard dependency.** Used for checkpointing experiments.
- **One hypothesis per experiment.** Small changes so you know what caused the metric to move.
- **Never lose data.** results.tsv is committed after every experiment. Git history preserves every attempt.

## Requirements

- Git (for experiment checkpointing)
- An eval script that prints a metric to stdout
- An AI coding agent that supports SKILL.md files

## License

MIT
