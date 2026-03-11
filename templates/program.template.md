# Autoresearch: {project_name}

## Goal

{one_sentence_description}

## Metric

- **Primary**: `{metric_name}` ({higher/lower} is better)
- **Baseline**: {baseline_value}
- **Current best**: {baseline_value}
- **Secondary constraints**:
{secondary_constraints}

## Files

- **EDIT** (agent may modify these):
{editable_files}

- **DO NOT EDIT** (never modify, never delete):
{protected_files}

- **READ FOR CONTEXT** (read freely, do not modify):
{context_files}

## Variables to Explore

{variables_organized_by_category}

## Evaluation

- **Command**: `{eval_command}`
- **Score pattern in stdout**: `{score_pattern}`
- **Time budget**: {time_budget_minutes} minutes per experiment
- **Timeout kill**: {timeout_minutes} minutes (hard kill if exceeded)

## Prerequisites

{setup_commands}

## Rules

{user_rules}

## Experiment Loop

Follow this loop indefinitely. NEVER stop unless manually interrupted.

1. **Read history**: Open `results.tsv`. Study every row. Note the current best score, recent trends, what categories of changes helped vs hurt.

2. **Plan**: Based on the history, choose ONE specific hypothesis to test. Write it down as a one-line description before making changes. Prefer underexplored dimensions. Avoid repeating failed approaches unless you have a specific reason to believe a variation will work.

3. **Implement**: Edit only the files listed under EDIT above. Make small, focused changes — one hypothesis per experiment.

4. **Commit**: `git add -A && git commit -m "[description of hypothesis]"`

5. **Run**: `{eval_command} > run.log 2>&1` — Kill if it exceeds {timeout_minutes} minutes.

6. **Measure**: Parse `run.log` for the pattern `{score_pattern}`. Extract the numeric value. Also extract secondary metrics if applicable.

7. **Decide**:
   - Score improved AND constraints satisfied → status: `keep` (do not revert)
   - Score same or worse → status: `discard` → `git reset HEAD~1 --hard`
   - Constraint violated → status: `discard` → `git reset HEAD~1 --hard`
   - Crashed → status: `crash` → `git reset HEAD~1 --hard` (retry once if simple fix)
   - Timed out → status: `timeout` → kill process, `git reset HEAD~1 --hard`

8. **Log**: Append a row to `results.tsv`:
   ```
   {commit_hash}	{score}	{secondary_scores}	{status}	{description}
   ```
   Then: `git add results.tsv && git commit -m "log: {status} - {description}"`

9. **Reflect** (every 10 experiments): Write analysis to `findings.md` and commit.

10. **Repeat**: Go to step 1. Never stop.
