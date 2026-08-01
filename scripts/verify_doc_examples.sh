#!/bin/bash
set -e

TOTAL_STEPS=3
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

PACKAGE=$(awk '/^name:/ {print $2; exit}' pubspec.yaml)
OUT="doc_examples_tmp"
SKIP_FILES="lib/src/error.dart \
lib/src/extensions/apply_if.dart \
lib/src/result.dart \
lib/src/types/array.dart \
lib/src/types/enum.dart \
lib/src/types/map.dart \
lib/src/types/object.dart \
lib/src/types/string.dart \
lib/src/types/transformed.dart \
lib/src/types/type.dart \
lib/src/v.dart \
lib/src/validators/string/card_brand_pattern.dart \
lib/src/validators/string/license_plate_pattern.dart \
lib/src/validators/string/license_plate_validator.dart \
lib/src/validators/string/phone_pattern.dart \
lib/src/validators/string/phone_validator.dart \
lib/src/validators/string/postal_code_pattern.dart \
lib/src/validators/string/tax_id_pattern.dart \
lib/src/validators/validator.dart"

EXTRA_IMPORTS=""
if grep -q "sdk: flutter" pubspec.yaml; then
  EXTRA_IMPORTS="package:flutter/foundation.dart package:flutter/widgets.dart"
fi

step "Cleaning previous run"
rm -rf "$OUT"
mkdir -p "$OUT"

cat > "$OUT/analysis_options.yaml" <<'YAML'
analyzer:
  language:
    strict-casts: true
  errors:
    unused_local_variable: ignore
    unused_element: ignore
    unused_import: ignore
YAML

step "Extracting samples from lib/"

TOTAL=0
SKIPPED=0

for FILE in $(find lib -name '*.dart' | sort); do
  COUNT=$(grep -c '/// ```dart' "$FILE" || true)

  if [ "$COUNT" -eq 0 ]; then
    continue
  fi

  case " $SKIP_FILES " in
    *" $FILE "*)
      SKIPPED=$((SKIPPED + COUNT))
      TOTAL=$((TOTAL + COUNT))
      echo "  skipped $FILE — $COUNT sample(s) excluded by SKIP_FILES"
      continue
      ;;
  esac

  TOTAL=$((TOTAL + COUNT))

  awk -v out="$OUT" -v q="'" -v package="$PACKAGE" -v extra="$EXTRA_IMPORTS" \
    -v base="$(basename "$FILE" .dart)" '
    function flush() {
      if (buffer == "") return

      name = sprintf("%s/%s_%d.dart", out, base, start)

      print "import " q "dart:async" q ";" > name
      print "" > name
      print "import " q "package:" package "/" package ".dart" q ";" > name

      count = split(extra, imports, " ")
      for (i = 1; i <= count; i++) {
        print "import " q imports[i] q ";" > name
      }

      print "" > name
      print "Future<void> example() async {" > name
      printf "%s", buffer > name
      print "}" > name
      close(name)

      buffer = ""
      start = 0
    }
    {
      line = $0
      sub(/^[ \t]*/, "", line)

      if (line ~ /^\/\/\//) {
        sub(/^\/\/\/ ?/, "", line)

        if (line ~ /^```dart/) {
          fenced = 1
          if (start == 0) start = NR
          next
        }

        if (line ~ /^```/) {
          fenced = 0
          next
        }

        if (fenced) buffer = buffer "  " line "\n"

        indoc = 1
        next
      }

      if (indoc) {
        flush()
        indoc = 0
      }
    }
    END { flush() }
  ' "$FILE"
done

FILES=$(find "$OUT" -name '*.dart' | wc -l | tr -d ' ')
echo "  $TOTAL sample(s) found, $SKIPPED skipped, $((TOTAL - SKIPPED)) extracted into $FILES file(s)"

step "Analyzing extracted samples"
dart analyze "$OUT"

rm -rf "$OUT"
