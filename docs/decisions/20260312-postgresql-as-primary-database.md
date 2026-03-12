# ADR: PostgreSQL as Primary Database

**Date:** 2026-03-12
**Supersedes:** N/A
**Superseded by:** N/A

## Research Findings

### Dependency: PostgreSQL
- **Source:** https://www.postgresql.org/docs/current/
- **Key finding:** Mature, open-source RDBMS with strong support for JSONB, full-text search, custom types, and extensibility via extensions (e.g., PostGIS, pgvector)
- **Constraint:** None; PostgreSQL is broadly available on all major cloud providers and hosting environments

## Context

The project needs a reliable, general-purpose relational database for persistent storage. Requirements include ACID transactions, strong data integrity via foreign keys and constraints, support for structured and semi-structured data, and a mature ecosystem of tooling, libraries, and operational knowledge.

## Decision

We will use PostgreSQL as the primary database.

PostgreSQL provides the relational integrity, query expressiveness, and ecosystem maturity the project requires. Its broad adoption ensures strong driver support across languages, extensive documentation, and straightforward operational practices for backup, replication, and monitoring.

## Alternatives Considered

### MySQL / MariaDB
- **Pros**: Widely adopted, good read performance, large community
- **Cons**: Weaker support for advanced data types (JSONB, arrays, custom types); historically looser default strictness around data integrity (e.g., silent truncation); fewer built-in extensions
- **Why not chosen**: PostgreSQL's richer type system and stricter correctness defaults better fit our needs

### SQLite
- **Pros**: Zero-configuration, embedded, excellent for local development and small-scale use
- **Cons**: Single-writer concurrency model; no network-accessible server; limited support for concurrent production workloads
- **Why not chosen**: Not suitable for a multi-connection production service

### MongoDB
- **Pros**: Flexible schema, native document model, horizontal scaling via sharding
- **Cons**: Weaker transactional guarantees across documents; no relational integrity enforcement; query patterns diverge significantly from SQL
- **Why not chosen**: The data model is fundamentally relational; PostgreSQL's JSONB covers our semi-structured needs without giving up referential integrity

## Consequences

### Positive
- ACID transactions and referential integrity enforced at the database level
- Rich indexing options (B-tree, GIN, GiST, BRIN) for diverse query patterns
- JSONB support for semi-structured data without a separate document store
- Extensive ecosystem of ORMs, migration tools, and monitoring solutions across all major languages
- Available as a managed service on every major cloud provider (RDS, Cloud SQL, Azure Database, etc.)

### Negative
- Requires running and operating a database server (vs. embedded options like SQLite)
- Horizontal write-scaling requires more effort (logical replication, Citus, or application-level sharding) compared to databases designed for it natively

### Neutral
- Team already has operational familiarity with PostgreSQL

## References

- https://www.postgresql.org/docs/current/
- https://www.postgresql.org/about/featurematrix/
