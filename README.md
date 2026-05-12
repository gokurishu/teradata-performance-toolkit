# Teradata Performance Toolkit

**Kanishk Trivedi** · Teradata DBA & Performance Engineer  
[GitHub](https://github.com/gokurishu) · kanishk.trivedi@delta.exchange

---

## About

A curated collection of production-grade Teradata SQL queries built and battle-tested in a large-scale enterprise EDW environment in the telecom industry. Covers the full Teradata DBA toolkit: performance monitoring, space management, workload analysis, table optimization, and system maintenance.

---

## Skills Demonstrated

| Area | Technologies |
|---|---|
| Query Performance Tuning | DBQL, AMPCPUTime, Skew Factor, ImpactCPU |
| Workload Management | TASM, AWT buckets, concurrency analysis |
| Storage Optimization | MVC (Multi-Value Compression), PPI, partition elimination |
| System Monitoring | ResUsageSpma, ResUsageSldv, CPU/IO Heatmaps |
| Statistics & Maintenance | Stale stats detection, unused stats cleanup, decommission |
| Space Management | DBC.DiskSpace, spool usage, skew-adjusted space |
| Reporting | Tableau integration queries, weekly ops dashboards |

---

## Repository Structure

```
.
├── performance-monitoring/     # CPU/IO heatmaps, AWT workload analysis
├── space-management/           # Database, spool, and DL space queries
├── dbql-query-logging/         # DBQL analysis: bad queries, long runners, object usage
├── table-analysis/             # PI/PPI skew, MVC, stats, table growth
├── session-system/             # Profiles, sessions, TASM, throttle
├── maintenance/                # Decommission, purging, runtime overflow
├── reports/                    # Weekly ops reports, Tableau utility queries
└── csr/                        # CSR real-time process monitoring queries
```

---

## Query Categories

### Performance Monitoring
Real-time and historical CPU/IO utilization analysis using `dbc.ResUsageSpma` and `dbc.ResUsageSldv`. Includes per-node heatmap queries used in Tableau dashboards, AWT workload breakdown, and response time profiling.

| File | Description |
|---|---|
| `cpu-heatmap.sql` | Per-node CPU utilization heatmap (avg and max) over 30 days |
| `io-heatmap.sql` | Disk I/O utilization using 80th percentile bucketing |
| `tdheatmap.sql` | Combined system heatmap for Tableau visualizations |
| `tdheatmap-refresh.sql` | Incremental refresh logic for the heatmap dataset |
| `awt-by-workload.sql` | AWT (Active Worker Thread) distribution by workload |
| `tableau-awt.sql` | AWT trend query optimized for Tableau consumption |

---

### Space Management
Queries for tracking and forecasting Teradata storage consumption across databases, including skew-adjusted space calculations and spool monitoring.

| File | Description |
|---|---|
| `database-space.sql` | Max, current, and free perm space per database |
| `dl-perf-space.sql` | Space query scoped to DL_PERF work area |
| `spool-space.sql` | Spool usage monitoring |
| `top-10-databases.sql` | Top 10 databases by current perm usage |
| `monthly-idw-space.sql` | Month-over-month IDW space trend |

---

### DBQL & Query Logging
Deep-dive DBQL queries for identifying top CPU consumers, long-running queries, and query patterns by object, user, or workload using `PDCRINFO.dbqlogtbl_hst` and related tables.

| File | Description |
|---|---|
| `dbql.sql` | Full DBQL pull with query band, skew factor, impact CPU |
| `dbql-30-days.sql` | 30-day historical DBQL summary |
| `dbql-obj-30-days.sql` | Object-level query logging (table/column access patterns) |
| `dbql-without-overflow.sql` | DBQL filtered to exclude overflow/spool errors |
| `current-dbql.sql` | Live DBQL from `dbc.dbqlogtbl` (current day) |
| `find-bad-high-consumption-query.sql` | Identify top CPU/spool offenders |
| `queries-gt-30-minutes.sql` | Long-running query detection (over 30 min elapsed) |

---

### Table Analysis & Optimization
Comprehensive queries for analyzing Primary Index skew, PPI efficiency, Multi-Value Compression savings, stale statistics, and table growth trends.

| File | Description |
|---|---|
| `pi-skew-scope.sql` | PI skew analysis scoped by database/table |
| `ppi-scope.sql` | PPI partition-level analysis |
| `ppi-definition.sql` | PPI definition extraction from system catalog |
| `skew-of-pi.sql` | AMP-level row distribution to identify hot AMPs |
| `size-of-table-with-skew.sql` | Table size adjusted for skew factor |
| `mvc.sql` | Multi-Value Compression analysis |
| `column-usage.sql` | Column-level access frequency from DBQL |
| `stale-table-query.sql` | Tables with stale or missing statistics |
| `unused-stats.sql` | Statistics defined but never used by the optimizer |
| `stats-post-implementation.sql` | Validate statistics after collect |
| `table-growth.sql` | Row count and perm growth over time |
| `step-table.sql` | Query step table analysis for plan inspection |

---

### Session & System Management
Queries for inspecting active sessions, user profiles, throttle rules, and TASM workload concurrency.

| File | Description |
|---|---|
| `check-profile.sql` | User profile details (spool limit, priority, etc.) |
| `session-info.sql` | Active session details |
| `system-details.sql` | Node configuration and system metadata |
| `system-throttle-query.sql` | Active throttle rules and their conditions |
| `tasm-concurrent-and-bucket.sql` | TASM concurrency by workload bucket over time |

---

### Maintenance & Operations
Scripts used for table decommissioning workflows, data purging, and runtime overflow investigations.

| File | Description |
|---|---|
| `decommission-in-group.sql` | Identify tables in scope for group decommission |
| `decommission-complete.sql` | Validate decommission completion |
| `table-usage-decommission.sql` | Check table last-access before decommission |
| `purging.sql` | Data purging template |
| `runtime-overflow.sql` | Identify queries causing runtime spool overflow |

---

### Reports & Dashboards
Weekly operational reports and Tableau-compatible utility queries used for stakeholder reporting.

| File | Description |
|---|---|
| `weekly-reports.sql` | Weekly DBA operations summary |
| `database-insights.sql` | Comprehensive database health and usage insights |
| `tableau-utility.sql` | Utility queries feeding Tableau workbooks |

---

### CSR (Real-Time Process Monitoring)
Queries for monitoring CSR ETL process status, step progress, CPU consumption, and elapsed time used for real-time production support.

| File | Description |
|---|---|
| `csr-queries.sql` | CSR process status, steps, and CPU consumption |

---

## Experience Context

These queries were built for a large-scale **Teradata EDW** environment supporting:
- Hundreds of terabytes of data across multiple databases
- Thousands of concurrent queries across business-critical workloads
- Real-time Tableau dashboards consumed by operations and engineering teams
- Weekly performance reviews and capacity planning

---

*All queries use PDCRINFO historical tables and DBC system views, standard Teradata DBA tooling.*
