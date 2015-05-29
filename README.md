# BASH Slugify

It slugifies strings. In your BASH.

I need to clean filenames — like uploaded images and the like — regularly and
this helps me automate it.


## What's happening?

- Optionally convert to upper- or lower case (default: no change).

- Optionally all *special chars* (`[^a-zA-Z0-9]`) are removed or replaced
  (default: `_`).

- Optionally all *glue characters* (`[-_.]`) are replaced with spaces (but
  there are options to keep them).

- Whitespace is consolidated and trimmed.

- All remaining spaces are replaced (default: `-`).


## Usage

    usage: slugify [(l|u)|(r|x)|D|U|P|A|S|E|(c <char>|s)|C <char>|e|m|n|f|v|d|h]… <filename>…

    List slugs for the given files.

    character options
      -l  convert to lowercase
      -u  convert to uppercase
      -r  remove special chars
      -x  replace special chars

    space options
      -D  don't convert dashes to spaces
      -U  don't convert underscores to spaces
      -P  don't convert dots (points) to spaces
      -A  don't remove spaces around dashes and underscores
      -S  don't consolidate multiple spaces
      -E  don't slugify extension

    replacement options
      -c <char> replace all spaces with this (default: '-')
      -C <char> replace special chars with this (default: '_')
      -s use underscores for spaces (shortcut for '-c_')

    mode options
      -e  extend — echo a slug for all arguments as one string (no rename)
      -m  move – rename files
      -n  dry run — show what would be renamed (don't do it)
      -f  force — overwrite existing files (on rename)

    other options
      -v  verbose output
      -d  debug output
      -h  print help

### Return Values

- `0` all went well
- `1` error parsing arguments
- `2` original string is empty
- `3` slugified string is empty


## Examples

    $ ./slugify.sh -er HeLlo, fine WOrld!
    HeLlo-fine-WOrld

    $ ./slugify.sh -erl HeLlo, fine WOrld!
    hello-fine-world

    $ ./slugify.sh -eur HeLlo, C:3!
    HELLO-C3

    $ ./slugify.sh -euxU HeLlo, C:3!
    HELLO_C_3_


## Development

Tested with [Bats]. Okay just barely…


[bats]: https://github.com/sstephenson/bats
