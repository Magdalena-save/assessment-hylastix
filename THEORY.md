# Theory and Process

This document provides the theoretical background and process description for the Hylastix IT Security Engineer (Junior) assessment.

---

## 1. System Audit
- Installed and executed the **Ubuntu Security Guide (USG)** and **CIS benchmark**.  
- Generated baseline report (`cis_before.html`) before hardening.  
- Applied hardening measures through shell scripts.  
- Generated post-hardening report (`cis_after.html`) to verify improvements.

---

## 2. TLS/SSL Configuration
- Generated self-signed certificates for HTTPS.  
- Configured Apache web server with TLS enabled.  
- Enforced secure headers (X-Frame-Options, X-Content-Type-Options, CSP).  
- Verified connection via browser (`https://<VM_PUBLIC_IP>`) and curl commands.

---

## 3. Firewall and Networking
- Configured **UFW** on the VM: allow only ports **22, 80, 443**.  
- Applied matching **NSG rules** in Azure to ensure cloud-level firewall consistency.  
- Verified rules with `ufw status` and Azure portal screenshots.

---

## 4. Verification & Testing
- curl test → `200 OK` for HTTPS.  
- curl test → `301 redirect` from HTTP to HTTPS.  
- Browser test → HTTPS warning (expected with self-signed cert).  
- CIS reports → visible improvements after hardening.  
- Azure portal screenshots → confirm VM deployment and NSG rules.

---

## 5. Deliverables
- **PDF report** (`assessmentMagdalenaVranic.pdf`)  
- **GitHub repository** with:
  - `packer/` → image build configuration  
  - `scripts/` → automation scripts for hardening, TLS, firewall  
  - `docs/` → CIS reports and verification screenshots
