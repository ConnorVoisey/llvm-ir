#!/usr/bin/env bash
set -euo pipefail

# roundtrip.sh — compile this crate to LLVM IR, then parse it with itself
#
# Usage:
#   ./scripts/roundtrip.sh [--features <llvm-version>]
#
#   Compiles the llvm-ir crate sources to LLVM bitcode via cargo rustc,
#   then uses the crate's own parse example to load and display the result.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FEATURE="${LLVM_FEATURE:-llvm-19}"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --features)
            FEATURE="$2"
            shift 2
            ;;
        -*)
            echo "Unknown flag: $1"
            exit 1
            ;;
        *)
            echo "Usage: $0 [--features <llvm-version>]"
            exit 1
            ;;
    esac
done

# Step 1: Compile the crate to LLVM bitcode with cargo rustc
echo "=== Compiling llvm-ir crate to LLVM bitcode ==="
cd "$PROJECT_DIR"
RUSTFLAGS="--emit=llvm-bc -C opt-level=0" cargo rustc --features "$FEATURE" --lib -- -C lto=no 2>&1 | tail -3

# Find the generated .bc file
BC_FILE=$(find target/debug/deps -name 'llvm_ir-*.bc' -not -name '*.cgu.*' | head -1)
if [[ -z "$BC_FILE" ]]; then
    echo "Failed to find .bc file in target/debug/deps/"
    exit 1
fi
echo "  -> $BC_FILE ($(wc -c < "$BC_FILE" | tr -d ' ') bytes)"
echo

# Step 2: Parse it with the crate's own parse example
echo "=== Parsing with llvm-ir ($FEATURE) ==="
set +e
OUTPUT=$(cargo run --example parse --features "$FEATURE" -- "$BC_FILE" 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 0 ]; then
    echo "$OUTPUT"
else
    echo "Parse failed. This may be due to LLVM version mismatch."
    echo "System LLVM: $(llvm-config --version 2>/dev/null || echo 'unknown')"
    echo "Crate feature: $FEATURE"
    echo
    echo "Error output:"
    echo "$OUTPUT" | grep -E 'error|panicked|Failed' | head -5
fi
