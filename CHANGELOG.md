# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.1] — 2026-04-01

### Removed

- **ConfigItemCreate** and **ConfigItemUpdate** operations — removed from the package because they conflict with the same files shipped by ITSMConfigurationManagement. The upstream operations are fully functional and accept human-readable names (Class, DeplState, InciState).

### Changed

- **Webservice YAML template** — now includes 5 ConfigItem operations (Create, Update, Get, Search, Delete) from ITSMConfigurationManagement with their routes, in addition to the 19 package-provided operations.
- Package version bumped to 1.2.1.

---

## [1.2.0] — 2026-04-01

### Added

- **FAQAdd** (`POST /FAQAdd`) — create a new FAQ article at agent level.
- **FAQUpdate** (`POST /FAQUpdate/:ItemID`) — update an existing FAQ article.
- **ConfigItemCreate** and **ConfigItemUpdate** operations (removed in 1.2.1).

### Changed

- **Package renamed** from `LinkServiceFAQChangeMerge` to `GenericInterfaceExtended`.

---

## [1.1.0] — 2026-03-31

### Added

- **ChangeGet** (`GET /ChangeGet/:ChangeID`) — retrieve full change details including work order IDs, CAB members, and timestamps (ITSMChangeManagement).
- **ChangeList** (`GET /ChangeList`) — list all change IDs.
- **ChangeSearch** (`GET|POST /ChangeSearch`) — search changes by title, state, manager, builder, category, impact, priority, date ranges, and more. Supports `Result=COUNT` mode.
- **WorkOrderGet** (`GET /WorkOrderGet/:WorkOrderID`) — retrieve work order details including state, type, agent, timestamps, and effort.
- **WorkOrderList** (`GET /WorkOrderList/:ChangeID`) — list work order IDs for a specific change.
- **WorkOrderSearch** (`GET|POST /WorkOrderSearch`) — search work orders by title, state, type, agent, date ranges, and more. Supports `Result=COUNT` mode.
- **Soft dependency** — ITSMChangeManagement is optional; all 6 Change operations return `.ModuleNotAvailable` if the package is not installed.

---

## [1.0.0] — 2026-03-19

### Added

- **TicketMerge** (`POST /TicketMerge`) — irreversible merge of two tickets; the source ticket is closed and linked to the target.
- **LinkList** (`GET|POST /LinkList`) — list all links for any OTOBO object (Ticket, FAQ article, Config Item, etc.).
- **LinkAdd** (`POST /LinkAdd`) — create a typed link between two objects.
- **LinkDelete** (`POST /LinkDelete`) — remove a specific link between two objects.
- **FAQSearch** (`GET|POST /FAQSearch`) — search FAQ articles at agent level, including internal and public states.
- **FAQGet** (`GET /FAQGet/:ItemID`) — retrieve a FAQ article by ID at agent level, without state restrictions.
- **ServiceGet** (`GET /ServiceGet/:ServiceID`) — retrieve full service details; includes ITSM fields (Type, Criticality) when ITSMCore is installed.
- **ServiceList** (`GET /ServiceList`) — list all services in the catalog.
- **ServiceSearch** (`GET|POST /ServiceSearch`) — search services by name pattern.
- **SLAGet** (`GET /SLAGet/:SLAID`) — retrieve SLA details by ID.
- **SLAList** (`GET /SLAList`) — list all SLAs.
- **Extensions::Common** — internal shared base class providing `ValidateRequiredParams` used by all operation modules.
- **`bin/build-opm.sh`** — portable build script that produces a self-contained `.opm` without requiring an OTOBO installation.
- **Webservice YAML template** (`development/webservices/GenericInterfaceExtendedConnectorREST.yml`) — ready-to-import Generic Interface webservice definition.
- **Soft dependencies** — FAQ and ITSMCore packages are optional; missing packages produce graceful errors rather than hard failures.
- **SysConfig XML registration** (`Kernel/Config/Files/XML/GenericInterfaceExtended.xml`) — all operations are auto-discovered by OTOBO after a config rebuild.
