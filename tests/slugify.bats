#!/usr/bin/env bats

slugify='./src/slugify.sh'


@test "test with no arguments" {
  run $slugify
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "[ERROR] at least one argument is needed. Try '-h' for help." ]
}


@test "test exclusive arguments" {
  run $slugify -lu test
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "[ERROR] '-l' and '-u' can't be used together." ]

  run $slugify -xX test
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "[ERROR] '-x' and '-X' can't be used together." ]

  run $slugify -sc . test
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "[ERROR] '-c' and '-s' can't be used together." ]
}


@test "multiple strings" {
  run $slugify asd
  [ $output = 'asd' ]

  run $slugify 'hello asd'
  [ $output = 'hello-asd' ]

  run $slugify hello asd
  [ "${lines[0]}" = 'hello' ]
  [ "${lines[1]}" = 'asd' ]
}


@test "basic examples" {
  run $slugify 'HeLlo, fine WOrld!'
  [ $output = 'HeLlo,-fine-WOrld!' ]

  run $slugify -x 'HeLlo, fine WOrld!'
  [ $output = 'HeLlo-fine-WOrld' ]

  run $slugify -X 'HeLlo, fine WOrld!'
  [ $output = 'HeLlo_-fine-WOrld_' ]

  run $slugify -xl 'HeLlo, fine WOrld!'
  [ $output = 'hello-fine-world' ]
}


@test "extended mode" {
  run $slugify -exl HeLlo, fine WOrld!
  [ $output = 'hello-fine-world' ]

  run $slugify -eX HeLlo, fine WOrld!
  [ $output = 'HeLlo_-fine-WOrld_' ]

  run $slugify -eXC. HeLlo, fine WOrld!
  [ $output = 'HeLlo.-fine-WOrld.' ]

  run $slugify -exs HeLlo, fine WOrld!
  [ $output = 'HeLlo_fine_WOrld' ]

  run $slugify -exc. HeLlo, fine WOrld!
  [ $output = 'HeLlo.fine.WOrld' ]

  run $slugify -exu HeLlo, fine WOrld!
  [ $output = 'HELLO-FINE-WORLD' ]

  run $slugify -exl HeLlo, fine WOrld!
  [ $output = 'hello-fine-world' ]

  run $slugify -eux HeLlo, C:3!
  [ $output = 'HELLO-C3' ]

  run $slugify -elX -C '.' HeLlo, C:3!
  [ $output = 'hello.-c.3.' ]
}


@test "extension" {
  run $slugify -rn -xl 'HeLlo, fine WOrld!.tXt'
  [ $output = 'hello-fine-world.txt' ]

  run $slugify -rn -xu 'HeLlo, fine WOrld!.tXt'
  [ $output = 'HELLO-FINE-WORLD.TXT' ]

  run $slugify -rn -xlE 'HeLlo, fine WOrld!.tXt'
  [ $output = 'hello-fine-world.tXt' ]

  run $slugify -rn -xuE 'HeLlo, fine WOrld!.tXt'
  [ $output = 'HELLO-FINE-WORLD.tXt' ]

  run $slugify -rn -xl 'HeLlo, fine WOrld!.t+X+t'
  [ $output = 'hello-fine-world.txt' ]

  run $slugify -rn -xlE 'HeLlo, fine WOrld!.t+X+t'
  [ $output = 'hello-fine-world.t+X+t' ]

  run $slugify -rn -Xl 'HeLlo, fine WOrld!.t+X+t'
  [ $output = 'hello_-fine-world_.t_x_t' ]

  run $slugify -rn -XlE 'HeLlo, fine WOrld!.t+X+t'
  [ $output = 'hello_-fine-world_.t+X+t' ]
}
