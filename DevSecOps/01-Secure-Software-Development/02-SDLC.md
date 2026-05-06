# SDLC — Software Development Lifecycle

> **Room:** [https://tryhackme.com/room/sdlc](https://tryhackme.com/room/sdlc)
> **Module:** 1 — Secure Software Development
> **Difficulty:** Easy

## Overview

This room covers the Software Development Lifecycle — the structured process teams use to plan, build, test, and maintain software. You'll learn the standard SDLC phases and the popular development models (Waterfall, Agile, DevOps).

---

## Key Concepts

### What is SDLC?

A **framework** that defines the steps for building software. It gives the team a shared structure so everyone knows what comes next, who's responsible, and what "done" looks like.

### The 6 SDLC phases

1. **Planning**
   - Define what the software should do
   - Set scope, budget, timeline
   - Identify stakeholders and risks

2. **Requirements / Analysis**
   - Gather what users actually need
   - Document functional requirements (what it does) and non-functional ones (performance, security, scalability)

3. **Design**
   - Create the architecture, data flow, UI mockups
   - Pick the tech stack
   - This is where threat modelling fits in DevSecOps

4. **Implementation / Coding**
   - Developers write the actual code
   - Follow coding standards and best practices

5. **Testing**
   - Unit tests, integration tests, system tests
   - QA finds bugs, devs fix them
   - Security testing should also happen here

6. **Deployment / Maintenance**
   - Push to production
   - Monitor, patch, fix bugs, push updates
   - Eventually retire or replace the software

### SDLC Models

#### Waterfall
- Linear, sequential — finish one phase before the next
- Heavy upfront planning and documentation
- Hard to change requirements once you've started
- Good for: regulated industries with fixed requirements
- Bad for: anything where requirements evolve

#### Agile
- Iterative — work in short sprints (1–4 weeks)
- Continuous feedback from users
- Embraces change
- Frameworks: Scrum, Kanban, XP
- Good for: most modern software

#### DevOps
- Builds on Agile
- Combines development and operations into one team
- Heavy automation: CI/CD pipelines, automated testing, infrastructure as code
- Goal: ship faster, more reliably
- Sets the stage for DevSecOps

#### Other models worth knowing
- **Spiral** — combines iterative dev with risk analysis at each loop
- **V-Model** — like Waterfall but with testing planned alongside each dev phase
- **RAD (Rapid Application Development)** — fast prototyping, less planning

### Why SDLC matters for security

If you don't have a structured process, security gets skipped. SDLC gives you predictable points where security checks can be inserted — which is exactly what SSDLC (next room) builds on.

---

## Commands Cheatsheet

Theory room — no commands.

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is SDLC?**
- Q: How many phases does the SDLC have?
- A: `6`

**Task 3 — Phases of the SDLC**
- Q: Which phase is responsible for gathering user requirements?
- A: `Requirements` (or `Analysis`)
- Q: Which phase involves writing the actual code?
- A: `Implementation`
- Q: In which phase do you fix bugs after release?
- A: `Maintenance`

**Task 4 — SDLC Models**
- Q: Which SDLC model is linear and sequential?
- A: `Waterfall`
- Q: Which model uses short iterative sprints?
- A: `Agile`
- Q: Which model combines development with operations?
- A: `DevOps`

**Task 5 — Conclusion**
- Click to complete.

> Question wording sometimes shifts on TryHackMe — these match the underlying concepts.

---

## Key Takeaways

1. SDLC = the framework for building software, 6 phases: Planning → Requirements → Design → Implementation → Testing → Deployment/Maintenance.
2. Waterfall is rigid; Agile is iterative; DevOps adds automation; DevSecOps adds security on top.
3. Without an SDLC, security gets skipped because there's no defined point to add it.
4. Threat modelling fits during the **Design** phase — well before any code is written.
