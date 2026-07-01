# Security Write-ups

Hands-on security write-ups focused on classic web vulnerabilities. Each
write-up walks through a single vulnerability from reconnaissance to
exploitation, then covers impact and remediation.

All work is performed legally on dedicated practice platforms (PortSwigger Web
Security Academy, retired Hack The Box machines, or locally built labs). Nothing
here targets systems without explicit authorization.

## Index

| Write-up | Class | CWE | OWASP | Platform | Status |
|---|---|---|---|---|---|
| [Blind SQL injection (time-based) with data exfiltration](sql-injection/blind-sqli-time-delay/) | SQL Injection | CWE-89 | A03:2021 | PortSwigger | Done |
| [Reflected XSS behind a strict CSP (dangling markup exfiltration)](cross-site-scripting/strict-csp-dangling-markup/) | Cross-Site Scripting | CWE-79 | A03:2021 | PortSwigger | Done |
| [SSRF with whitelist-based input filter (URL parser confusion)](server-side-request-forgery/ssrf-whitelist-filter-bypass/) | Server-Side Request Forgery | CWE-918 | A10:2021 | PortSwigger | Done |

## Repository layout

```
writeups/
  <vulnerability-class>/
    <slug>/
      README.md      the write-up (renders on GitHub)
      images/        screenshots, numbered and named in English
      scripts/       any automation used (Python, etc.)
  templates/
    writeup-template.md    starting skeleton for a new write-up
    writeup.latex          Pandoc LaTeX template (cover page + table of contents)
    center-images.lua      Pandoc filter to center images in the PDF export
    pdf-header.tex         extra LaTeX preamble (code wrapping, tables)
  build-pdf.sh       Markdown to PDF export (Pandoc plus XeLaTeX)
  Makefile           "make pdf" builds every write-up PDF
```

## Conventions

- One directory per write-up, with its own `README.md`, `images/` and `scripts/`.
- Write-ups grouped by vulnerability class (OWASP category).
- Prose in English, ASCII only, no section separators.
- Screenshots numbered and named in English (`01-lab-not-solved.png`).
- Images centered and shown inline next to the matching explanation.

## PDF export

Each write-up can be exported to a formal PDF report from its single Markdown
source:

```
./build-pdf.sh sql-injection/blind-sqli-time-delay
```

or build every write-up at once:

```
make pdf
```

This requires `pandoc` and a LaTeX engine (`xelatex`). The PDF opens on a clean
cover page (title, author, and the `lab` / `cwe` / `owasp` / `difficulty` /
`dbms` / `platform` fields from the front matter), followed by the table of
contents on its own page, then the body. These fields are read from the YAML
front matter at the top of each `README.md`.

## License

Released under the [MIT License](LICENSE).
