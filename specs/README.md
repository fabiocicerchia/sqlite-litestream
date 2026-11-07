# Specifications of sqlite-litestream

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Database Admin UI
Browsing and editing the database through a web interface.

- **Write access control**: [Browsing the database in the admin UI](admin-ui/write-access/admin-ui.feature) (2)

## Configuration
How operators tell the sidecar which database to protect and where to send it.

- **Bring your own config**: [Bringing your own Litestream config](configuration/custom-config/custom-config.feature) (2)
- **Run modes**: [Choosing a run mode](configuration/mode-selection/run-modes.feature) (3)
- **Environment-based setup**: [Setting up replication from environment variables](configuration/simple-setup/env-based-setup.feature) (2)

## Distribution & Deployment
Getting the image onto machines and clusters.

- **Container image**: [Using the published container image](distribution/container-image/container-image.feature) (4)
- **One-line installer**: [Installing sqlite-litestream with one command](distribution/installer/one-line-installer.feature) (2)
- **Kubernetes chart validation**: [Validating the Kubernetes chart](distribution/kubernetes-chart/chart-render-check.feature) (3)
- **Publishing releases**: [Publishing releases](distribution/publishing/publishing-releases.feature) (3)

## Disaster Recovery
Bringing a database back from its replica on demand.

- **On-demand restore**: [Restoring the database on demand](recovery/forced-restore/on-demand-restore.feature) (1)

## Backup & Replication
Continuously streaming the SQLite database to a remote replica so it is never lost.

- **Restore on first start**: [Restoring a missing database on first start](replication/auto-restore-on-start/restore-on-first-start.feature) (3)

## Security & Encryption
Keeping replicated data and the running container safe.

- **Container hardening**: [Running the sidecar safely](security/container-hardening/container-hardening.feature) (4)
- **Replica encryption**: [Encrypting replicas with age](security/replica-encryption/replica-encryption.feature) (3)
