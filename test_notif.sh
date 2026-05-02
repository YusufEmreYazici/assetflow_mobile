#!/bin/bash
TOKEN=$(curl -s -X POST https://api.mobnet.online/t/guvenok/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"emre@guvenok.com","password":"Test1234."}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token alındı: ${TOKEN:0:20}..."

STATUS=$(curl -s -o /tmp/notif_resp.txt -w "%{http_code}" \
  -X POST "https://api.mobnet.online/t/guvenok/api/notifications/test" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Length: 0")

echo "HTTP $STATUS"
cat /tmp/notif_resp.txt
