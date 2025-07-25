#!/bin/bash

# Tool: Blind Web Tester
# Author: Aakil Mirza
# Description: Basic web penetration testing tool for blind users using screen readers.

clear
echo "=========================================="
echo "         Blind Web Tester v1.0            "
echo "=========================================="
echo ""

read -p "Enter target URL (e.g. https://example.com): " target

echo ""
echo "[*] Checking HTTP headers..."
curl -I --silent "$target" > headers.txt
cat headers.txt | grep -iE "Server:|X-Powered-By:|Content-Security-Policy|Strict-Transport-Security"

echo ""
echo "[*] Detecting CMS using common paths..."
for path in "/wp-login.php" "/administrator/" "/user/login" "/xmlrpc.php"
do
    status=$(curl -o /dev/null -s -w "%{http_code}" "$target$path")
    if [[ "$status" == "200" ]]; then
        echo "[+] Found possible CMS path: $path"
    fi
done

echo ""
echo "[*] Starting directory enumeration using wordlist..."
wordlist="/usr/share/wordlists/dirb/common.txt"
while read word; do
    url="$target/$word"
    code=$(curl -o /dev/null -s -w "%{http_code}" "$url")
    if [[ "$code" == "200" ]]; then
        echo "[+] Found: $url (Status: 200)"
    fi
done < "$wordlist"

echo ""
echo "[*] Suggesting basic payloads for SQLi and XSS testing:"
echo "  - SQLi Test URL: ${target}?id=1' OR '1'='1"
echo "  - XSS Test URL: ${target}?q=<script>alert(1)</script>"

echo ""
echo "[*] Test completed."
echo "Results saved in: headers.txt"
