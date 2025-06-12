def pass_completions_directory [] {
    if ($env | columns | any { |it| $it == "PASSWORD_STORE_DIR" }) {
        return $env.PASSWORD_STORE_DIR
    } else {
        return ("~/.password-store" | path expand)
    }
}

export def "nu-complete pass-files" [] {
    enter (pass_completions_directory)
    ls **/*.gpg
        | get name
        | each { || str replace ".gpg" "" }
}

export def "nu-complete pass-directories" [] {
    enter (pass_completions_directory)
    ls **
        | get name
        | where { |it| not (ls $it | is-empty) }
}

export def "nu-complete pass-gpg" [] {
    ^gpg --list-keys
        | lines
        | skip 2
        | split list ''
        | each { |entry|
            {
                value: ($entry.1 | str trim),
                description: ($entry.2 | parse --regex '^uid\s*\[[\w\s]*\]\s*(.*?)\s*$' | get 0.capture0)
            }
        }
}
