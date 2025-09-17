
renv_ext_enabled <- function() {

  # disable on Windows; may be able to re-evaluate in future
  if (renv_platform_windows())
    return(FALSE)

  # otherwise, check envvar
  truthy(Sys.getenv("RENV_EXT_ENABLED", unset = "TRUE"))

}
