use fs2::FileExt;
use std::fs::File;

use extendr_api::prelude::*;

#[extendr]
struct RenvLock {
    path: Box<str>,
    file: File,
    count: usize,
}

fn acquire_lock(path: &str) -> Result<RenvLock> {
    let file = File::options()
        .read(true)
        .write(true)
        .create(true)
        .open(path)
        .map_err(|e| e.to_string())?;

    file.lock_exclusive().map_err(|e| e.to_string())?;

    Ok(RenvLock {
        file: file,
        count: 0,
        path: path.into(),
    })
}

#[extendr]
fn acquire_lock_infallible(file: &str) -> RenvLock {
    loop {
        if let Ok(lock) = acquire_lock(file) {
            return lock;
        }
    }
}

#[extendr]
fn lock_reacquire(lock: &mut RenvLock) {
    if lock.count == 0 {
        while lock.file.lock().is_err() {}
    }
    lock.count += 1;
}

#[extendr]
fn release_lock(lock: &mut RenvLock) {
    if lock.count == 1 {
        let _ = lock.file.unlock();
    }
    lock.count = 0;
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod renv;
    fn acquire_lock_infallible;
    fn lock_reacquire;
    fn release_lock;
}
