# VPS Security Toolkit

This folder contains scripts to harden, audit, and (if necessary) rollback security settings on any Ubuntu VPS.  
Designed for portability across regions (OVH or other providers).

---

## 📂 Contents

- `secure-vps.sh`  
  Harden your VPS with:
  - SSH key login only (passwords disabled)
  - Root login disabled
  - Firewall (UFW) with only SSH open
  - Fail2Ban intrusion protection
  - Automatic security updates (unattended-upgrades)

- `rollback-ssh.sh`  
  Emergency rollback script:
  - Re-enables root login
  - Re-enables password authentication
  - Use only if you lose SSH key access

- `check-vps-status.sh`  
  Quick audit script:
  - Shows firewall rules
  - Displays SSH config (root/password settings)
  - Reports Fail2Ban status
  - Confirms auto-update settings

---

## 🚀 Usage Workflow

```text
          ┌───────────────────┐
          │   secure-vps.sh   │
          │ Harden & lock VPS │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │ check-vps-status  │
          │ Verify hardening  │
          └─────────┬─────────┘
                    │
     ┌──────────────┴──────────────┐
     │                             │
     ▼                             ▼
┌───────────────┐          ┌─────────────────┐
│ Normal usage  │          │ rollback-ssh.sh │
│ (secure state)│          │ Emergency unlock│
└───────────────┘          └─────────────────┘

