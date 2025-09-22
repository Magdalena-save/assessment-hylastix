# Hylastix / Ruhr Security — IT Security Engineer (Junior)

Ovaj repo sadrži **reproducibilno** rešenje praktičnog dela:
- VM image build sa **Packer** (Ubuntu 22.04)
- CIS audit pomoću **OpenSCAP/USG** (before/after izveštaji)
- **Apache** preko HTTPS sa **hardenovanim TLS** i **Mutual TLS (mTLS)** (lokalna CA, `openssl`)
- **UFW** (netfilter) minimalno restriktivna pravila
- Sva konfiguracija se **bake-uje u image** kroz Packer provisionere (nema ručnog SSH editovanja)

## Prerequisites
- Azure nalog + `az` CLI (ulogovan): `az login`
- Packer 1.9+
- (Opcionalno) **Ubuntu Pro** token u $UA_TOKEN ako želiš USG content

## Quick start
```bash
packer build packer/ubuntu2204.json


# Bez klijent sertifikata (zahtev za /secure treba da bude odbijen/403):
curl -i https://YOUR_DNS/secure

# Sa klijent sertifikatom (OK):
curl -i --cert client/client1.crt --key client/client1.key https://YOUR_DNS/secure


/packer/ubuntu2204.json     # Packer template
/scripts/hardening.sh       # OpenSCAP/USG audit + (best-effort) remediation
/scripts/apache_setup.sh    # Apache + TLS hardening + mTLS lokacija
/scripts/tls_setup.sh       # Lokalna CA + server + client cert
/scripts/firewall.sh        # UFW policy (22/80/443 allow)
/docs/cis_before.html       # Izveštaji (kopirati ovde posle build-a)
/docs/cis_after.html
/docs/screenshots/          # Screenshot-ovi (Azure, curl, WAF…)



---

## 2) Upisujemo **THEORY.md**
```bash
cat > THEORY.md << 'EOF'
# Arhitektura & TLS

## Preporučena arhitektura (cloud-agnostic)
Internet → (opciono) WAF → **reverse proxy** (Nginx/Envoy/Traefik + oauth2-proxy) u public subnetu → **privatni** VM servis u private subnetu (bez public IP).
- Proxy terminira TLS i vrši **OIDC** autentikaciju prema IdP-u ili **mTLS** na edge-u.
- Backend ostaje neizložen internetu; NSG/SG blokira direktne dolazne konekcije.

## TLS
- Dozvoli samo **TLS 1.3** i **TLS 1.2** (isključi SSLv3, TLS 1.0/1.1)
- TLS 1.3 (implicitno u OpenSSL/Apache): `TLS_AES_256_GCM_SHA384`, `TLS_CHACHA20_POLY1305_SHA256`, `TLS_AES_128_GCM_SHA256`
- TLS 1.2 (samo ECDHE + AEAD):
  - `ECDHE-ECDSA-AES256-GCM-SHA384`, `ECDHE-RSA-AES256-GCM-SHA384`
  - `ECDHE-ECDSA-CHACHA20-POLY1305`, `ECDHE-RSA-CHACHA20-POLY1305`
  - `ECDHE-ECDSA-AES128-GCM-SHA256`, `ECDHE-RSA-AES128-GCM-SHA256`
- Onemogući `3DES`, `RC4`, `MD5`, `aNULL`, `eNULL`, `DES`, `EXPORT`; preferiraj **forward secrecy** (ECDHE).
