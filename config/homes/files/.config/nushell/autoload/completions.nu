# https://github.com/nushell/nushell/pull/14781
# Return null to fallback to internal completions if external completer list is empty
let completer = $env.config.completions.external.completer
let wrapped_completer = (if $completer == null { null } else {
  {|spans|
    let completions = do $completer $spans
    if ($completions | is-empty) {null} else {$completions}
  }
})
$env.config.completions.external.completer = $wrapped_completer
