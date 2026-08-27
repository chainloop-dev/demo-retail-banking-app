#!/usr/bin/env bash

# Point the Chainloop project version in .chainloop.yml at the next development
# cycle: given the tag just released, rewrite projectVersion to "<tag>+next".
#
# Run by .github/workflows/release.yml after the release attestation has been
# pushed and the version renamed. Adapted from the same script in
# chainloop-dev/chainloop.

set -e

die () {
   echo >&2 "$@"
   echo "usage: bump-project-version.sh <version> [configFile]"
   exit 1
}

## debug if desired
if [[ -n "${DEBUG}" ]]; then
   set -x
fi

[ "$#" -ge 1 ] || die "Version argument is required"

version="${1}"
project_yaml=".chainloop.yml"
# manual override
if [[ -n "${2}" ]]; then
   project_yaml="${2}"
fi

[ -f "${project_yaml}" ] || die "${project_yaml} not found"

# Chainloop does not validate version strings — they are free-form and are not
# sorted semantically — so nothing downstream rejects a malformed one. That is
# exactly why it is checked here: the tag reaches this script straight from
# `git tag`, and a typo would otherwise be written into .chainloop.yml and
# silently become the version every later build attests under.
#
# The patch component is optional so both v2026.9 and v2026.9.0 pass. Note that
# only the latter is valid semver, which matters if anything ever has to parse
# the "+next" suffix as build metadata rather than as part of the string.
if [[ ! "${version}" =~ ^v?[0-9]+\.[0-9]+(\.[0-9]+)?([-+][0-9A-Za-z.-]+)?$ ]]; then
   die "version '${version}' does not look like a version, e.g. v2026.9.0"
fi

# Append "+next" to the version
version_with_next="${version}+next"

# Update the project yaml file
sed -i "s#^projectVersion:.*#projectVersion: ${version_with_next}#g" "${project_yaml}"

# A silent no-op here would let the release workflow open an empty pull request
# and report success, leaving every later build attesting under the released
# version instead of the new cycle.
grep -q "^projectVersion: ${version_with_next}$" "${project_yaml}" \
  || die "failed to set projectVersion in ${project_yaml}"

echo "projectVersion: ${version_with_next}"
