# Contributing to Teradata Performance Toolkit

Contributions are welcome. If you have a useful Teradata query, an improvement to an existing one, or a fix, feel free to open a pull request.

## How to Contribute

1. Fork this repository
2. Create a branch: `git checkout -b add/your-query-name`
3. Add your query to the relevant folder:
   - `performance-monitoring/` - CPU, IO, AWT analysis
   - `space-management/` - database, spool, perm space
   - `dbql-query-logging/` - DBQL history, bad queries, long runners
   - `table-analysis/` - skew, PPI, MVC, stats, growth
   - `session-system/` - sessions, profiles, TASM, throttle
   - `maintenance/` - decommission, purging, overflow
   - `reports/` - weekly ops, dashboards, Tableau
   - `csr/` - real-time process monitoring
4. Use `.sql` extension and a lowercase hyphenated filename (e.g. `cpu-skew-by-node.sql`)
5. Add a comment at the top of the file describing what the query does
6. Update the relevant section in `README.md` with a one-line description
7. Open a pull request with a clear title and description

## Guidelines

- Queries must be valid Teradata SQL
- Do not include real table names, usernames, or data from proprietary systems
- Replace sensitive identifiers with placeholders like `your_database`, `your_table`
- One query (or closely related set) per file
- Keep filenames consistent with the naming convention already in the repo

## Questions

Open an issue if you have a question or want to suggest a new category.
