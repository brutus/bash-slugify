#!/usr/bin/env bats

slugify='./src/slugify.sh'

@test "test with no arguments" {
  run $slugify
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "[ERROR] at least one argument is needed. Try '-h' for help." ]
}

@test "examples" {
  run $slugify -er HeLlo, fine WOrld!
  [ $output = 'HeLlo-fine-WOrld' ]

  run $slugify -erl HeLlo, fine WOrld!
  [ $output = 'hello-fine-world' ]

  run $slugify -eur HeLlo, C:3!
  [ $output = 'HELLO-C3' ]

  run $slugify -euxU HeLlo, C:3!
  [ $output = 'HELLO_C_3_' ]
}
