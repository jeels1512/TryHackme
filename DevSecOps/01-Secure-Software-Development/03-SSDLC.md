# SSDLC — Secure Software Development Lifecycle

> **Room:** [https://tryhackme.com/room/securesdlc](https://tryhackme.com/room/securesdlc)
> **Module:** 1 — Secure Software Development
> **Difficulty:** Easy

## Overview

SSDLC = SDLC + security baked into every phase. This room walks through how each SDLC phase changes when you add security as a requirement, plus the major SSDLC frameworks like Microsoft SDL, OWASP SAMM, and BSIMM.

---

## Key Concepts

### What is SSDLC?

The **Secure Software Development Lifecycle** integrates security activities into every phase of the SDLC. Instead of testing for security at the end, you build it in from the start.

### SSDLC vs SDLC

| SDLC Phase | What's added in SSDLC |
|------------|------------------------|
| Planning | Security requirements gathering, risk assessment |
| Requirements | Define security and compliance requirements |
| Design | Threat modelling, secure architecture review |
| Implementation | Secure coding standards, peer reviews, SAST |
| Testing | Security testing (SAST, DAST, pen testing) |
| Deployment | Secure configuration, vulnerability scanning, monitoring |

### Phase-by-phase security activities

#### Planning
- Identify regulatory requirements (GDPR, HIPAA, PCI-DSS)
- Define risk tolerance and security budget
- Plan for security training

#### Requirements
- Document **security requirements** alongside functional ones
- Examples: "All passwords must be hashed with bcrypt", "All API endpoints must require authentication"
- Apply CIA triad: **Confidentiality, Integrity, Availability**

#### Design
- **Threat modelling** — STRIDE method is common:
  - **S**poofing
  - **T**ampering
  - **R**epudiation
  - **I**nformation disclosure
  - **D**enial of service
  - **E**levation of privilege
- Architecture reviews
- Choose secure libraries and frameworks

#### Implementation
- Follow secure coding standards (OWASP Secure Coding Practices)
- Peer code reviews with security checklist
- Run **SAST** tools as devs commit
- Use linters and static analysers in IDE

#### Testing
- **SAST** — static analysis (looks at code without running it)
- **DAST** — dynamic analysis (tests running app)
- **IAST** — interactive (runs while app is being tested)
- **SCA** — software composition analysis (scans dependencies)
- Penetration testing
- Fuzz testing

#### Deployment
- Harden production configs
- Scan IaC for misconfigurations
- Implement WAF, IDS/IPS
- Set up logging and monitoring
- Plan for incident response

### Major SSDLC Frameworks

#### Microsoft SDL (Security Development Lifecycle)
- One of the oldest and most well-known
- 12 practices spanning training, requirements, design, implementation, verification, release, response

#### OWASP SAMM (Software Assurance Maturity Model)
- Open framework from OWASP
- 5 business functions: Governance, Design, Implementation, Verification, Operations
- Each function has practices with maturity levels (1, 2, 3)

#### BSIMM (Building Security In Maturity Model)
- Descriptive — based on observed practices at real companies
- Helps you benchmark your security maturity against peers

#### NIST SSDF (Secure Software Development Framework)
- US government framework (NIST SP 800-218)
- 4 groups: Prepare the Organization, Protect the Software, Produce Well-Secured Software, Respond to Vulnerabilities

### Benefits of SSDLC

- Vulnerabilities caught early → cheaper to fix
- Compliance becomes easier
- Reduced attack surface in production
- Faster, safer releases over time
- Builds a **security-aware culture**

---

## Commands Cheatsheet

Theory room — no commands.

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is SSDLC?**
- Q: What does SSDLC stand for?
- A: `Secure Software Development Lifecycle`

**Task 3 — Phases of SSDLC**
- Q: In which phase is threat modelling typically performed?
- A: `Design`
- Q: SAST is performed during which phase?
- A: `Implementation` (or `Testing` depending on the question — both can apply)

**Task 4 — SSDLC Frameworks**
- Q: Which framework was developed by Microsoft?
- A: `Microsoft SDL` (or `SDL`)
- Q: Which OWASP framework helps measure software security maturity?
- A: `SAMM`
- Q: Which framework is descriptive and based on real-world observations?
- A: `BSIMM`

**Task 5 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. SSDLC = SDLC with security activities integrated into every phase.
2. Threat modelling (STRIDE) lives in the **Design** phase.
3. SAST, DAST, SCA each have their place — combine them for full coverage.
4. Major frameworks to know: **Microsoft SDL, OWASP SAMM, BSIMM, NIST SSDF**.
5. The earlier you find a vulnerability, the cheaper it is to fix.
