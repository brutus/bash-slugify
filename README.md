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

    Slugifies strings or filenames.

    usage: slugify [(l|u)|(x|X)|E|D|U|P|A|S|(c< char>|s)|C< char>|e|r|n|f|v|d|h]… <string>…

    character options
      -l  convert to lowercase
      -u  convert to uppercase
      -x  remove special chars
      -X  replace special chars

    space options
      -D  don't convert dashes to spaces
      -U  don't convert underscores to spaces
      -P  don't convert dots (points) to spaces
      -A  don't remove spaces around dashes and underscores
      -S  don't consolidate multiple spaces

    replacement options
      -c <char> replace all spaces with this (default: '-')
      -C <char> replace special chars with this (default: '_')
      -s use underscores for spaces (shortcut for '-c_')

    mode options
      -e  extended — treat all arguments as one string and echo one slug for it
      -r  rename files – treat arguments as filenames and rename them

    rename options
      -E  don't slugify file extensions
      -n  dry run — only show new file names (no renaming)
      -f  force — overwrite existing files

    other options
      -v  verbose output
      -d  debug output
      -h  print help

### Return Values

- `0` all went well
- `1` error parsing arguments
- `2` original string is empty
- `3` slugified string is empty
- `4` original file not found
- `5` slugified file exists


## Examples

    $ ./slugify.sh foo 'Hello World!' Bar
    foo
    Hello-World!
    Bar

    $ ./slugify.sh -e foo 'Hello World!' Bar
    foo-Hello-World!-Bar

    $ ./slugify.sh -el foo 'Hello World!' Bar
    foo-hello-world!-bar

    $ ./slugify.sh -exl foo Hello World! Bar
    foo-hello-world-bar

If you use the `-r` switch, arguments are threated as file names to be slugifed
(and renamed). Here's the output if you run it dry (no renaming) in the
directory of this repository — `$ ./slugify.sh -rn -lx *`:

    CHANGELOG.md -> changelog.md
    LICENSE -> license
    README.md -> readme.md
    src -> skipped (no change)
    tests -> skipped (no change)

## Development

Tested with [Bats]. Okay just barely…


[bats]: https://github.com/sstephenson/bats
