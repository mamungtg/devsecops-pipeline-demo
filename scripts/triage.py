import json, subprocess, sys

data = json.load(open(sys.argv[1]))
existing = subprocess.run(
    ["gh", "issue", "list", "--label", "security", "--state", "open",
     "--json", "title", "--limit", "500"],
    capture_output=True, text=True, check=True)
titles = {i["title"] for i in json.loads(existing.stdout)}

for result in data.get("Results", []):
    for v in result.get("Vulnerabilities") or []:
        if v["Severity"] not in ("CRITICAL", "HIGH"):
            continue
        title = f'[{v["Severity"]}] {v["VulnerabilityID"]} in {v["PkgName"]}'
        if title in titles:
            continue
        body = (f'Package: {v["PkgName"]} {v["InstalledVersion"]}\n'
                f'Fixed in: {v.get("FixedVersion", "n/a")}\n'
                f'Target: {result["Target"]}\n'
                f'Reference: {v.get("PrimaryURL", "")}\n\n'
                'Remediation: upgrade to the fixed version and open a PR with '
                '"Fixes #<this issue>". The PR re-scan verifies the fix.')
        subprocess.run(["gh", "issue", "create", "--title", title,
                        "--body", body, "--label", "security"], check=True)
        print("Created:", title)