#![cfg(feature = "llvm-22-or-greater")]

//! LLVM 22-specific tests

use llvm_ir::Module;
use llvm_ir::terminator;
use llvm_ir::Terminator;
use std::path::Path;

macro_rules! llvm_test {
    ($path:expr, $func:ident) => {
        #[test]
        #[allow(non_snake_case)]
        fn $func() {
            let _ = env_logger::builder().is_test(true).try_init();
            let path = Path::new($path);
            let _ = Module::from_bc_path(&path).expect("Failed to parse module");
        }
    };
}

llvm_test!(
    "tests/llvm_bc/compatibility-as-of-llvm-22.bc",
    compatibility_llvm_22
);

#[test]
fn switch_case_values_llvm22() {
    let _ = env_logger::builder().is_test(true).try_init();
    let path = Path::new("tests/basic_bc/llvm22/switch.bc");
    let module = Module::from_bc_path(path).expect("Failed to parse module");

    let func = module
        .functions
        .iter()
        .find(|func| func.name == "has_a_switch")
        .expect("has_a_switch function should exist");

    // Find the switch terminator
    let switch = func.basic_blocks.iter().find_map(|bb| {
        if let Terminator::Switch(s) = &bb.term {
            Some(s)
        } else {
            None
        }
    }).expect("Should have a Switch terminator");

    // Verify we have 9 case destinations
    assert_eq!(switch.dests.len(), 9, "Expected 9 switch cases");

    // Verify specific case values are present
    let expected_cases = vec![
        (0, "12"),
        (1, "2"),
        (13, "3"),
        (26, "4"),
        (33, "5"),
        (142, "6"),
        (1678, "7"),
        (88, "8"),
        (101, "9"),
    ];

    for (i, (expected_val, expected_dest)) in expected_cases.iter().enumerate() {
        let (case_val, case_dest) = &switch.dests[i];
        assert_eq!(
            case_dest.to_string(),
            format!("%{}", expected_dest),
            "Case {} destination mismatch", i
        );
        assert_eq!(
            format!("{}", case_val),
            if *expected_val == 0 {
                "i32 0".to_string()
            } else {
                format!("i32 {}", expected_val)
            },
            "Case {} value mismatch", i
        );
    }

    // Default dest should be label %10
    assert_eq!(switch.default_dest.to_string(), "%10");
}
