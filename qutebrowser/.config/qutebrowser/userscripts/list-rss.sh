#!/usr/bin/env bash

set -euo pipefail

xpath='//link[@rel="alternate"][contains(@type,"rss") or contains(@type,"atom") or contains(@type,"rdf") or contains(@type,"xml")]/@href'

html=''
while IFS= read -r href; do
    [ -z "$href" ] && continue
    url=$(python3 -c 'import sys, html, urllib.parse as u; print(html.escape(u.urljoin(sys.argv[1], html.unescape(sys.argv[2]))))' "$QUTE_URL" "$href")
    html+="<a href=\"${url}\">${url}</a><br>"$'\n'
done < <(
    xmllint --html --xpath "$xpath" "$QUTE_HTML" 2>/dev/null \
        | grep -oP 'href="\K[^"]*'
)

if [ -z "$html" ]; then
    html='<p>None.</p>'
fi

base64_str=$(printf '%s' "$html" | base64 -w0)
data_url="data:text/html;base64,${base64_str}"

printf 'open -t %s\n' "$data_url" > "$QUTE_FIFO"
