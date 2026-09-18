fn main() {
    if let Err(error) = signals_numerical_adapter::self_check() {
        eprintln!("self-check failed: {error}");
        std::process::exit(1);
    }
    println!("signals numerical adapter self-check passed");

    #[cfg(feature = "hdf5")]
    if let Some(path) = std::env::var_os("SIGNALS_PDEBENCH_SOD6") {
        match signals_numerical_adapter::hdf5_io::read_pdebench_sod6(path) {
            Ok(dataset) => println!(
                "PDEBench Sod6 ingestion passed: {} snapshots x {} coordinates",
                dataset.snapshot_count(),
                dataset.spatial_count()
            ),
            Err(error) => {
                eprintln!("PDEBench Sod6 ingestion failed: {error}");
                std::process::exit(1);
            }
        }
    }
}
