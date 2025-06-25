# https://www.nushell.sh/cookbook/external_completers.html

let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {
        if ($in | path exists) {$'"(($in | path expand | str replace --all "\"" "\\\"" ) +
        (if ($in | split chars | last) == "/" { "/" } else { "" }))"'} else {$in}
    }
}

let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        _ => $fish_completer
    } | do $in $spans
}

$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
}
