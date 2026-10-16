# Startup and catalogue loading

The October 15, 2026 change applies the video's caching and parallel-loading
ideas while retaining the application's authentication contract. It does not
establish a 10x speedup or a 0.2-second launch time.

- Firebase and text-size preference loading no longer block `runApp`. Push
  initialization waits for Firebase and registers an already activated account
  if account restoration finishes first. Messaging failures remain optional.
- Supabase initialization, session restoration, account/profile validation and
  role/status gates remain required before private pages mount. A remembered
  account alone never authorizes a private page. Expired and anonymous sessions
  cannot read the catalogue snapshot.
- The buyer catalogue's first page (24 products plus one pagination sentinel)
  is saved locally after a successful request. Its inventory summaries and farm
  details now load concurrently after the product list arrives. Campaign product
  hydration uses the same parallel path. RPC names, bound parameters, grants,
  rate limits, and marketplace authorization contracts are unchanged.
- One SharedPreferences JSON snapshot is tagged with the authenticated owner,
  page size and save time. It contains marketplace rows and farm details only,
  including account-specific sale prices; no credentials, wallet, documents,
  messages or order history are added. It is valid for 15 minutes, ignored if
  malformed/future-dated, and removed on account-state reset/logout/switch.
- Snapshot reads and network refresh start independently. Existing products
  remain visible while refreshing and on failure, with updating/retry copy.
  Pagination waits for the fresh first page. A late disk result cannot replace
  newer network results. Generation and owner checks reject late responses;
  serialized writes and reset invalidation prevent pending writes resurrecting
  a cleared snapshot. Cached values do not authorize purchases or mutations.

Verification: 42 focused Flutter regression tests passed, covering catalogue
pagination/mapping, authentication, role gates, account switching, logout and
expired-session navigation. After adding a same-account re-login race guard,
all 10 cache/controller tests passed (nine overlap the earlier suite). Modified
application sources are 34–197 physical lines, with no prohibited inline styles.
Final Dart analysis passed after the race guard; formatting and whitespace
checks also passed.

Device cold launch, slow-network timings, hosted database behavior and release
APK startup have not been measured by this change. No database migration or
authorization policy was changed. Benchmark profile/release builds on the same
device, account and network before making a numerical performance claim.
