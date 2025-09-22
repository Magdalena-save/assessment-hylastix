#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[*] Update & base tools"
apt-get update -y
apt-get upgrade -y
apt-get install -y ubuntu-advantage-tools openscap-scanner libopenscap8 scap-security-guide || true
apt-get install -y ubuntu-security-guide || true

mkdir -p /opt/cis_reports /var/www/html/reports
chmod 755 /opt/cis_reports /var/www/html/reports

echo "[*] (Optional) Attach Ubuntu Pro if UA_TOKEN is set"
if [[ -n "${UA_TOKEN:-}" ]]; then ua attach "$UA_TOKEN" || true; fi

PROFILE="xccdf_org.ssgproject.content_profile_cis_level1_server"
CONTENT="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"

echo "[*] BEFORE report"
if [[ -f "$CONTENT" ]]; then
  oscap xccdf eval --profile "$PROFILE" \
    --results-arf /opt/cis_reports/before.arf \
    --report /opt/cis_reports/cis_before.html \
    "$CONTENT" || true
fi

echo "[*] Best-effort remediation via USG"
if command -v usg >/dev/null 2>&1; then
  usg fix cis_level1_server || usg apply cis_level1_server || true
fi

echo "[*] AFTER report"
if [[ -f "$CONTENT" ]]; then
  oscap xccdf eval --profile "$PROFILE" \
    --results-arf /opt/cis_reports/after.arf \
    --report /opt/cis_reports/cis_after.html \
    "$CONTENT" || true
fi

cp -f /opt/cis_reports/cis_*.html /var/www/html/reports/ 2>/dev/null || true
echo "[*] Hardening done."
