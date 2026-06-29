#!/usr/bin/env bash
set -euo pipefail

# roundtrip.sh — compile Rust source to LLVM IR, then parse it with llvm-ir
#
# Usage:
#   ./scripts/roundtrip.sh [--features <llvm-version>] [rust_source.rs]
#
#   If no Rust source is given, generates a simple fibonacci function.
#   LLVM version defaults to the feature in Cargo.toml or llvm-19.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FEATURE="${LLVM_FEATURE:-llvm-19}"
RUST_SRC=""
CLEANUP_FILES=()

cleanup() {
    for f in "${CLEANUP_FILES[@]}"; do
        rm -f "$f"
    done
}
trap cleanup EXIT

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
            RUST_SRC="$1"
            shift
            ;;
    esac
done

# Generate Rust source if not provided
if [[ -z "$RUST_SRC" ]]; then
    RUST_SRC="$(mktemp /tmp/llvm_ir_demo_XXXXXX.rs)"
    CLEANUP_FILES+=("$RUST_SRC")
    cat > "$RUST_SRC" << 'RUSTEOF'
#[no_mangle]
pub fn fib(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fib(n - 1) + fib(n - 2),
    }
}

#[no_mangle]
pub fn add_one(x: i32) -> i32 {
    x + 1
}

fn main() {
    println!("fib(10) = {}", fib(10));
    println!("add_one(41) = {}", add_one(41));
}
RUSTEOF
    echo "=== Generated demo source ==="
    cat "$RUST_SRC"
    echo
fi

# Compile to LLVM bitcode
BC_FILE="${RUST_SRC%.rs}.bc"
LL_FILE="${RUST_SRC%.rs}.ll"
CLEANUP_FILES+=("$BC_FILE" "$LL_FILE")
echo "=== Compiling to LLVM IR with rustc ==="
rustc --emit=llvm-bc,llvm-ir -C opt-level=0 -o "$BC_FILE" "$RUST_SRC" --edition 2021
echo "  -> $LL_FILE"
echo

# Parse with llvm-ir (prefer bitcode, fallback to text IR)
echo "=== Parsing with llvm-ir ($FEATURE) ==="
cd "$PROJECT_DIR"
set +e
OUTPUT=$(cargo run --example parse --features "$FEATURE" -- "$BC_FILE" 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 0 ]; then
    echo "$OUTPUT"
    exit 0
fi
echo "Bitcode parse failed, trying text IR..."
set +e
OUTPUT=$(cargo run --example parse --features "$FEATURE" -- "$LL_FILE" 2>&1)
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
