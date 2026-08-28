# Before Chainloop

The three pipelines as they were before any Chainloop instrumentation, kept
beside the instrumented ones so the difference can be read as a diff:

| before/            | instrumented        |
| ------------------ | ------------------- |
| `api-build.yml`    | `../api-build.yml`  |
| `mobile-build.yml` | `../mobile-build.yml` |
| `release.yml`      | `../release.yml`    |

GitHub Actions only picks up workflows at the top level of `.github/workflows/`,
so nothing in this directory ever runs. These files are documentation.

What the instrumented versions add, and these do without:

- **No attestation.** Each pipeline builds and scans, then stops. What it
  produced is described by the run log and by whatever was uploaded as a run
  artifact — nothing signed, nothing that outlives the 90-day artifact
  retention.
- **No gate.** Coverage, mutation score and SAST findings are all produced here
  too; nothing reads them. A release ships whatever the build made, whether or
  not the numbers moved, and the release pipeline has no way to ask what the
  component builds found for the version it is releasing.
- **Evidence stays where it was produced.** SonarQube's findings live in
  SonarQube, Oversecured's in Oversecured, JaCoCo's and PIT's in a run artifact.
  There is no place that holds all of them for one version of the product.
- **No version flow.** `.chainloop.yml` does not exist in this world, so there
  is no in-flight project version for the builds to attest into, no rename on
  release, and no bump pull request afterwards.
- **No jobs that exist only to open and close an attestation**, so the API build
  is two jobs rather than four, and the release is two rather than four.
