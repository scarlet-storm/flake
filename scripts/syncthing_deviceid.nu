#! /usr/bin/env nu

def deviceid [cert: path] {
    # flawed actual implementation in syncthing (without reverse in luhn mod32)
    let s = open $cert | openssl x509 -outform der | hash sha256 -b | encode base32 | str trim -r -c '='
    let charlist = (seq char A Z) ++ (seq 2 7)
    let charmap = $charlist | enumerate | reduce --fold {} {|it, acc| $acc | upsert ($it.item | into string) $it.index}
    0..3 |  each {|i| $s | str substring ((13 * $i)..(13 * $i + 12))} |
    # each {|b| $b + ( $b| split chars | reverse | enumerate | reduce --fold 0 {|it, acc|
    each {|b| $b + ( $b| split chars | enumerate | reduce --fold 0 {|it, acc|
        let factor = if ($it.index mod 2 | into bool) { 2 } else { 1 }
        let addend = $factor * ($charmap | get $it.item)
        $acc + ($addend // 32) + ($addend mod 32) }|
    each {|s| let remainder = $s mod 32; (32 - $remainder) mod 32 }|
    each {|n| $charlist | get $n } | into string)} |
    each {|b| [ ($b | str substring 0..6)  ($b | str substring 7..13) ]} | flatten |
    reduce {|it, acc| $acc + "-" + $it}
}

def main [cert: path] {
    deviceid $cert
}
