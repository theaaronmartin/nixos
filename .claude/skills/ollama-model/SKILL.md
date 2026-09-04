---
name: ollama-model
description: Add, tune, or troubleshoot a local LLM served by Ollama on NIXCORE, including wiring it into the pi coding agent. Use when a model was just downloaded or pulled, when a local model is slower than expected, when deciding num_ctx / VRAM tradeoffs on the RTX 3080, or when pi cannot see a model. Triggers on "ollama", "qwen", "local model", "num_ctx", "tok/s", "pi model", "gguf".
---

# Adding a local model on NIXCORE

Ollama runs on NIXCORE only, at `127.0.0.1:11434`, configured by `modules/ollama.nix`. The `pi`
coding agent consumes it through `~/.pi/agent/models.json`.

The RTX 3080 has **10 GB total, ~9.2 GB usable** (the desktop session holds ~0.95 GB). That is the
binding constraint for everything below.

## Two traps that are invisible unless you look for them

1. **Ollama serves 4096 tokens by default**, no matter what the model advertises. A model reporting
   `context length 40960` in `ollama show` will still run at 4096. Only the CONTEXT column of
   `ollama ps` tells the truth. `OLLAMA_CONTEXT_LENGTH` in `modules/ollama.nix` sets the floor.

2. **A model reported as loaded may be running partly on CPU.** `ollama ps` shows a PROCESSOR
   column; anything other than `100% GPU` means layers spilled to system RAM. This is severe on
   NIXCORE because CPU boost is disabled there — a 14% spill measured 29.9 tok/s versus 75.0 tok/s
   fully resident.

## Procedure

### 1. Give the model a context-tuned tag

Do not rely on the model's advertised context, and do not edit the original tag. Derive a new one —
it inherits the template and parameters and reuses the same blobs, so it costs no extra disk:

```bash
printf 'FROM <existing-tag>\nPARAMETER num_ctx 12288\n' > /tmp/Mf
ollama create <name>:12k -f /tmp/Mf
```

### 2. Find the largest context that stays 100% GPU

Sweep downward and read `ollama ps` after each load. This is the whole point of the exercise:

```bash
for ctx in 32768 16384 12288 8192; do
  ollama rm probe >/dev/null 2>&1
  printf 'FROM <existing-tag>\nPARAMETER num_ctx %s\n' "$ctx" > /tmp/Mf
  ollama create probe -f /tmp/Mf >/dev/null 2>&1
  curl -s http://127.0.0.1:11434/api/generate \
    -d "{\"model\":\"probe\",\"prompt\":\"hi\",\"stream\":false}" >/dev/null
  printf 'ctx=%-6s -> %s\n' "$ctx" "$(ollama ps | tail -1 | awk '{print $3, $4, $5}')"
  ollama stop probe; sleep 3
done
ollama rm probe
```

**Gate: do not proceed until the chosen context reports `100% GPU`.** Measured ceilings as of
2026-09-04, with `OLLAMA_KV_CACHE_TYPE=q4_0` and flash attention on:

| Model | Max GPU-resident context | VRAM | Speed |
|---|---|---|---|
| `qwen3-14b-iq4xs` (8.1 GB, IQ4_XS) | 12288 | 8.4 GB | 75.0 tok/s |
| `qwen3:8b` (5.2 GB, Q4_K_M) | 32768 | 6.4 GB | 111.0 tok/s |

### 3. Confirm the speed

```bash
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"<tag>","prompt":"Write three sentences about mountains.","stream":false}' \
| python3 -c 'import sys,json; d=json.load(sys.stdin); print(f"{d["eval_count"]/(d["eval_duration"]/1e9):.1f} tok/s")'
```

A 14B-class model well under ~50 tok/s on this card is a spill, not a slow model. Re-check `ollama ps`.

### 4. Register it with pi

Add to the `ollama` provider's `models` array in `~/.pi/agent/models.json`. `contextWindow` must
match the tag's `num_ctx` — pi will happily send more than the server accepts otherwise:

```json
{
  "id": "<tag>",
  "name": "<human label>",
  "reasoning": true,
  "input": ["text"],
  "contextWindow": 12288,
  "maxTokens": 4096,
  "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }
}
```

Provider-level settings that are already correct and should not be changed casually: `apiKey` is the
placeholder `"ollama"` (Ollama ignores it, but pi requires *some* credential before a model appears),
and `compat.supportsDeveloperRole: false` because Ollama's OpenAI shim does not use that role.

`compat.supportsReasoningEffort` is deliberately **`true`**. pi's generic Ollama guidance says to set
it `false`, but that is wrong for this server: measured 2026-09-04 against
`/v1/chat/completions`, `reasoning_effort: "none"` is the *only* way to actually stop Qwen3 from
thinking. `think: false`, `enable_thinking: false`, `chat_template_kwargs.enable_thinking: false`
and a `/no_think` suffix were all accepted and all still produced 400-1100 characters of reasoning.
With it `true`, `pi --thinking off` works; with it `false`, pi cannot send the parameter and every
request thinks.

Verify with `pi --list-models`, then a real agentic task — not just a chat reply, since tool-calling
is the thing that actually breaks:

```bash
cd /tmp && mkdir -p pichk && cd pichk && printf 'one\ntwo\n' > in.txt
pi -p --provider ollama --model '<tag>' --no-session \
  'Read in.txt here and create out.txt with those words uppercased.'
cat out.txt
```

## KV cache precision

`OLLAMA_KV_CACHE_TYPE` is server-wide, not per-model, so changing it needs a rebuild and affects
everything. It is deliberately `q4_0`. `q8_0` was tried on 2026-09-04 and reverted: it roughly
doubles KV size, which cost the 14B its GPU residency entirely (it spilled even at 6144 ctx), for no
measurable accuracy gain — a 4-trial-per-model agentic file test found no difference between the 8B
and 14B either way. On a 10 GB card, spend VRAM on weights, not KV precision.

## Scripting pi (important)

**Always redirect stdin when running `pi -p` non-interactively: `pi -p "..." < /dev/null`.**

`pi -p` reads stdin even when the prompt is given as an argument. If stdin is an open pipe that
never reaches EOF — which is exactly what happens over `ssh host "script"`, or from a CI runner —
pi blocks forever with no output and no error. It looks identical to a hung model or a broken
config, and it wasted a long debugging detour on 2026-09-04: Ollama's own log showed *zero*
incoming requests during the "hangs", which is the tell. `< /dev/null` fixes it, and backgrounding
with `&` masks it (bash gives background jobs `/dev/null`).

## Skills in pi

pi does not read `.claude/skills/`. It scans `~/.pi/agent/skills/`, `~/.agents/skills/`,
`.pi/skills/` and `.agents/skills/`. This repo's `.pi/settings.json` points pi at the Claude Code
directory so both harnesses share one copy:

```json
{ "skills": ["../.claude/skills"] }
```

Project-local settings load **only after the project is trusted**, so this works with `--approve`
(per run) or after running `/trust` once in interactive pi (writes `~/.pi/agent/trust.json`).
Untrusted, pi silently sees no skills. Verified working: `pi -p --approve` lists `media-triage`,
`nixos-rebuild`, `ollama-model`.

Note that `~/.pi/agent/models.json` and `settings.json` are **not** managed by the flake, so they do
not sync between hosts the way this repo does.

## Notes

- `/var/lib/ollama/models` is root-only, so `plague` cannot run a second Ollama instance against the
  same store to A/B server settings. Comparisons require a rebuild.
- `OLLAMA_KEEP_ALIVE` is 30m. Ollama's 5m default makes an idle agent pay a multi-GB reload.
- Models tend to omit the trailing newline when writing files. Compare content, not bytes, when
  scoring a model's output — a strict `diff` against a file ending in `\n` will report false failures.
