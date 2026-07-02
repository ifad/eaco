# Eaco v2.0 — Project Tracker

> Working hub for the modernization effort. Mirrors the four GitHub issues
> (Phases 1–4) but is the **source of truth while we work**; GitHub issues are
> synced from here later (decision: track locally for now).

Last updated: 2026-06-26

---

## 1. What Eaco is (one-liner)

An **Attribute-Based Access Control (ABAC)** *authorization* framework for Ruby:
authorization decisions live in the **database** as per-record ACLs
(`designator → role`), not in code. You ask `actor.can?(:edit, document)` and
fetch `Document.accessible_by(user)` with a single indexed query.

## 2. Positioning (the "why now")

**Authentication ≠ Authorization.** Rails 8's built-in auth generator and Devise
answer *who are you?* (sessions, passwords, 2FA). Eaco answers *what can you do?*
They are **adjacent layers** — Eaco pairs *with* Devise / Rails 8 auth, it does
not compete with them. Rails 8 shipping auth pushes more apps to the
authorization question sooner, which is Eaco's space.

**Eaco's real peers** are Pundit / CanCanCan / Action Policy (all RBAC, code-defined).
Eaco's defensible niche vs them:

| Capability | Pundit / CanCanCan / Action Policy | Eaco |
|---|---|---|
| Model | RBAC (rules in code) | **ABAC (ACLs in data)** |
| Per-record, runtime-editable sharing | bolt-on / hand-rolled | **native** (`doc.grant :reader, :user, 42`) |
| "List everything user X can see" | N+1 / custom scopes | **one indexed hash-key query** |

**The moat = dynamic, per-record, end-user-managed permissions** (Google-Docs-style
sharing, multi-tenant org hierarchies) + efficient `accessible_by`. v2.0 messaging
must commit loudly to this niche instead of pitching a generic "authorization
framework" (which loses a head-to-head with Pundit on simple role apps).

**Honest boundaries (state these in docs):**
- Simple "admins vs users" apps → Pundit/Action Policy are lighter; use them.
- The rising alternative for ABAC/ReBAC is *externalized* authz (OpenFGA/Zanzibar,
  OSO/Cedar). Eaco's pitch vs those: "stay in your Postgres, no extra service,
  idiomatic Ruby." Name this boundary in the README.

## 3. Version targets (decided 2026-06-26)

- **Ruby floor:** 3.2 (matches Rails 8.0/8.1 minimum; lets us drop legacy shims).
- **Ruby ceiling:** 4.0, open-ended. (Ruby 4.0.0 shipped 2025-12-25; evolutionary,
  mostly backward-compatible — Box & ZJIT are experimental. Eaco audited clean
  against all 4.0 removals: no `cgi`, no `ObjectSpace._id2ref`, no leading-pipe
  `open`, no `Ractor`; uses `Set` only via public API.)
- **Rails:** 7.2, 8.0, 8.1.
- **Next release:** `2.0.0.beta1`.

### CI matrix

| Ruby | Rails |
|------|-------|
| 3.2  | 7.2, 8.0 |
| 3.3  | 8.0, 8.1 |
| 3.4  | 8.1 |
| 4.0  | 8.1 |

---

## Phase 1 — Modernization  → milestone `v2.0.0-beta`  (GitHub #1)

### 1.1 Rails 7.x/8.x compatibility
- [x] Railtie uses `ActiveSupport::Reloader.to_prepare` — *already present in `lib/eaco/railtie.rb`*
- [x] **AR adapter now supports Rails 7.0–8.1** — added compat modules `V70`–`V81`
  (`lib/eaco/adapters/active_record/compatibility/`); full suite green on AR
  7.2.3 / 8.0.5 / 8.1.3 under Ruby 4.0. *Was hard-failing "Unsupported Active
  Record version: 81".*
- [ ] Verify modern PG jsonb handling is optimal (works; revisit for GIN-index/perf in Phase 2)
- [x] Zeitwerk autoloader: **validated inside a real Rails 8.1 app boot** (throwaway `rails new --minimal` app in scratchpad, eaco via `path:`). Found & fixed two real bugs:
  - Railtie parsed rules directly in the initializer → `NameError` on any model reference under Zeitwerk (Rails 7+ forbids autoloading during boot). Now parses inside `app.config.to_prepare` (runs at boot + on each dev reload).
  - `rails db:create` crashed: `table_exists?` raises `ActiveRecord::NoDatabaseError` on modern Rails when the DB is missing; adapter schema check now rescues & skips.
  - Smoke test: 11/11 checks green (grant/revoke, `can?`, `accessible_by`, admin bypass, jsonb persistence, controller integration) in both lazy and eager-load boot. Note for docs/generator: rules file must use top-level constants (`::Document`) — bare `Document` resolves under `Eaco::` in the DSL.
- [x] Railtie uses `config.enable_reloading` (was deprecated `config.cache_classes`); dropped pre-7.x reloader fallback — *superseded: now a single `to_prepare` path, no reloading branch needed*
- [x] Remove deprecated Rails 3.x/4.x — *gemfiles + Appraisals trimmed; floor now Rails 7.2*

### 1.2 Ruby 3.x AND 4.0 compatibility  *(reworded — was "Ruby 3.x")*
- [x] **Suite green on Ruby 4.0.5** (local: RSpec 21/0, Cucumber 33/33 on Rails 7.2/8.0/8.1)
- [x] Ruby 3.4+ `Hash#inspect` spacing — specs now derive expectation from Ruby's own output
- [x] Ruby 4.0 Prism `SyntaxError` wording — relaxed feature expectation
- [x] Audit keyword-argument usage — no in-place issues; suite green on Ruby 4.0 is the signal
- [x] Added `# frozen_string_literal: true` across all of `lib/` (56 files); no string-mutation breakage, suite green
- [ ] Pattern matching where it improves the DSL (optional — not pursued)
- [x] Test on Ruby 3.2, 3.3, 3.4, 4.0 (CI matrix) — *local validation done on 4.0 only; CI covers the rest*

### 1.3 Dependency updates
- [x] Modernized Cucumber (3.2 → 11.x); rspec/yard current
- [x] Add `spec.required_ruby_version = '>= 3.2'` to gemspec
- [x] Removed `coveralls` (unmaintained) → plain `SimpleCov`; dropped dead Travis upload path
- [x] Migrate Appraisals → checked-in `gemfiles/` matrix *(Appraisals trimmed; see open decision on full removal)*

### 1.4 CI/CD modernization
- [x] Travis → GitHub Actions *(done earlier)*
- [x] New Ruby/Rails matrix (3.2–4.0 × 7.2–8.1) + fix `master`→`main` triggers
- [x] Automated gem releases — `.github/workflows/release.yml` via RubyGems Trusted
  Publishing (OIDC). **One-time maintainer setup:** register repo+workflow as a
  trusted publisher on rubygems.org before the first tagged release.

---

## Phase 2 — New Features  → milestone `v2.0.0`  (GitHub #2)

> **Reprioritized 2026-06-26:** weight toward **deepening the ABAC moat** over
> **breadth**. Adapters that just add another datastore (esp. MongoDB) are
> deprioritized; work that makes dynamic per-record ABAC + `accessible_by`
> better/faster/easier is promoted.

### Tier 1 — Deepen the moat (PRIORITIZE)
- [ ] **Hierarchical designators** (org → dept → team → user) — core to the multi-tenant/org ABAC story
- [ ] **OAuth/OIDC/JWT-claims designator** — harvest designators from tokens; modern auth integration, complements Devise/Rails 8 auth
- [ ] **PostgreSQL jsonb GIN indexes for `accessible_by`** — makes the killer feature actually scale; this *is* the moat
- [ ] **DX: Rails generator** for common setups — lowers adoption friction
- [ ] **DX: rake tasks for ACL inspection/debugging** + console helpers
- [ ] **DX: actionable error messages**

### Tier 2 — Breadth (DEPRIORITIZE / demand-gated)
- [ ] SQLite JSON1 adapter — *keep-ish:* low cost, lets people try Eaco without Postgres; good for dev/test
- [ ] MySQL/MariaDB JSON adapter — only if real demand
- [ ] Time-based designators (business hours) — good ABAC demo; candidate for plugin/cookbook rather than core
- [ ] IP/geo-location designators — same as above
- [ ] ~~MongoDB adapter~~ — **defer/drop** (was already a "stretch goal"); revisit only on concrete demand

---

## Phase 3 — Documentation & Education  (GitHub #3)

> Frame migration guides as **"graduation from Pundit/CanCanCan"** (your sharing
> needs outgrew RBAC), not "replacement". Lead every doc with the auth-vs-authz
> distinction.

### 3.1 Docs site
- [ ] Choose stack (GitHub Pages + VitePress/Jekyll)
- [ ] Getting-started guide
- [ ] Migration guide from Pundit/CanCanCan
- [ ] Full DSL reference with examples

### 3.2 Tutorials
- [ ] 1: Basic — protect a Document
- [ ] 2: Multi-role (owner/editor/reader)
- [ ] 3: Group-based team permissions
- [ ] 4: Google-Docs-style sharing  *(showcases the moat)*
- [ ] 5: ABAC for multi-tenant SaaS  *(showcases the moat)*
- [ ] 6: Migrating from Pundit to Eaco

### 3.3 Example apps
- [ ] Document management (Google Docs clone)
- [ ] Project management (Basecamp/Asana style)
- [ ] Multi-tenant SaaS with org hierarchy

### 3.4 Integration guides
- [ ] **Devise** integration *(positioning-critical: auth + authz combo)*
- [ ] Hotwire/Turbo patterns
- [ ] API-only Rails
- [ ] Testing authz with RSpec

---

## Phase 4 — Community & Sustainability  (GitHub #4)

### 4.1 Community
- [ ] Announcement blog post (lead with auth-vs-authz + the moat)
- [ ] Talk at a Ruby meetup/conference
- [ ] GitHub Discussions
- [ ] CONTRIBUTING.md + contribution guidelines

### 4.2 Maintenance
- [ ] GitHub Sponsors
- [ ] Documented release process
- [ ] Public roadmap (this file → published)
- [ ] Identify/mentor co-maintainers

---

## Open decisions / questions

- [x] ~~**Upgrade Cucumber 3.2.0 → 9.x?**~~ **DONE (2026-06-26):** upgraded to
  Cucumber 11.1.1. No step-definition/World changes were needed (the gem only
  uses `World do` + `Before do`). Dropped the unmaintained `yard-cucumber`
  plugin, which was the hard blocker (`cucumber < 4`). Banner silenced via
  `CUCUMBER_PUBLISH_QUIET` in CI. Green on Rails 7.2/8.0/8.1, Ruby 4.0.
- [ ] **Full Appraisal removal?** Currently trimmed Appraisals + checked-in gemfiles
  (both kept in sync). Decide whether to drop the `appraisal` dev dep entirely and
  hand-maintain gemfiles, or keep Appraisal as the generator.
- [x] ~~**Repo home:**~~ **DECIDED (2026-07-02):** `iamaestimo/eaco` is the
  maintained home. Gem republished as **`eaco-abac`** (the `eaco` name on
  rubygems.org is owned by ifad; name checked available). Require path stays
  `require "eaco"` (`gem "eaco-abac", require: "eaco"`). Gemspec renamed to
  `eaco-abac.gemspec`, homepage/badges/README all point at the fork; README
  carries a lineage note crediting ifad's original. First publish will claim
  the name via a *pending trusted publisher* on rubygems.org (no API key).
- [x] ~~`coveralls` replacement~~ **DONE:** now plain `SimpleCov`. Optional future:
  wire CI to upload LCOV to a coverage service (qlty/codecov) — no gem needed.
- [ ] When to actually tag `v2.0.0.beta1` (release workflow is in place; needs the
  rubygems.org trusted-publisher registration first). **ON HOLD pending the
  upstream outreach below.**
- [ ] **⚠ BLOCKING — upstream is stirring: ifad/eaco PR #24** (discovered
  2026-07-02). An ifad member (lleirborras) opened "Support Rails 8.1 / Ruby 4"
  on 2026-06-19 — motivation is their internal fleet upgrade (edoc, hermeshq,
  noobs, scriptoria depend on eaco). Open, unreviewed, unmerged as of today.
  - **Overlap with our Phase 1:** same core compat work; their railtie fix is
    the *identical* `app.config.to_prepare` approach (independent convergence).
  - **They have / we don't:** a single `Modern` fallback module for AR ≥ 7.0
    instead of per-version `V70`–`V81` copies — cleaner; adopt it later
    regardless of outcome (logged under Phase 2 cleanup below).
  - **We have / they don't:** `rails db:create` `NoDatabaseError` fix;
    real-Rails-8.1-app validation; clean version floor (they keep Ruby 2.7 /
    Rails 6.1, coveralls, yard-cucumber, Cucumber ~9.2); Cucumber 11; trusted
    publishing release automation; README repositioning; Phase 2 ABAC roadmap;
    stated intent of long-term community maintenance.
  - **Risk:** ifad owns the `eaco` rubygems name. If they merge + release 2.x,
    the "rescue of an abandoned gem" launch story collapses and `eaco-abac`
    becomes a confusing parallel fork.
  - **Plan (decided 2026-07-02):** comment on their PR #24 — congratulate,
    note the identical railtie fix, offer to upstream the `db:create` fix and
    the rest, ask about release plans and co-maintainership / gem ownership.
    **Timebox: 2 weeks** (until ~2026-07-16). Outcomes: (a) maintainership →
    inherit the real name, retire `eaco-abac` plan; (b) they release, we
    contribute upstream; (c) silence → launch `eaco-abac` with the honest
    "offered upstream first" story. Draft comment prepared; posting is
    Aestimo's call, in his voice.

## GitHub issue sync notes (apply later when we sync)

- **#1:** rename "1.2 Ruby 3.x Compatibility" → "Ruby 3.x **and 4.0**"; change
  "test with 3.1, 3.2, 3.3" → "3.2, 3.3, 3.4, 4.0"; strengthen "remove 3.x/4.x"
  to "floor = Rails 7.2 / Ruby 3.2".
- **#2:** restructure into Tier 1 (moat) / Tier 2 (breadth) as above; mark MongoDB
  deferred.

## Changelog of this effort

- **2026-06-26:** Created tracker; repositioned README (auth-vs-authz + comparison);
  Phase 1 mechanics — trimmed gemfiles/Appraisals to Rails 7.2/8.0/8.1, added
  Rails 8.0/8.1 gemfiles, rewrote CI matrix (Ruby 3.2–4.0), fixed `master`→`main`
  triggers, added `required_ruby_version` + version bump to `2.0.0.beta1`.
- **2026-06-26 (cont.):** Ran the suite locally on Ruby 4.0.5 + PG 18 and made it
  green on Rails 7.2/8.0/8.1: added AR compat modules `V70`–`V81` (the big one —
  adapter rejected AR > 6.1), added `ostruct` dev dep, fixed Ruby 3.4 `Hash#inspect`
  and Ruby 4.0 Prism `SyntaxError` test expectations, removed `.config/cucumber.yml`
  (Cucumber 3.x ERB-profile crash on Ruby 3.4+). Result: RSpec 21/0, Cucumber 33/33.
- **2026-06-26 (housekeeping):** Upgraded Cucumber 3.2 → 11.x (dropped `yard-cucumber`).
  Replaced `coveralls` with plain SimpleCov + removed dead Travis path; railtie
  `cache_classes` → `enable_reloading`; `frozen_string_literal` across all 56 `lib/`
  files; added `release.yml` (RubyGems Trusted Publishing). Suite re-validated green
  on all three gemfiles. **Phase 1 complete bar the real-Rails-app Zeitwerk check.**
- **2026-07-02 (smoke test):** Built a throwaway Rails 8.1 app and installed eaco
  from the local checkout. Caught & fixed two real bugs: railtie must parse rules
  in `to_prepare` (Zeitwerk forbids model autoload during boot) and the adapter's
  `table_exists?` check must rescue `NoDatabaseError` so `rails db:create` works.
  Smoke test 11/11 green (lazy + eager-load boot); gem suite re-validated green on
  all three gemfiles. **Phase 1 code work fully complete.**
- **2026-07-02 (PR):** Opened PR #5 (`main` ← `phase-1-modernization`,
  https://github.com/iamaestimo/eaco/pull/5). GitHub Actions CI green on all
  6 matrix cells (Ruby 3.2–4.0 × Rails 7.2/8.0/8.1, PG 16). Merged by Aestimo.
- **2026-07-02 (rename):** Gem renamed to `eaco-abac` (PR #6,
  https://github.com/iamaestimo/eaco/pull/6): gemspec → `eaco-abac.gemspec`,
  homepage/badges/links → this fork, README relaunch refresh (lineage note,
  jsonb migration, `::Model` constant requirement, `before_filter` →
  `before_action`). Suite re-verified green. RubyGems account created;
  pending-trusted-publisher registration deferred (reservation expires in
  days — create it right before merge+tag).
- **2026-07-02 (upstream):** Discovered ifad/eaco PR #24 (Rails 8.1/Ruby 4
  support by an ifad member, opened 2026-06-19). Beta tag put ON HOLD;
  outreach comment drafted for Aestimo to post. See the blocking item under
  *Open decisions*. Cleanup candidate regardless of outcome: replace our
  per-version `V70`–`V81` compat copies with their single `Modern` fallback
  module for AR ≥ 7.0.
