use std::env;
use std::path::Path;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <file.ll|file.bc>", args[0]);
        process::exit(1);
    }
    let path = &args[1];

    let module = if Path::new(path).extension().map_or(false, |e| e == "bc") {
        match llvm_ir::Module::from_bc_path(path) {
            Ok(m) => m,
            Err(e) => {
                eprintln!("Failed to parse bitcode {}: {}", path, e);
                process::exit(1);
            }
        }
    } else {
        match llvm_ir::Module::from_ir_path(path) {
            Ok(m) => m,
            Err(e) => {
                eprintln!("Failed to parse IR {}: {}", path, e);
                process::exit(1);
            }
        }
    };

    println!("=== Module: {} ===", path);
    println!("Functions: {}", module.functions.len());
    println!("Function declarations: {}", module.func_declarations.len());
    println!("Global variables: {}", module.global_vars.len());
    println!("Global aliases: {}", module.global_aliases.len());

    for func in &module.functions {
        println!(
            "\n  {} ({} blocks, {} params)",
            func.name,
            func.basic_blocks.len(),
            func.parameters.len(),
        );
        for bb in &func.basic_blocks {
            println!("    {}: {} instructions", bb.name, bb.instrs.len());
            for inst in &bb.instrs {
                println!("      {}", inst);
            }
            println!("      term: {}", bb.term);
        }
    }
}
