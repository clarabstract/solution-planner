#!/bin/sh
# Prints every requirement statement in this solution, without its test cases.
#
# Run it with no arguments, on macOS or Linux. It looks in the requirements
# folder above this script, and reads each .feature file only from its Feature
# line to the first keyword after it, so cases can't reach the output. Problems
# are reported by key, never by quoting the file.

solution=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 1
requirements="$solution/requirements"

if [ ! -d "$requirements" ]; then
  echo "No requirements folder at $requirements" >&2
  exit 1
fi

status=0
for file in "$requirements"/*/*.feature; do
  [ -f "$file" ] || continue

  name=${file##*/}
  group=${file%/*}
  key="${group##*/}.${name%.feature}"

  # A step before any keyword could be a misplaced case, and with no keyword
  # there's no telling where the statement ends. Both print nothing.
  statement=$(awk '
    NR == 1 { sub(/^\357\273\277/, "") }
    {
      line = $0
      sub(/\r$/, "", line)
      sub(/^[ \t]+/, "", line)
    }
    !feature {
      if (line ~ /^Feature:/) feature = 1
      next
    }
    line ~ /^(Background|Example|Examples|Rule|Scenario|Scenario Outline|Scenario Template|Scenarios):/ ||
    line ~ /^[@#]/ {
      ended = 1
      exit
    }
    line ~ /^(Given|When|Then|And|But)[ \t]/ || line ~ /^\*[ \t]/ {
      exit
    }
    { text = text " " line }
    END {
      if (ended) {
        gsub(/[ \t]+/, " ", text)
        sub(/^ /, "", text)
        sub(/ $/, "", text)
        print text
      }
    }
  ' "$file")

  if [ -n "$statement" ]; then
    printf '%s: %s\n' "$key" "$statement"
  else
    echo "$key: needs a Feature line, a statement, then a case" >&2
    status=1
  fi
done

exit "$status"
