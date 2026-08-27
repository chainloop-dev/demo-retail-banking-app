# Demo Retail Banking Application

[![Backend API Build](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/api-build.yml/badge.svg)](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/api-build.yml)
[![Mobile Client Build](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/mobile-build.yml/badge.svg)](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/mobile-build.yml)
[![Release](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/release.yml/badge.svg)](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/release.yml)

An example application used to demonstrate software supply chain security with
[Chainloop](https://chainloop.dev). It is a multi-component product: a backend API and a mobile
client, each built and attested independently.

## Components

| Component | Directory | Stack |
|---|---|---|
| Payments API | [`payments-api/`](payments-api/) | Java 17, Spring Boot, Maven |
| Mobile client | [`mobile-client/`](mobile-client/) | Android — **placeholder, no source code**. See [`mobile-client/README.md`](mobile-client/README.md) |

Each component owns its own build, configuration and documentation. Start with
[`payments-api/README.md`](payments-api/README.md) for how to build, run and test the backend, and
[`mobile-client/README.md`](mobile-client/README.md) for what the mobile pipeline does and does not do.

## Repository-wide configuration

| Path | Purpose |
|---|---|
| `.github/workflows/` | CI pipelines for every component. |
| `.chainloop.yml` | Chainloop organization, project and **project version**. Every component of this repo attests to the one `retail-banking-app` project; each pipeline names its own workflow (`payments-api-build`, `mobile-client-build`, `release`) explicitly, but none names a version — see below. |
| `.chainloop/contracts/` | Contracts for all three workflows, synced to Chainloop by [`chainloop-sync.yml`](.github/workflows/chainloop-sync.yml). Git is the source of truth. |

## Versioning and releases

`.chainloop.yml` carries `projectVersion: <last release>+next`, and
`chainloop attestation init` reads it whenever a pipeline passes no `--version`. No pipeline
does, so every build of either component attests into the same in-flight project version.

Pushing a `v*` tag runs [`release.yml`](.github/workflows/release.yml), which attests a release
into that same version, renames it to the tag, and opens a pull request bumping
`projectVersion` to `<tag>+next` for the next cycle. Do not edit that line by hand.

## License

Released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
The Payments API is derived from the [Spring PetClinic](https://github.com/spring-projects/spring-petclinic)
sample application.
