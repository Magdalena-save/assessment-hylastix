# Assessment – IT Security Engineer (Junior)

This repository contains the deliverables for the Hylastix assessment.  
The tasks were performed in an isolated Azure environment with Ubuntu 22.04 LTS, following security hardening best practices, TLS setup, and firewall configuration.

---

## Contents

- **THEORY.md** – theoretical part of the assessment (concepts, explanation, process)
- **packer/ubuntu2204.json** – Packer template for VM image build
- **scripts/** – automation scripts:
  - `hardening.sh` – CIS hardening baseline
  - `apache_setup.sh` – Apache + TLS setup
  - `tls_setup.sh` – TLS certificates configuration
  - `firewall.sh` – UFW firewall rules
- **docs/**
  - `cis_before.html` – CIS benchmark report (before hardening)
  - `cis_after.html` – CIS benchmark report (after hardening)
  - `screenshots/` – verification screenshots (see below)

---

## Verification Screenshots

All verification evidence is located in `docs/screenshots/`:

- **CIS reports**  
  - `before*.PNG` → CIS benchmark results before hardening  
  - `after*.PNG` → CIS benchmark results after hardening  

- **Apache configuration**  
  - `apache_before.PNG`, `apache_aftrer.PNG` → Apache before/after TLS setup  

- **curl tests**  
  - `200.PNG` → HTTPS access (200 OK)  
  - `301port.PNG` → HTTP to HTTPS redirect  
  - `not_secured.PNG`, `apache_page_secured.PNG` → Browser HTTPS tests  

- **Firewall & networking**  
  - `nsg-ufw.PNG` → UFW configuration  
  - `NSG_rules.PNG` → NSG rules in Azure portal  

- **Azure resources**  
  - `vm_azure.PNG` → VM deployment overview in Azure portal  

---

## Deliverables

- PDF (theory + process): `assessmentMagdalenaVranic.pdf`
- GitHub repo: [https://github.com/Magdalena-save/assessment-hylastix](https://github.com/Magdalena-save/assessment-hylastix)
