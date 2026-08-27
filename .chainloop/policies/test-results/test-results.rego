package test_results

# Fails a JUnit/xUnit report that contains failing or errored test cases.
#
# Chainloop ingests JUNIT_XML with github.com/joshdk/go-junit and marshals the
# resulting []Suite to a JSON array; the policy engine wraps a top-level array as
# input.elements. So each element here is one test suite. The ingester calls
# Aggregate(), so .totals is populated -- but the counts below are taken from the
# test cases themselves, which is the same number and does not depend on a
# producer having written correct suite attributes.

import rego.v1

################################
# Common section do NOT change #
################################

result := {
	"skipped": skipped,
	"violations": violations,
	"skip_reason": skip_reason,
}

default skip_reason := ""

skip_reason := m if {
	not is_junit_report
	m := "the file content is not recognized as a JUnit XML report"
}

default skipped := true

skipped := false if valid_input

# A misconfigured input must not leave the policy skipped: a skip reads as "not
# applicable" at the gate, so a typo would silently satisfy the requirement this
# policy backs. Surface it as a violation instead and fail closed.
skipped := false if misconfigured

########################################
# EO Common section, custom code below #
########################################

# The crafter rejects a report with no suites before it is ever uploaded, so this
# is defence in depth rather than the load-bearing check.
is_junit_report if {
	is_array(input.elements)
	count(input.elements) > 0
}

valid_input if {
	is_junit_report
	not misconfigured
}

misconfigured if {
	is_junit_report
	max_failures_invalid
}

# Surefire and Failsafe emit suites flat, one per test class, but the JUnit schema
# allows a <testsuite> to nest inside a <testsuites>. Both levels are collected so
# a nested report cannot hide a failure from the gate.
#
# Arrays, not sets. A material may be a zip of many report files, and two runs of
# the same parameterized case can serialise to byte-identical test objects -- as a
# set those collapse into one, silently undercounting both the totals and the
# failures. Comprehensions preserve multiplicity.
suites := array.concat(
	[s | some s in input.elements],
	[s | some parent in input.elements; some s in parent.suites],
)

tests := [t |
	some s in suites
	some t in s.tests
]

# go-junit normalises every producer's spelling to these four statuses: passed,
# skipped, failed, error. A skipped test is deliberately NOT a failure here --
# gating on skips belongs in a separate input, not in the definition of "failing".
failing := [t |
	some t in tests
	lower(t.status) in {"failed", "error"}
]

# sort() makes the violation list deterministic, so re-running the same report
# does not reshuffle which failures fall inside the cap below.
failed_ids := sort([id |
	some t in failing
	id := sprintf("%s.%s (%s)", [t.classname, t.name, lower(t.status)])
])

default max_failures := 0

max_failures := to_number(input.args.max_failures) if max_failures_valid

# The engine evaluates policies with strict builtin errors, so to_number on a
# non-numeric string aborts the whole evaluation with an opaque "failed to execute
# policy" rather than leaving the rule undefined. Validate the shape first so a
# typo produces the violation below instead of an engine error. An input that is
# present but invalid would also fall through to the default above, quietly gating
# against a bar nobody configured.
max_failures_valid if {
	is_string(input.args.max_failures)
	regex.match(`^\d+$`, input.args.max_failures)
}

max_failures_invalid if {
	input.args.max_failures
	not max_failures_valid
}

over_threshold if count(failed_ids) > max_failures

violations contains msg if {
	is_junit_report
	max_failures_invalid
	msg := sprintf("max_failures %v is not a whole number", [input.args.max_failures])
}

# A report carrying suites but no test cases means the run produced nothing to
# judge. Fail closed: a release gate that goes green because no test executed is
# the exact false pass this policy exists to prevent.
violations contains msg if {
	valid_input
	count(tests) == 0
	msg := "the report contains no test cases"
}

violations contains msg if {
	valid_input
	over_threshold
	msg := sprintf(
		"%d of %d test cases did not pass, maximum allowed is %d",
		[count(failed_ids), count(tests), max_failures],
	)
}

# Enumerated so a blocked release names what broke rather than only how much.
# Capped, because a suite-wide breakage would otherwise emit hundreds of
# violations and bury the summary above.
violations contains msg if {
	valid_input
	over_threshold
	some i, id in failed_ids
	i < 10
	msg := sprintf("failing test: %s", [id])
}

violations contains msg if {
	valid_input
	over_threshold
	count(failed_ids) > 10
	msg := sprintf("... and %d more failing test cases", [count(failed_ids) - 10])
}
