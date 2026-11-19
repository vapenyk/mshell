#!/bin/sh
# Lists QML/JS files that nothing else references. Run from the project root.
# A file is "used" if its base name appears in any other QML/JS file.
# Entry points and tests are excluded.
for dir in components services modules utils config; do
  [ -d "$dir" ] || continue
  find "$dir" -type f \( -name '*.qml' -o -name '*.js' \)
done | while read -r f; do
      name=$(basename "$f"); base=${name%%.*}
      case "$base" in shell) continue ;; esac
      n=$(grep -rlw --include='*.qml' --include='*.js' "$base" . 2>/dev/null | grep -v "^./$f$" | grep -v '^./tests/' | wc -l)
      [ "$n" -eq 0 ] && echo "UNUSED: $f"
    done
exit 0
