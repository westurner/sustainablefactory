fn main() {
    if let Err(error) = signals_numerical_adapter::self_check() {
        eprintln!("self-check failed: {error}");
        std::process::exit(1);
    }
    println!("signals numerical adapter self-check passed");
}
