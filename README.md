# Demo Retail Banking Application

[![Java CI with Maven](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/maven-build.yml/badge.svg)](https://github.com/chainloop-dev/demo-retail-banking-app/actions/workflows/maven-build.yml)

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
| `.chainloop.yml` | Default Chainloop project. The mobile pipeline overrides it with `--project mobile-banking`. |
| `.devcontainer/`, `.gitpod.yml` | Prebuilt development environments. |

## License

Released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
The Payments API is derived from the [Spring PetClinic](https://github.com/spring-projects/spring-petclinic)
sample application.
