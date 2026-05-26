# Adapters

Matins is agent-runtime-agnostic. The framework is just files: a markdown state document, observe-script shell files, and a YAML threshold config. Any agent runtime that can read text, execute shell commands, and commit/push git can run matins.

This document describes how matins maps onto specific runtimes.

## Claude Code (reference runtime)

The framework was developed against [Claude Code](https://docs.claude.com/en/docs/claude-code). The reference invocation is:

```
/loop run matins
```

This relies on:

- **`/loop`** — Claude Code's self-paced iteration mechanism. The agent picks the next task, executes, then schedules its own next wakeup.
- **Shell tool** — to run `.continuity/observe/*.sh` and git commands.
- **Read/Edit/Write tools** — to update `MATINS.md` in place.
- **Optional: `telegram-notify` skill** — for milestone pings. Replace with any notify channel you prefer.

Claude Code skills like `niptao-cut-release`, `eas-build-watch`, `vercel:deploy` integrate naturally — list them under `## Skills & Connectors` so the agent knows what's available.

## Cursor

Cursor's agent mode supports a similar long-running task loop, though without an explicit `/loop` primitive at the time of writing. To run matins in Cursor:

1. Open the project in Cursor.
2. In the agent panel, paste:
   ```
   Read MATINS.md in this directory. Follow the protocol at
   https://github.com/gaurav18115/matins/blob/main/docs/PROTOCOL.md exactly.
   Execute one task per turn. After each task, update MATINS.md, commit + push
   to dev, and stop until I send "continue". Never prompt me for input — if
   blocked, mark BLOCKED and move on.
   ```
3. Use `continue` between cycles, or wire a shell wrapper that pings the Cursor CLI on a timer.

Cursor's strength here is the in-editor diff review — easier than Claude Code for `MATINS.md` cycle-to-cycle changes.

Gap: Cursor doesn't auto-schedule the next wakeup like Claude Code's `/loop` does. Self-pacing is manual or via an external cron. **PR welcome:** a Cursor extension that polls and re-invokes the agent.

## Aider

Aider operates in single-shot interactive sessions. To run matins-style cycles:

```bash
# Wrap aider in a loop. Each iteration reads MATINS.md, executes one task, commits.
while true; do
  aider --message "Read MATINS.md. Execute the next task per docs/PROTOCOL.md. Update MATINS.md, commit. Exit." \
        MATINS.md
  sleep 300
done
```

Aider's strength: built-in conventional-commit handling, native git diff awareness. It commits cleanly per cycle without needing the agent to remember the rules.

Gap: no built-in long-running loop. The shell wrapper above approximates `/loop`.

## Codex / OpenAI Assistants

The pattern is the same — point an Assistant at `MATINS.md`, give it the protocol URL, and a shell tool. The Assistants API doesn't have a native loop primitive, so:

1. Spin up an Assistant with code-interpreter + a custom function tool that runs shell commands in the project directory.
2. Set system message to: *"You are the matins agent. Read MATINS.md. Follow https://github.com/gaurav18115/matins/blob/main/docs/PROTOCOL.md. Execute one task per run, then exit."*
3. Drive it from a cron / GH Actions / Lambda that pokes the Assistant on a schedule.

Gap: the Assistants API has per-run cost and rate limits that make 5-minute cycles expensive. Recommend longer intervals (30+ min) or red-band-signal-triggered runs only.

## Continue.dev

Continue runs in your editor and supports custom commands. Wire a `matins-cycle` command in `~/.continue/config.json`:

```jsonc
{
  "customCommands": [{
    "name": "matins-cycle",
    "prompt": "Read MATINS.md in the workspace root. Execute the next task per https://github.com/gaurav18115/matins/blob/main/docs/PROTOCOL.md. Update MATINS.md (status, outcome, last verified). Commit + push to dev. Stop.",
    "description": "Run one matins cycle"
  }]
}
```

Invoke with `@matins-cycle`. No long-running loop yet — manual invocation only.

## Generic LLM tool loop (custom-built)

If you're building your own agent, the matins contract is:

```python
# Pseudocode for any LLM + tool-use loop.

PROTOCOL_URL = "https://github.com/gaurav18115/matins/blob/main/docs/PROTOCOL.md"

def matins_cycle(llm, tools, project_dir):
    """Execute one matins cycle. Idempotent — safe to call in a loop."""
    state = read_file(f"{project_dir}/MATINS.md")
    protocol = fetch(PROTOCOL_URL)

    response = llm.run(
        system=f"You are the matins agent. Protocol:\n{protocol}",
        user=f"Current state:\n{state}\n\nExecute one cycle.",
        tools=tools,  # at minimum: shell, file_edit, git
    )

    # The agent updates MATINS.md and commits as part of its execution.
    # You don't need to parse the response — the file is the state.

def matins_loop(llm, tools, project_dir, interval_seconds=300):
    while not shutdown_requested():
        matins_cycle(llm, tools, project_dir)
        sleep(interval_seconds)
```

Required tools the LLM needs:

| Tool | Why |
|---|---|
| Read file | Read MATINS.md, source files, observe-script outputs |
| Write file | Update MATINS.md in place |
| Execute shell | Run `.continuity/observe/*.sh`, tests, deploys |
| Run git | Commit + push per cycle |
| (Optional) Notify | Telegram / Slack / email on milestones |

You do **not** need vector search, RAG, or a memory store. `MATINS.md` is the memory.

## Adapter wishlist (PRs welcome)

- **Cursor extension** that polls and re-invokes on the matins protocol.
- **VS Code extension** likewise.
- **`continue`-mode shell script** that wraps `/loop` semantics around any one-shot CLI agent (Aider, Plandex, etc.).
- **GH Actions workflow template** that runs matins on a cron without needing a long-running process.
- **Telegram/Discord/Slack bot** that exposes `/matins cycle` to a chat surface — the operator runs cycles from anywhere.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the contribution flow.
