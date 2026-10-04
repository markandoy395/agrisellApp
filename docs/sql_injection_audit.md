# Database query parameterization audit - 2026-10-04

The app's Flutter database calls and notification Edge Function use Supabase's
structured table/filter methods and RPC parameter objects. No application SQL
string is constructed from user input. The inventory is `.query-audit.txt`.
There is no separate ORM, raw PostgreSQL driver, SQLite database, or Firestore
database in the application to convert.

The audit covered client filters, RPC names/arguments, database function bodies,
migration dynamic SQL, and the deployed public/private function definitions.
Static SQL and PL/pgSQL queries use parameters/variables as values; concatenating
a search pattern or message value inside a static statement does not turn that
value into executable SQL. Runtime SQL construction was found only in the rider
dashboard, and it already bound its rider ID through `EXECUTE ... USING`.

The refactor makes runtime query behavior stricter:

- Rider dashboard earnings use static SQL against `public.delivery_payments`.
  Its existing caller-derived rider ID and result fields are preserved. The
  historical compatibility table choice and dynamic execution are removed.
- Voucher lookup uses `current_checkout_voucher(p_code)` with a JSON RPC argument
  and static case-insensitive equality. `%`, `_`, `*`, quotes, comments, and SQL
  fragments remain literal code text. They cannot expand the match or execute.
  Missing, disabled, or ambiguous duplicate codes return no voucher.
- The public voucher wrapper invokes a private implementation with a fixed
  schema and query. It rejects missing/anonymous callers and returns only the
  published enabled campaign fields needed by checkout. Existing RPC-only
  catalogue access is preserved without granting direct table access.

Schema migration SQL still uses controlled dynamic DDL. Table/column identifiers
are quoted with `%I` or come from PostgreSQL `regclass`/`regprocedure` objects.
Policy bodies, role lists, and wrapper templates come from fixed migration
definitions or database metadata, never request values. Historical applied
migrations are preserved; the new migration changes the current implementation.

PostgreSQL documents both [automatic parameter substitution in static PL/pgSQL
and parameter binding with EXECUTE USING](https://www.postgresql.org/docs/17/plpgsql-statements.html).
Identifiers cannot be bound as ordinary values; identifier quoting remains
appropriate for controlled schema migrations.

## Verification

- All 8 Flutter lookup and existing deals/voucher regressions passed. Mock HTTP
  tests inspect actual request bodies for SQL fragments and punctuation and
  verify they remain one literal RPC argument, with no raw filter expression.
- Targeted Dart analysis found no issues. Formatting and whitespace checks
  passed. The two application sources are 16 and 169 physical lines and contain
  no prohibited inline styling.
- A hosted rolled-back preflight compared the old/new dashboard JSON for an
  existing rider in the same transaction and found identical output.
- `supabase/tests/sql_injection_boundary.sql` compares hostile voucher values to
  static literal equality, checks an ordinary existing code when available,
  rejects anonymous access, and asserts application runtime functions have no
  dynamic `EXECUTE` statements. It does not change application records.
- The migration deployed successfully to the linked hosted database. The
  injection test and the existing authentication and application-table RLS
  assertions all passed after deployment. Docker was unavailable for the CLI's
  optional local catalog cache; remote deployment and checks completed.

The database change is `20261003133000_parameterize_runtime_database_queries.sql`,
after the previous ownership/support repair migrations. The updated client
requires its new voucher RPC. Run the injection check and the existing
authentication/RLS assertions after deploying or changing database functions.
Keep future user data in structured SDK arguments or SQL parameters; never add
a general-purpose SQL execution RPC or concatenate input into command text.
