# Python Evaluation Template

Use this as a starting point for a Python-based eval script. Adapt it to your project.

```python
#!/usr/bin/env python3
"""
Autoresearch evaluation script.
DO NOT MODIFY during the experiment loop. The agent modifies the editable files only.
"""
import sys
import time


def run_eval():
    """
    Replace this with your actual evaluation logic.

    Must return a dict with at least the primary metric.
    Keys become the metric names printed to stdout.

    Examples:
        # Landing page A/B test simulation
        return {"conversion_rate": 3.2, "page_load_ms": 450}

        # RAG pipeline evaluation
        return {"accuracy": 0.847, "cost_per_query": 0.03}

        # API benchmark
        return {"p95_latency": 45.2, "error_rate": 0.001}

        # ML training
        return {"val_loss": 0.342, "vram_gb": 18.5}
    """
    raise NotImplementedError("Replace this with your evaluation logic")


if __name__ == "__main__":
    try:
        start = time.time()
        metrics = run_eval()
        elapsed = time.time() - start

        for key, value in metrics.items():
            print(f"{key}: {value}")
        print(f"eval_time_seconds: {elapsed:.1f}")

        sys.exit(0)
    except Exception as e:
        print(f"EVAL_ERROR: {e}", file=sys.stderr)
        sys.exit(1)
```

## Guidelines

- The eval script must be **deterministic** or at least **low-variance**. If results are noisy, consider averaging multiple runs.
- Print each metric on its own line in the format `metric_name: value`.
- Exit 0 on success, non-zero on failure. The agent treats non-zero exits as crashes.
- Keep the eval script fast. The time budget is for the full experiment, including eval.
- If your evaluation requires external services (APIs, databases), handle connection errors gracefully.
