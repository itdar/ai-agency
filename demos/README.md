# demos/

Mocked terminal demos for the root README. **No real AI calls** — all output
is scripted so the demos are deterministic and free to regenerate.

## Regenerate GIFs

```bash
# one-time: install vhs + tmux
brew install vhs tmux

# from repo root
vhs demos/init.tape     # → imgs/init.gif
vhs demos/multi.tape    # → imgs/multi.gif
```

Both tapes add `demos/mock/` to `PATH` so the fake `ai-agency` binary is
picked up instead of the real one.

## Files

| File | Purpose |
|---|---|
| `init.tape` | VHS script for the `ai-agency init` demo |
| `multi.tape` | VHS script for the 4-pane multi-agent demo |
| `mock/ai-agency` | Fake CLI — prints scripted output for `init` / `list` / `board` |
| `mock/agent-pm.sh` | PM pane — posts tasks, writes to shared board file |
| `mock/agent-backend.sh` | Backend pane — claims work, hits a block, resumes |
| `mock/agent-frontend.sh` | Frontend pane — claims 429 handler, ships |
| `mock/agent-infra.sh` | Infra pane — reacts to unblock request |
| `mock/multi-setup.sh` | Builds the 2×2 tmux layout, launches each pane |

Shared board file: `/tmp/ai-agency-demo-board.md` (truncated at every run).

## Tweaking

- Pacing: edit `sleep` values in the `mock/agent-*.sh` scripts; total runtime
  must stay under the `Sleep` budget at the end of `multi.tape` (currently 18s).
- Terminal size: `Set Width` / `Set Height` in the tape files.
- Theme: `Set Theme` — VHS ships Dracula, Catppuccin, Solarized, etc.
