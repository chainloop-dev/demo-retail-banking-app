# Payments API

The backend service of the demo retail banking application: a [Spring Boot](https://spring.io/guides/gs/spring-boot)
application built with [Maven](https://spring.io/guides/gs/maven/), based on the
[Spring PetClinic](https://github.com/spring-projects/spring-petclinic) sample.

Everything in this directory is self-contained — all commands below are run from `payments-api/`.

## Layout

| Path | Contents |
|---|---|
| `src/` | Application sources, tests and resources. |
| `pom.xml`, `mvnw`, `.mvn/` | Maven build and wrapper. |
| `docker-compose.yml` | MySQL and PostgreSQL containers for local development. |
| `k8s/` | Kubernetes manifests used by the deploy-and-test workflow. |

## Requirements

- Java 17 or newer (a full JDK, not a JRE)
- Docker, only if you want to run a database or build a container image

## Run it locally

```bash
./mvnw spring-boot:run
```

The application is then available at <http://localhost:8080/>.

## Build a container image

There is no `Dockerfile`. Use the Spring Boot build plugin instead:

```bash
./mvnw spring-boot:build-image
docker run -p 8080:8080 docker.io/library/spring-petclinic:latest
```

## Database configuration

By default the service uses an in-memory H2 database that is populated at startup. The H2
console is exposed at <http://localhost:8080/h2-console>; connect with the `jdbc:h2:mem:<uuid>`
URL printed to the console at startup.

MySQL and PostgreSQL are also supported. Switching database means switching Spring profile —
`spring.profiles.active=mysql` or `spring.profiles.active=postgres`. See the
[Spring Boot documentation](https://docs.spring.io/spring-boot/how-to/properties-and-configuration.html#howto.properties-and-configuration.set-active-spring-profiles)
for the ways to set an active profile.

The provided `docker-compose.yml` starts either database, with one service named after each profile:

```bash
docker compose up mysql
# or
docker compose up postgres
```

Setup notes for each engine live in
[`src/main/resources/db/mysql`](src/main/resources/db/mysql) and
[`src/main/resources/db/postgres`](src/main/resources/db/postgres).

## Testing

```bash
./mvnw verify
```

At development time you can also run the test applications defined as `main()` methods in
`PetClinicIntegrationTests` (default H2 database plus Spring Boot Devtools),
`MySqlTestApplication` and `PostgresIntegrationTests`. These run in your IDE for fast feedback
and double as integration tests against the respective database — the MySQL tests start the
database with Testcontainers, the Postgres tests with Docker Compose.

## Cross-component integration testing

`MobileClientContractIT` asserts the contract the mobile client depends on this API to honour.
It is the only suite here that says something about **both** components of the product, which
is why the release pipeline runs it rather than either component's build.

It sits behind the `integration` Maven profile, and its `*IT` name keeps it out of Surefire's
default includes, so `./mvnw verify` never picks it up:

```bash
./mvnw -P integration verify
```

Reports land in `target/failsafe-reports/` — the `TEST-*.xml` files are what Chainloop ingests,
as a single zipped `JUNIT_XML` material. Like the mutation run, it is report-only: the profile
sets `testFailureIgnore` and does not bind `failsafe:verify`, so a failing test does not break
the Maven build. That matters more here than it does for PIT — a Maven failure would abort
before the report could be attested, and the release gate would never see the failure it exists
to block on.

**One of its tests fails on purpose.** `paymentsHistoryEndpointServesTheMobileClient` calls an
endpoint the API has not shipped. That is the defect class a component-scoped suite cannot
catch: both sides pass their own tests and the product is still broken. The `test-results`
policy in [`.chainloop/policies/`](../.chainloop/policies/) reads that failure and blocks the
release.

## Mutation testing

Coverage tells you which lines ran; mutation testing tells you whether the tests would notice
if those lines were wrong. [PIT](https://pitest.org/) is wired up behind the `mutation` Maven
profile, because a full mutation run is much slower than the test suite:

```bash
./mvnw -P mutation verify
```

Reports land in `target/pit-reports/` — `index.html` to browse, and `mutations.xml`, the
machine-readable report Chainloop ingests. The run is report-only: it never fails the build on
a low score, since gating is the policy's job.

CI runs the same command in a dedicated `mutation-testing` job and attests `mutations.xml` to
Chainloop. No pipeline in this repository publishes build artifacts: the attested copy is the
retrievable one, and a parallel copy on the workflow run would expire while claiming to be the
same evidence.

## Compiling the CSS

`src/main/resources/static/resources/css/petclinic.css` is generated from
`src/main/scss/petclinic.scss` combined with [Bootstrap](https://getbootstrap.com/). After
changing the SCSS or upgrading Bootstrap, regenerate it with the `css` profile:

```bash
./mvnw package -P css
```

## Working in your IDE

Import this directory (`payments-api`) as a Maven project:

- **Eclipse / STS** — `File -> Import -> Maven -> Existing Maven project`, then select
  `payments-api`. Run `./mvnw generate-resources` (or `Run As -> Maven install`) once to
  generate the CSS, then run the `PetClinicApplication` main class as a Java application.
- **IntelliJ IDEA** — `File -> Open` and select [`pom.xml`](pom.xml). Generate the CSS with
  `./mvnw generate-resources` or `Maven -> Generate Sources and Update Folders`, then run the
  `PetClinicApplication` main class.
- **VS Code** — open the `payments-api` folder and install the Java extension pack; generate the
  CSS with `./mvnw generate-resources`, then run the `PetClinicApplication` main class.

Editor preferences are in [`.editorconfig`](.editorconfig); plugins are available at
<https://editorconfig.org>.

## Where things live

| Concern | File |
|---|---|
| Main class | [`PetClinicApplication`](src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
| Properties | [`src/main/resources`](src/main/resources) |
| Caching | [`CacheConfiguration`](src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |
