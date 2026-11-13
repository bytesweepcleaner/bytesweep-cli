# ByteSweep for AI assistants: `bsweep mcp`

`bsweep mcp` is a [Model Context Protocol](https://modelcontextprotocol.io) server. Claude
Desktop, Claude Code, Cursor, VS Code and any other MCP client can use it to look at a machine
(why the disk is full, what can be cleaned, health, updates, services, databases...) and to help
clean it, with the same rules as the command line and the app.

- **Transport:** stdio, JSON-RPC 2.0, one message a line. Protocol `2025-06-18`; `2024-11-05`,
  `2025-03-26` and `2025-11-25` are answered too. Methods: `initialize`, `ping`, `tools/list`,
  `tools/call`, `notifications/cancelled` (stops a running look); `resources/list` and
  `prompts/list` answer empty lists. Hand-written (`internal/mcp`), no new dependency.
- **Free.** Changes need administrator rights, exactly as `bsweep` on the command line.

## Set it up

`bsweep mcp config` prints the setup for every assistant; name one to get just that. Add
`--allow-changes` to let the assistant apply a plan after the person's yes, and `--json` for a
program to read (the desktop apps).

### Claude Code

    bsweep mcp config claude-code
    claude mcp add --scope user bsweep -- /usr/local/bin/bsweep mcp

With changes (Linux and macOS: changes need root, so it starts through `sudo -n`, which never
asks for a password):

    claude mcp add --scope user bsweep -- sudo -n /usr/local/bin/bsweep mcp --allow-changes

and let that user run bsweep without a password: `sudo visudo -f /etc/sudoers.d/bsweep`, add
`USER ALL=(root) NOPASSWD: /usr/local/bin/bsweep`. Without that line, looks and plans work and
`apply_plan` answers "needs administrator rights".

### Claude Desktop

`bsweep mcp config claude-desktop` prints the file and the JSON. Merge it into the file's
`mcpServers` (keep the others), then quit and reopen Claude Desktop:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

```json
{ "mcpServers": { "bsweep": { "command": "/usr/local/bin/bsweep", "args": ["mcp"] } } }
```

The path is the absolute path of the bsweep that printed it: Claude Desktop starts programs
with a short PATH, so a bare `bsweep` may not be found.

**A server over SSH.** Claude Desktop on a laptop can drive bsweep on a server: the stdio
crosses SSH unchanged. Use a key (no password prompt) and:

```json
{ "mcpServers": { "office": { "command": "ssh",
  "args": ["-T", "-o", "BatchMode=yes", "deploy@203.0.113.10", "sudo -n bsweep mcp"] } } }
```

### Cursor and VS Code

- Cursor: `~/.cursor/mcp.json`, the same `mcpServers` JSON (`bsweep mcp config cursor`).
- VS Code: `code --add-mcp '{"name":"bsweep","command":"/usr/local/bin/bsweep","args":["mcp"]}'`,
  or `.vscode/mcp.json` with `{"servers": {"bsweep": {"type": "stdio", "command": ..., "args": ["mcp"]}}}`
  (`bsweep mcp config vscode`).

### Windows

No sudo: an assistant started normally can look and plan; to apply plans, start it with Run as
administrator and add `--allow-changes`.

## The tools

Every tool runs this same bsweep program with a fixed list of words, built from checked values,
plus `--json`, and answers with that command's JSON (as in `desktop-contract.md`). Never a
shell, never SQL, never a command line the model wrote. Paths must be absolute; no value may
start with `-`; ages (`7d`), sizes (`100M`), groups, counts and service names are checked before
anything runs; unknown arguments are refused. Answers over 512 KB are cut, with a note to ask for
less.

### Looks (read only, free)

| Tool | Runs | Use it for |
|---|---|---|
| `summary` | `summary` | start here: disks, what safe rules can free, health counts, updates, one CPU/memory sample |
| `why` | `why` | the fullest disk and why, in sentences |
| `health` | `health` | every finding with `about`, `risk`, `steps`, `action` |
| `check` | `check` | what monitoring would alert on |
| `drives` | `drives` | disk hardware health |
| `report` | `report` | everything at once (large) |
| `top` | `top [PATH] --dirs N\|--files N [--inodes]` | the largest folders or files |
| `find` | `find PATH [--larger] [--older] [--newer] [--name]` | files to pick for `plan_rm` |
| `dupes` | `dupes [PATH...] [--min] [--limit]` | copies, largest saving first |
| `clean_list` | `clean --list [--group] [--older]` | items the rules found, with ids for `plan_clean` |
| `logs` | `logs` | logs that can be cleared |
| `undo_list` | `undo` | what waits in Undo, ids for `plan_undo_restore` |
| `updates` | `updates [--security]` | waiting updates (refreshes lists: up to 2 minutes) |
| `services` | `services [--failed]` | services, failed first |
| `backups` | `backups` | backups found and when they last worked |
| `maintain`, `maintain_reports` | `maintain`, `maintain reports [--limit]` | the maintenance plan, window and past runs |
| `sites`, `databases`, `jobs`, `logins`, `sharesafe`, `ports`, `startup`, `apps`, `sleep` | the same command | server and machine checks |
| `stats`, `stats_history` | `stats [--detail]`, `stats --history [--since] [--points]` | CPU and memory now, and recorded history |
| `grown` | `grown [--days]` | what grew |
| `restart_needed` | `reboot` (no `--yes`, so only the look) | does it need a restart, and why |
| `forecast` | `forecast [--disk PATH] [--days N]` | when each disk will be full at this pace (exit 1/2 when soon) |
| `snapshots` | `snapshots [--tool T]` | system snapshots (Time Machine, restore points, Timeshift, Snapper, ZFS...), sizes, which is newest |
| `backup` | `backup` | the backup plans ByteSweep set up (restic), last run, next run |
| `backup_list` | `backup list ID` | the copies a plan keeps, ids for `plan_backup_restore` |
| `fleet_status` | `fleet status [--hosts a,b \| --tag T] [--sort]` | every saved server at once, over SSH |
| `fleet_history` | `fleet history [--limit]` | past fleet checks and runs |
| `audit_log` | `log [--since]` | every change, who made it (`mcp` for this server) |
| `about` | `version` | version, OS, root or not |

Exit 1 and 2 (warning, critical) still answer with the JSON, plus one line saying so.

### Changes: plan, then apply

| Plan tool | Previews | Applied with `--yes` |
|---|---|---|
| `plan_clean` | `clean ID...`, `clean --safe [--group G]`, `clean --group G --older AGE` | items go to Undo where they can; never `--now` |
| `plan_rm` | `rm PATH...` | to Undo for 7 days; never `--now` |
| `plan_logs_clear` | `logs clear --older 7d [--docker] [--live]` | can't be undone (the preview says each file) |
| `plan_undo_restore` | `undo restore ID` | puts it back |
| `plan_updates_install` | `updates install [--security]` | through the package managers; nothing restarts |
| `plan_services_restart` | `services restart NAME` | SSH, the network, logins and the system manager are refused |
| `plan_maintain_run` | `maintain run` | the saved plan's steps, now |
| `plan_snapshots_remove` | `snapshots remove ID... [--keep-newest N]` (N 1 to 100) | through the tool that made each; no Undo; the newest of each group always stays |
| `plan_snapshots_thin` | `snapshots thin [--tool T] [--keep-newest N]` (N 1 to 100) | all but the newest N of each group |
| `plan_backup_run` | `backup run [ID]` | a copy now, then old copies thinned by the plan's keep rule |
| `plan_backup_restore` | `backup restore ID SNAPSHOT\|latest --to DIR [--path P]` | only into a new or empty folder (checked before the plan, and by bsweep) |
| `plan_fleet_run` | `fleet run ACTION [NAME] (--hosts a,b \| --tag T \| --all)`, ACTION clean-safe, logs-clear, updates-security, maintain-run, services-restart | one server at a time, stops at the first failure |
| `apply_plan` | | runs one plan by its token |

**Not offered over MCP**, so the person does them in the app or on the command line:

- restarting a machine: `reboot`, and `plan_maintain_run` / `plan_fleet_run maintain-run` are
  refused (no token) when a plan has `reboot-if-needed`, checked again at apply;
- `--now` (no Undo), removing apps, stopping programs, `undo free`, settings changes;
- `snapshots remove/thin --keep-newest 0 --i-understand` (removing the last snapshot of a group:
  `keep_newest` is 1 to 100) and `snapshots resize`;
- `backup add`: it makes a new secret password and shows it once, which belongs on the person's
  screen, not in a chat transcript;
- `backup remove` (and `--forget-data`, which deletes every copy) and `backup restore --in-place`
  (over today's files);
- `fleet run updates-all`: every update, majors and kernels included, on many servers in one go is
  the riskiest fleet action and the one most likely to need a person watching; `plan_updates_install`
  still installs all updates on this one machine, after its preview.

**Fleet and sudo.** `fleet` runs on the watching machine with that user's saved servers
(`bsweep.yml`) and SSH keys, and needs no local root: each server's own `sudo -n` decides. Start the server for fleet work **without** sudo (`bsweep mcp --allow-changes`); under sudo
it would read root's saved servers instead.

## Safety model

The ecosystem's lifecycle, with the person in the middle:

1. **Discover / analyze**: looks (`summary`, `why`, `clean_list`...). Nothing changes.
2. **Plan / preview**: a `plan_*` tool runs the command without `--yes`, which in bsweep is
   always a preview (`"dryRun": true`). Before that, every path in `plan_rm` is resolved (links
   in its folder followed) and checked with `internal/undo`'s protected-path rules, the same as
   `bsweep rm`: system folders, databases' data, container stores, mounted disks, the Undo store
   and the config's `keep` list are refused before any plan exists. Database internals are never
   removed as files; `databases` only explains each engine's own commands.
3. **Approve**: the answer has the preview, `willRun` (the exact command line), a `token` that
   lasts 15 minutes, and a `next` sentence telling the model to show the preview and wait for the
   person's yes. MCP clients also ask the person before each tool call (`apply_plan` is marked
   `destructiveHint`).
4. **Execute**: `apply_plan(token)`:
   - refuses unless the server was started with `--allow-changes`, saying how to switch it on
     (`bsweep mcp config ... --allow-changes`) or to run `willRun` by hand. Nothing runs.
   - a token runs once, and an unknown or old token is refused.
   - runs the preview again; if what it would change differs from what the person saw (ids,
     paths, names, steps, commands; sizes and times may move), nothing runs and a new plan comes
     back to show.
   - runs exactly the planned words plus `--yes`, one change at a time. The root checks are bsweep's own: exit 5 comes back as "needs administrator rights", in words.
5. **Verify**: the command's own result JSON (`cleaned`, `failed`, `freed`, `undo`); `undo_list`
   shows what can be put back.
6. **Audit**: the command writes its usual entry to ByteSweep's audit log with user `mcp`, and the
   server adds one more, action `mcp`: `TOKEN: bsweep ... --yes`, with what it freed or the error.
   `bsweep log` and the `audit_log` tool show both.

## A real session (lima VM, Debian, 2026-11-09)

`~/agent-mcp/bsweep` (a test build), driven by a script over stdio:

```
initialize -> 2025-06-18 {'name': 'bsweep', 'title': 'ByteSweep CLI', 'version': '1.1.0-test+72119df5b'}
tools/list -> 40 tools
plan_rm /etc            isError=True: Refused, nothing planned: /etc can't be cleaned: /etc is protected: the system or a database depends on it.
plan_rm /var/lib/mysql  isError=True: Refused, nothing planned: ... protected ...
(bsweep mcp)                  plan_rm old-export.log -> token; apply_plan -> "Changes are switched off ... --allow-changes ... Nothing was changed."
(sudo -n bsweep mcp --allow-changes)
                              plan_rm -> apply_plan: {"failed": [], "items": [...3002368...], "undo": true}; the file is gone
                              undo_list -> plan_undo_restore -> apply_plan: the file is back
                              plan_services_restart ssh.service -> refused: restarting SSH can end the login you use
bsweep log:
  mcp  rm            /home/alex.guest/agent-mcp/real/old-export.log           2.9 MB
  mcp  mcp           plan-22f9...: bsweep rm /home/.../old-export.log --json --yes
  mcp  undo restore  /home/alex.guest/agent-mcp/real/old-export.log
  mcp  mcp           plan-c577...: bsweep undo restore 18e647d970411d3a --json --yes
```

`go test ./cmd/bsweep -run MCP` drives the server over in-memory pipes the same way; run as root it also does the real clean to Undo and the restore.

### Second session (2026-11-09, after forecast, snapshots, backup and fleet were merged)

51 tools. As root (`sudo -n bsweep mcp --allow-changes`) with a throwaway plan `b1` made by hand
(`backup add`, not over MCP): `forecast` (not enough history yet, `switchOn` timer on);
`snapshots` (none on the VM); `plan_snapshots_thin` (empty preview); `keep_newest: 0` refused;
`plan_backup_run b1` → apply: `ok: true`, a copy made; `backup_list b1`; `plan_backup_restore` to
`/`, to the non-empty source folder and with `in_place` all refused before any plan; to a new folder
→ apply: 2 files back under it. As the user, against the VM itself as `web1`/`web2`:
`fleet_status`; `plan_fleet_run updates-all` and one without servers refused; `logs-clear` on web1
→ apply: done, in `fleet_history`; `maintain-run` on tag prod planned (no restart step there).
`bsweep log` has `backup run`, `backup restore` and the server's `mcp` lines, all user `mcp`.

## Not tested

Claude Desktop, Cursor and VS Code themselves (the setup JSON follows their documented formats);
the SSH form for a remote server; Windows and macOS runs of the server (they build); applying
`plan_updates_install` and `plan_maintain_run` for real (previews only on the shared VM);
`plan_snapshots_remove`/`thin` with real snapshots (the VM had none at the time); fleet runs other
than logs-clear.
