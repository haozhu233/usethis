github_remotes <- function() {
  remotes <- git_remotes()
  if (length(remotes) == 0) return(NULL)
  m <- vapply(remotes, function(x) grepl("github", x), logical(1))
  if (length(m) == 0) return(NULL)
  remotes[m]
}

github_origin <- function() {
  r <- github_remotes()
  if (length(r) == 0) return(NULL)
  parse_github_remotes(r)[["origin"]]
}

github_owner <- function() {
  github_origin()[["owner"]]
}

github_source <- function() {
  upstream <- parse_github_remotes(github_remotes())[["upstream"]]
  upstream[["owner"]]
}

github_repo <- function() {
  github_origin()[["repo"]]
}

github_repo_spec <- function() {
  paste0(github_origin(), collapse = "/")
}

## repo_spec --> owner, repo
parse_repo_spec <- function(repo_spec) {
  repo_split <- strsplit(repo_spec, "/")[[1]]
  if (length(repo_split) != 2) {
    ui_stop("{ui_code('repo_spec')} must be of form {ui_value('owner/repo')}.")
  }
  list(owner = repo_split[[1]], repo = repo_split[[2]])
}

spec_owner <- function(repo_spec) parse_repo_spec(repo_spec)$owner
spec_repo <- function(repo_spec) parse_repo_spec(repo_spec)$repo

## named vector or list of Git remote URLs --> named list of (owner, repo)
parse_github_remotes <- function(x) {
  # https://github.com/r-lib/devtools.git --> rlib, devtools
  # https://github.com/r-lib/devtools     --> rlib, devtools
  # git@github.com:r-lib/devtools.git     --> rlib, devtools
  re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  ## on R < 3.4.2, regexec() fails to apply as.character() to first 2 args,
  ## though it is documented
  m <- regexec(re, as.character(x))
  match <- stats::setNames(regmatches(as.character(x), m), names(x))
  lapply(match, function(y) list(owner = y[[2]], repo = y[[3]]))
}
