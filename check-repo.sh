#!/bin/bash
# Run from repo root: bash check-repo.sh
# Or: chmod +x check-repo.sh && ./check-repo.sh echo "=== CHECKING REPO BEFORE RUN ==="

echo ""

echo "--- 1. Dangerous patterns (eval, exec, private keys) ---"
grep -rnE "eval\(|exec\(|Function\(|process\.env\.(Wallet|Private|Key|Secret|EKEY)" --include="*.js" --include="*.ts" --exclude-dir=node_modules . 2>/dev/null || echo "  (none found)"
echo ""
echo "--- 2. Base64 / encoded strings ---"
grep -rnE "atob|btoa|Buffer\.from\(.*base64" --include="*.js" --include="*.ts" --exclude-dir=node_modules . 2>/dev/null || echo "  (none found)"
echo ""
echo "--- 3. Config file lengths (obfuscation = very long) ---"
found_any=false
for f in tailwind.config.js webpack.config.js babel.config.js postcss.config.js vite.config.js; do
  if [ -f "$f" ]; then
    found_any=true
    lines=$(wc -l < "$f")
    echo "  $f: $lines lines"
    if [ "$lines" -gt 100 ]; then
      echo -e "\033[0;31m  ^ WARNING: Config > 100 lines - scroll to end and check for obfuscated code\033[0m"
    fi
  fi
done
if [ "$found_any" = false ]; then
  echo "  (none found)"
fi
echo ""
echo "--- 4. Post install / preinstall scripts ---"
grep -E "postinstall|preinstall|prepare" package.json backend/package.json 2>/dev/null || echo "  (none found)"
echo ""
echo "--- 5. Suspicious dependencies (0.0.0, 0.0.1) ---"
grep -E '"[^"]+":\s*"0\.0\.[01]"' package.json backend/package.json 2>/dev/null || echo "  (none found)"
echo ""
echo "=== DONE ==="
echo "Review the output above. If you see:"
echo "  - Unknown external URLs (not Infura, Alchemy, your backend)"
echo "  - process.env.Wallet* or process.env.*Private* sent anywhere"
echo "  - Config files with 100+ lines (scroll to end and look for hex/obfuscation)"
echo "  - post install scripts from unknown packages"
echo "  -> DO NOT RUN npm install or npm start. Investigate further or run in Docker only!"
