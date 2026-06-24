#!/usr/bin/env bash
# render.sh <input.mmd> [输出名]
# 把一个 mermaid .mmd 一键渲染成 svg(矢量)+ png(嵌入)。
# 自动配好 puppeteer(--no-sandbox)和 mmdc(放开 maxTextSize/maxEdges,支持超大图)。
# 依赖:Node(npx 会按需拉起 mermaid-cli,无需全局安装)。
set -euo pipefail
IN="${1:?用法: ./render.sh <input.mmd> [输出名,默认同输入名]}"
OUT="${2:-${IN%.mmd}}"
BG="#FBFAF7"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
echo '{"args":["--no-sandbox"]}' > "$TMP/puppeteer.json"
cat > "$TMP/mmdc.json" <<'JSON'
{ "maxTextSize": 9000000, "maxEdges": 5000,
  "flowchart": { "htmlLabels": true, "curve": "basis" } }
JSON
echo "→ 渲染 SVG(矢量)..."
npx -y @mermaid-js/mermaid-cli@latest -i "$IN" -o "$OUT.svg" -b "$BG" -p "$TMP/puppeteer.json" -c "$TMP/mmdc.json"
echo "→ 渲染 PNG(2x,嵌入用)..."
npx -y @mermaid-js/mermaid-cli@latest -i "$IN" -o "$OUT.png" -b "$BG" -p "$TMP/puppeteer.json" -c "$TMP/mmdc.json" -s 2
echo "✅ 完成: $OUT.svg  $OUT.png"
