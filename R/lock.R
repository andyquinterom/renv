
the$lock_registry <- new.env(parent = emptyenv())

renv_lock_acquire <- function(path) {

  # normalize path
  path <- renv_lock_path(path)
  dlog("lock", "%s [acquiring lock]", renv_path_pretty(path))

  # if we already have this lock, increment our counter
  lock <- the$lock_registry[[path]]
  if (!is.null(lock)) {
    lock_reacquire(lock)
    return(TRUE)
  }

  # make sure parent directory exists
  ensure_parent_directory(path)

  # suppress warnings in this scope
  renv_scope_options(warn = -1L)

  the$lock_registry[[path]] <- acquire_lock_infallible(path)

  # notify the watchdog
  renv_watchdog_notify("LockAcquired", list(path = path))

  # TRUE to mark successful lock
  dlog("lock", "%s [lock acquired]", renv_path_pretty(path))
  TRUE

}


renv_lock_release <- function(path) {

  # normalize path
  path <- renv_lock_path(path)

  # decrement our lock count
  lock <- the$lock_registry[[path]]
  if (!is.null(lock)) {
    release_lock(lock)
  }

}

renv_lock_orphaned <- function(path) {

}

renv_lock_refresh <- function(lock) {
}

renv_lock_unload <- function() {
}

renv_lock_path <- function(path) {

  file.path(
    renv_path_normalize(dirname(path), mustWork = TRUE),
    basename(path)
  )

}
