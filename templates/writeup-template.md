---
title: "TODO - Write-up title"
author: "Lucas Fagioli"
lab: "TODO - lab or target name"
cwe: "CWE-XXX"
owasp: "AXX:2021 - Category"
difficulty: "Apprentice | Practitioner | Expert"
dbms: "TODO - DBMS or stack (optional)"
platform: "PortSwigger Web Security Academy"
date: "YYYY-MM-DD"
---

# Write-up - TODO Title

> Lab / Target: **TODO name of the lab or target**
> Category: TODO (CWE-XXX / OWASP AXX:2021)
> Difficulty: TODO . DBMS or stack: TODO
> Legal platform: TODO (PortSwigger, HTB retired, lab built locally...)

## 1. Context

Describe the target and the vulnerability in two or three sentences. What does
the application do, where does untrusted input enter, and why is it dangerous.
State clearly the injection point and the goal of the attack.

- **Injection point**: TODO
- **Goal**: TODO

Initial state of the target before exploitation:

<p align="center">
  <img src="images/01-initial-state.png" alt="Initial state, not solved" width="100%">
</p>

## 2. Environment and setup

| Item | Detail |
|---|---|
| OS | TODO |
| Main tool | TODO (Burp Suite Community, sqlmap...) |
| Browser | TODO |
| Target | TODO |

Steps performed to get ready:

1. TODO setup step one.
2. TODO setup step two.
3. TODO setup step three.

## 3. Reconnaissance

Explain how the injection point was located. Keep it factual: what was tested,
what was observed, what confirmed the entry point.

<p align="center">
  <img src="images/02-recon.png" alt="Reconnaissance" width="100%">
</p>

## 4. Exploitation

### 4.1 TODO first step

Explain the payload and what it proves. Show the request and the result.

```
TODO payload here
```

State the observed result in one short sentence.

<p align="center">
  <img src="images/03-step.png" alt="Step result" width="100%">
</p>

### 4.2 TODO second step

Same pattern: payload, expected behavior, observed result, screenshot.

```
TODO payload here
```

<p align="center">
  <img src="images/04-step.png" alt="Step result" width="100%">
</p>

### 4.3 TODO automation (optional)

If the extraction is automated, point to the script and show its output.

```
TODO script output
```

<p align="center">
  <img src="images/05-script-output.png" alt="Script output" width="100%">
</p>

### 4.4 Solving the target

Use the recovered data to complete the objective and prove success.

<p align="center">
  <img src="images/06-solved.png" alt="Target solved" width="100%">
</p>

## 5. Impact

Explain the business and technical impact. Cover confidentiality, integrity and
availability when relevant. Note whether authentication was required and how easy
the attack is to reproduce. Add an indicative severity.

## 6. Remediation

State the root cause and the primary fix first, then defense in depth.

- **Primary fix**: TODO
- **Least privilege**: TODO
- **Input validation**: TODO
- **Monitoring and logging**: TODO

Reference: TODO (OWASP Cheat Sheet, CWE page, vendor advisory...)

## Screenshot index

| # | File | Description |
|---|------|-------------|
| 01 | `01-initial-state.png` | TODO |
| 02 | `02-recon.png` | TODO |
| 03 | `03-step.png` | TODO |
| 04 | `04-step.png` | TODO |
| 05 | `05-script-output.png` | TODO |
| 06 | `06-solved.png` | TODO |
