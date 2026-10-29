# DevSecOps Reference Pipeline (sanitized)

Sanitized reference implementation based on patterns used in production.

## Files

- `devsecops.yml`: GitHub Actions workflow
- `Jenkinsfile`: equivalent Jenkins declarative pipeline
- `scripts/triage.py`: converts Trivy findings into GitHub Issues for triage

## Pipeline flow

SAST (Semgrep) > SCA + secrets (Trivy fs) > IaC (Trivy config) > build > container scan gate > SBOM (Syft, SPDX) > Cosign sign + SBOM attestation > SLSA build provenance

## Security gates

Builds fail on CRITICAL/HIGH findings (unfixed vulnerabilities ignored for image scans).

## Triage and fix verification

1. Findings are published as SARIF to GitHub code scanning.
2. `triage.py` opens one issue per CRITICAL/HIGH finding (deduplicated).
3. Remediation PR references "Fixes #N".
4. PR re-scan must pass the gate (fix verification); merge closes the issue.

## Signing

- GitHub Actions: Cosign keyless (OIDC) + `actions/attest-build-provenance`
- Jenkins: key-based Cosign with credentials from the Jenkins credential store

## Production notes

Pin third-party actions by commit SHA, use least-privilege job permissions, and use ephemeral runners.
