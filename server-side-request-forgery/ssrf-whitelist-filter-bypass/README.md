---
title: "SSRF with whitelist-based input filter (URL parser confusion)"
author: "Lucas Fagioli"
lab: "SSRF with whitelist-based input filter"
cwe: "CWE-918"
owasp: "A10:2021 - Server-Side Request Forgery (SSRF)"
difficulty: "Expert"
dbms: "Stock check API (internal HTTP service)"
platform: "PortSwigger Web Security Academy"
date: "2026-07-01"
---

# Write-up - SSRF with whitelist-based input filter (URL parser confusion)

> Lab: **SSRF with whitelist-based input filter**
> Category: Server-Side Request Forgery (CWE-918 / OWASP A10:2021)
> Difficulty: Expert . Target service: internal stock check API
> Legal platform: PortSwigger Web Security Academy

## Lab brief

> This lab has a stock check feature which fetches data from an internal system.
>
> To solve the lab, change the stock check URL to access the admin interface at
> `http://localhost/admin` and delete the user `carlos`. The developer has
> deployed an anti-SSRF defense you will need to bypass.
>
> Source: [PortSwigger Web Security Academy](https://portswigger.net/web-security/ssrf/lab-ssrf-with-whitelist-filter)

## 1. Context

The shop exposes a "Check stock" feature on each product page. When clicked, the
server fetches a URL passed in the `stockApi` parameter and returns the body of
that response. This is a textbook SSRF entry point: the client controls, at least
in part, the URL the server requests.

The application defends itself with a **whitelist on the host**: only
`stock.weliketoshop.net` is accepted, so a naive `http://localhost/admin` is
rejected. The whole challenge is to make the request reach the internal admin
interface anyway, by exploiting an **inconsistency between the URL parser that
validates the host and the URL parser that actually performs the request**.

- **Injection point**: `stockApi` POST parameter on `/product/stock`
- **Goal**: reach `http://localhost/admin` and delete the user `carlos`

Initial state of the lab (not solved):

<p align="center">
  <img src="images/01-lab-not-solved.png" alt="Lab not solved" width="100%">
</p>

## 2. Environment and setup

| Item | Detail |
|---|---|
| OS | Windows 11 |
| Main tool | Burp Suite Community Edition |
| Browser | Chromium embedded in Burp (Open Browser) |
| Target | PortSwigger lab instance (ephemeral `*.web-security-academy.net` URL) |

Steps performed to get ready:

1. Launched Burp Suite Community and created a temporary project with the
   defaults.
2. Opened the embedded browser (Proxy, Open Browser), already wired to the Burp
   proxy, so no proxy or certificate configuration was needed.
3. Accessed the lab and confirmed it was in the "Not solved" state.

## 3. Reconnaissance

Opening any product page reveals a store selector followed by a **Check stock**
button. That button is what triggers the server-side fetch.

<p align="center">
  <img src="images/02-check-stock-feature.png" alt="Check stock feature on a product page" width="100%">
</p>

With interception enabled, clicking **Check stock** captures a `POST` to
`/product/stock` carrying a URL-encoded `stockApi` parameter.

<p align="center">
  <img src="images/03-intercepted-request-proxy.png" alt="Intercepted request in the Burp proxy" width="100%">
</p>

The request was sent to Repeater to iterate quickly. Decoded, the parameter
points at an internal service:

```
stockApi=http://stock.weliketoshop.net:8080/product/stock/check?productId=4&storeId=1
```

A normal request returns `200 OK` with the stock count as the body (for example
`677`). This is our baseline.

<p align="center">
  <img src="images/04-stockapi-request-repeater.png" alt="stockApi request in Burp Repeater with a normal response" width="100%">
</p>

## 4. Exploitation

The strategy is to build up the bypass one observation at a time: confirm the
filter, find a property the parser tolerates, then turn that property into a host
confusion.

### 4.1 The host filter blocks arbitrary targets

Pointing `stockApi` straight at the loopback address is rejected, confirming a
host whitelist rather than a blacklist:

```
stockApi=http://127.0.0.1/
```

The response is an error stating the external stock check host is not allowed.

<p align="center">
  <img src="images/05-localhost-blocked.png" alt="Loopback address blocked by the whitelist" width="100%">
</p>

### 4.2 Embedded credentials are accepted

URLs of the form `userinfo@host` are valid, and the parser reads the host as the
part **after** the `@`. Since that part is the whitelisted domain, the request is
accepted:

```
stockApi=http://username@stock.weliketoshop.net/
```

The response comes back normally. The `username` portion is ignored by the
filter, which only cares that the host is `stock.weliketoshop.net`.

<p align="center">
  <img src="images/06-embedded-credentials-accepted.png" alt="Embedded credentials accepted by the filter" width="100%">
</p>

### 4.3 A raw fragment character breaks the host

Adding a `#` after the credentials changes how the host is computed: the `#`
starts a URL fragment, so the parser no longer sees `stock.weliketoshop.net` as
the host, and the request is rejected:

```
stockApi=http://username#@stock.weliketoshop.net/
```

<p align="center">
  <img src="images/07-hash-rejected.png" alt="Raw hash character rejected" width="100%">
</p>

This is the key observation. If we could keep the `#` invisible to the validator
but have it decoded by the component that performs the request, the two parsers
would disagree on the host.

### 4.4 Double-encoding the fragment to desynchronise the parsers

Encoding the `#` twice (`#` -> `%23` -> `%2523`) achieves exactly that. The
server decodes the parameter once, so:

- the **validator** sees `...localhost:80%23@stock.weliketoshop.net...`. The `%23`
  is still encoded, so it is treated as part of the credentials and the host is
  read as the whitelisted `stock.weliketoshop.net`. Validation passes.
- the **HTTP client** that performs the fetch decodes `%23` into a real `#`, so
  the authority before it (`localhost:80`) becomes the actual target host.

Reaching the admin interface first confirms the bypass works:

```
stockApi=http://localhost:80%2523@stock.weliketoshop.net/admin
```

The response now contains the HTML of the internal admin panel, including the
links to delete users.

<p align="center">
  <img src="images/08-admin-panel-via-ssrf.png" alt="Admin panel reached through the SSRF" width="100%">
</p>

### 4.5 Solving the lab

Pointing the same payload at the user deletion endpoint removes the target
account:

```
stockApi=http://localhost:80%2523@stock.weliketoshop.net/admin/delete?username=carlos
```

<p align="center">
  <img src="images/09-delete-carlos-request.png" alt="Request deleting carlos through the SSRF" width="100%">
</p>

The lab is marked as solved.

<p align="center">
  <img src="images/10-lab-solved.png" alt="Lab solved" width="100%">
</p>

A one-shot reproduction of the final request is provided in
[`scripts/exploit.sh`](scripts/exploit.sh).

## 5. Impact

SSRF turns the server into a proxy into the trusted internal network. Here it
granted unauthenticated access to an admin interface that is normally reachable
only from `localhost`, leading to account deletion (an integrity and
availability impact). In the real world the same primitive is routinely used to
reach cloud metadata endpoints, internal dashboards, and other back-end services
shielded only by network position. The attack requires no authentication and is
trivially reproducible once the payload is known.

Indicative severity: **High**.

## 6. Remediation

The root cause is trusting a host whitelist that is enforced with a different URL
parser than the one used to make the request. Parser-equivalence bugs make any
string-level allowlist fragile.

- **Primary fix**: parse the URL once with a single, strict parser, extract the
  host, and reject anything that is not an exact match for the allowed host.
  Re-use that parsed, normalised value to build the outgoing request - never the
  raw user string.
- **Reject ambiguity**: forbid embedded credentials (`@`), fragments, and
  encoded control characters in the supplied URL instead of trying to interpret
  around them.
- **Resolve and pin**: resolve the host to an IP and block private, loopback,
  and link-local ranges (including the cloud metadata IP) before connecting,
  guarding against DNS rebinding.
- **Least privilege / segmentation**: the internal admin interface should not be
  reachable from the application server, and should require authentication even
  from `localhost`.
- **Monitoring and logging**: log outbound fetch destinations and alert on
  requests to internal ranges.

Reference: OWASP Server-Side Request Forgery Prevention Cheat Sheet; CWE-918.

## Screenshot index

| # | File | Description |
|---|------|-------------|
| 01 | `01-lab-not-solved.png` | Lab in the not-solved state |
| 02 | `02-check-stock-feature.png` | Check stock feature on a product page |
| 03 | `03-intercepted-request-proxy.png` | Intercepted POST in the Burp proxy |
| 04 | `04-stockapi-request-repeater.png` | Baseline `stockApi` request in Repeater |
| 05 | `05-localhost-blocked.png` | Loopback target blocked by the whitelist |
| 06 | `06-embedded-credentials-accepted.png` | `userinfo@host` form accepted |
| 07 | `07-hash-rejected.png` | Raw `#` rejected by the validator |
| 08 | `08-admin-panel-via-ssrf.png` | Admin panel reached via `%2523` |
| 09 | `09-delete-carlos-request.png` | Request deleting carlos |
| 10 | `10-lab-solved.png` | Lab solved |
