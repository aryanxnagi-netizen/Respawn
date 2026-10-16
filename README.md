# RESPAWN — mobile-first gaming social prototype

**Tagline:** Find Your Squad. Build Your Legacy.

This is a runnable, dependency-free web prototype designed for mobile browsers. It includes a premium dark UI, responsive navigation, a deterministic Squad Finder, sample feed, FRAGZ demonstration cards, event listings, local profile customization, demo wallet, missions, notifications, search, privacy preferences, and PWA shell files.

## Important status
This is **not yet a production social network**. There is no real authentication, remote database, hosted media, realtime chat, verified rank integration, server-side coin ledger, push notification service, or protected admin backend. Sample players, posts, and events are labelled as demo content. Most interactions save to the current browser's local storage only. Do not enter passwords or sensitive personal information.

## Run on Android
1. Download and extract `respawn-project.zip`.
2. For easiest phone-only use, upload the extracted folder to a static host that supports HTTPS (for example, a free static-site host; account/terms may vary), or use a browser-based code workspace.
3. Publish the folder with `index.html` at the site root. No build step or package installation is required.
4. Open the HTTPS URL in Chrome on your Samsung phone.
5. In Chrome, open the three-dot menu and choose **Add to Home screen** or **Install app** if offered.

PWA service-worker caching requires HTTPS or localhost; opening `index.html` directly from a file manager may not enable installation/offline behavior.

## Run locally on a computer
Serve this directory with any static HTTP server, e.g. `python -m http.server 8000`, then open `http://localhost:8000`. This is optional; no terminal is needed to use a hosted static copy.

## Included files
- `index.html` — app shell and navigation
- `styles.css` — mobile-first design system
- `app.js` — local demo state and interactions
- `manifest.webmanifest`, `sw.js`, `icon.svg` — PWA shell
- `supabase/schema.sql` — starter relational schema and RLS policy baseline
- `.env.example` — placeholder public client config only

## Squad matching
The compatibility score is deterministic, weighted, and transparent:
- Game: 25%
- Rank: 20%
- Role: 15%
- Language: 10%
- Region: 10%
- Availability: 10%
- Playstyle: 10%

The current demo uses game/style/language/availability/microphone as hard filters and then ranks the remaining sample players. The matching result is a heuristic, not an outcome probability. Weights and score function are in `app.js`.

## Backend path
A sensible next step is Supabase (Postgres, Auth, Storage, and Realtime), after creating a project and configuring it. Free-tier quotas and availability can change; check current plan limits before committing. The current app does not consume the `.env.example` variables. Never expose a Supabase service-role key in a frontend app. Use RLS and server-side functions for coin rewards, purchases, tournament verification, moderation, and admin actions.

The starter SQL is intentionally a baseline, not a complete production schema or security audit. Test policies with separate user accounts before storing real user data.

## Tests
A dependency-free `tests/squad-score.test.js` includes score-weight and deterministic-ranking checks. Run with Node.js using `node --test tests/squad-score.test.js`. Browser interactions have not been tested on a real Android device in this environment.

## Public launch checklist
- Real authentication and account recovery
- Database migrations reviewed and tested with RLS enabled
- Server-authorized profiles, posts, follows, requests, and messages
- Object storage and upload limits for images/video
- Rate limiting, reporting, blocking, moderation queue, audit logs
- Atomic server-side coin ledger and idempotent reward claims
- Tournament registration and verified result workflow
- Age-appropriate privacy defaults and legal review for applicable Indian privacy/child-safety requirements
- Accessibility, performance, security, and device QA
