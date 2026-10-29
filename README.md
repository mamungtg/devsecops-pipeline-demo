# DevSecOps Reference Pipeline (sanitized)

Sanitized reference implementation based on patterns used in production.

## Repository layout

- `.github/workflows/devsecops.yml`: GitHub Actions pipeline
- `Jenkinsfile`: equivalent Jenkins declarative pipeline
- `scripts/triage.py`: converts Trivy findings into GitHub Issues for triage
- `app/` + `Dockerfile`: sample Flask service (non-root container)
- `terraform/modules/secure-s3-bucket`: reusable module (KMS CMK with rotation, versioning, public access block)

## Pipeline flow

SAST (Semgrep) > SCA + secrets (Trivy fs) > IaC (Trivy config) > build > container scan gate > SBOM (Syft, SPDX) > Cosign sign + SBOM attestation > SLSA build provenance

## Security gates

Builds fail on CRITICAL/HIGH findings (unfixed vulnerabilities ignored for image scans).

## Triage and fix verification

1. Findings are published as SARIF to GitHub code scanning.
2. `scripts/triage.py` opens one issue per CRITICAL/HIGH finding (deduplicated).
3. Remediation PR references "Fixes #N".
4. PR re-scan must pass the gate (fix verification); merge closes the issue.

## Signing and provenance

- GitHub Actions: Cosign keyless (OIDC), SBOM attestation, and `actions/attest-build-provenance`
- Jenkins: key-based Cosign with credentials from the Jenkins credential store

## Supply chain hardening

- All third-party actions are pinned to full commit SHAs (tag kept as a comment). Mutable tags were force-pushed in the March 2026 Trivy compromise (CVE-2026-33634); SHA pinning prevents that class of attack.
- Scanner images in Jenkins are pinned to known-safe versions.
- Least-privilege `permissions:` per job; write scopes only where required.
