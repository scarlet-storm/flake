let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | from tsv --flexible --noheaders --no-infer
    | rename value description
}
$env.config = {
    completions: {
        algorithm: "fuzzy"
        external: {
            enable: true
            completer: $fish_completer
        }
    }
}
