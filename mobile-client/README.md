# Mobile client — placeholder component

**There is no mobile application source code here, and there is not going to be.** This directory
is a placeholder that exists so the demo product has a second, non-Java component whose evidence
travels the same path as the Payments API's.

Read that literally: nothing in this directory is compiled, and no security scan runs in CI.

## What the pipeline actually does

[`mobile-build.yml`](../.github/workflows/mobile-build.yml) produces the same *shape* of evidence a
real Android pipeline would — an application binary plus a mobile SAST report, attested together to
the `mobile-client-build` workflow of the `retail-banking-app` Chainloop project — by substituting a
pre-built binary and a pre-existing scan
for the two steps it cannot run:

| Step | Real pipeline | Here |
|---|---|---|
| Build | Gradle assembles the APK from source | A pre-built APK checked into this directory is copied to the path Gradle would have written it to |
| Scan | Oversecured scans the freshly built APK | Nothing. The scan already ran in the Oversecured tenant |
| Report | Scanner writes its report | The existing scan's report is fetched from the Oversecured API by app and scan id |
| Attest | `chainloop attestation add` for binary and report | Identical — this part is real |

Only the first two rows are substituted. The report is a real Oversecured report over a real APK,
fetched live from their API on every run, and the attestation, signing and policy evaluation are
exactly what a customer's pipeline would do.

## Why the scan does not run in CI

Oversecured is a commercial, cloud-only product: scanning means uploading the built binary to their
infrastructure, and each scan draws on a metered quota. Running one per CI build is not something
this demo repository can spend, so the scan is performed once, out of band, in the tenant — and the
pipeline fetches its result instead of producing it.

That substitution is invisible downstream by design. The `sast` policy, the mobile compliance
requirement and the release gate all read the attestation, never the build, so a fetched report is
indistinguishable from a freshly produced one at the point where any of them looks.

## The binary and the report are different apps

The checked-in APK is `DecodeConfigSampleAPI-Kotlin.apk` (package `com.example.decodeconfigsampleapi`,
an unrelated third-party sample). The report describes Oversecured's own `SampleApp` 3.4.0
(`com.oversecured.sample`, scanned from `sampleapp-1.0.0.apk`, 28 findings). **They are not the same
application, and the pipeline does not pretend otherwise.**

This is deliberate and costs nothing, because Oversecured's report contains no digest of the binary
it scanned — so even a matching pair could not have been cryptographically linked from the report
alone. What binds the two here is the attestation: both land as materials in one signed statement,
which is precisely the property being demonstrated.

If someone asks in a demo, the answer is that the mobile application is out of scope for this sample
repository and the pipeline demonstrates the evidence path. Do not describe the build step as a build.

## Contents

| Path | |
|---|---|
| `DecodeConfigSampleAPI-Kotlin.apk` | The stand-in application binary, committed rather than built |
