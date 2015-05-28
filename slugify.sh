#!/usr/bin/env bash

# BASH SLUGIFY
#
# AUTHOR: Brutus [DMC] <brutus.dmc@googlemail.com>
# LICENSE: GNU General Public License v3 or above -
#          http://www.opensource.org/licenses/gpl-3.0.html'
#
# ERROR CODES:
#
# 0 all went well
# 1 error parsing arguments
# 2 original string is empty
# 3 slugified string is empty

if [ "$(basename -- $0)" == "bash" ]; then
  MAIN=0
else
  MAIN=1
fi

VERSION='0.1.0'


### OPTIONS

# character options
TO_UPPERCASE=0
TO_LOWERCASE=0
REMOVE_SPECIAL_CHARS=0
REPLACE_SPECIAL_CHARS=0

# space options
KEEP_DASHES=0
KEEP_UNDERSCORES=0
KEEP_DOTS=0
KEEP_SPACES_AROUND_DASHSCORES=0
CONSOLIDATE_SPACES=1

# replacement options
SPACE_CHAR='-'
REPLACE_CHAR='_'

# mode options
DRY_RUN=0
EXTEND=0

# other options
VERBOSE=0
DEBUG=0


### ARGUMENTS

OPTS_STRING=':lurxDUASc:C:snevdh'
OPTION_STRING='[(l|u)|(r|x)|D|U|A|S|(c <char>|s)|C <char>|n|e|v|d|h]…'
USAGE="usage: slugify $OPTION_STRING <filename>…"
DESCRIPTION='Changes the names of all given files to their slugs.'

HELP="$USAGE

$DESCRIPTION

character options
  -l  convert to lowercase
  -u  convert to uppercase
  -r  remove special chars
  -x  replace special chars

space options
  -D  don't convert dashes to spaces
  -U  don't convert underscores to spaces
  -P  don't convert points to spaces
  -A  don't remove spaces around dashes and underscores
  -S  don't consolidate multiple spaces

replacement options
  -c <char> replace all spaces with this (default: '-')
  -C <char> replace special chars with this (default: '_')
  -s use underscores for spaces (shortcut for '-c_')

mode options
  -n  dry run – don't rename anything
  -e  extended – treat all arguments as one string (no rename)

other options
  -v  verbose output
  -d  debug output
  -h  print help"

function print_usage(){
  echo "$HELP"
  exit ${1:-0}
}

function print_options(){
  >&2 echo '# OPTIONS'
  >&2 echo '# ======='
  >&2 echo '#'
  >&2 echo '# [character options]'
  >&2 echo "# TO_UPPERCASE: $TO_UPPERCASE"
  >&2 echo "# TO_LOWERCASE: $TO_LOWERCASE"
  >&2 echo "# REMOVE_SPECIAL_CHARS: $REMOVE_SPECIAL_CHARS"
  >&2 echo "# REPLACE_SPECIAL_CHARS: $REPLACE_SPECIAL_CHARS"
  >&2 echo '#'
  >&2 echo '# [space options]'
  >&2 echo "# KEEP_DASHES: $KEEP_DASHES"
  >&2 echo "# KEEP_UNDERSCORES: $KEEP_UNDERSCORES"
  >&2 echo "# KEEP_DOTS: $KEEP_DOTS"
  >&2 echo "# KEEP_SPACES_AROUND_DASHSCORES: $KEEP_SPACES_AROUND_DASHSCORES"
  >&2 echo "# CONSOLIDATE_SPACES: $CONSOLIDATE_SPACES"
  >&2 echo '#'
  >&2 echo '# [replacement options]'
  >&2 echo "# SPACE_CHAR: '$SPACE_CHAR'"
  >&2 echo "# REPLACE_CHAR: '$REPLACE_CHAR'"
  >&2 echo '#'
  >&2 echo '# [mode options]'
  >&2 echo "# DRY_RUN: $DRY_RUN"
  >&2 echo "# EXTEND: $EXTEND"
  >&2 echo '#'
  >&2 echo '# [other options]'
  >&2 echo "# VERBOSE: $VERBOSE"
  >&2 echo "# DEBUG: $DEBUG"
}

function get_arguments() {
  while getopts $OPTS_STRING opt "$@"; do
    case $opt in
      l)
        TO_LOWERCASE=1
        ;;
      u)
        TO_UPPERCASE=1
        ;;
      r)
        REMOVE_SPECIAL_CHARS=1
        ;;
      x)
        REPLACE_SPECIAL_CHARS=1
        ;;
      D)
        KEEP_DASHES=1
        ;;
      U)
        KEEP_UNDERSCORES=1
        ;;
      U)
        KEEP_DOTS=1
        ;;
      A)
        KEEP_SPACES_AROUND_DASHSCORES=1
        ;;
      S)
        CONSOLIDATE_SPACES=0
        ;;
      c)
        SPACE_CHAR=$OPTARG
        ;;
      C)
        REPLACE_CHAR=$OPTARG
        ;;
      s)
        SPACE_CHAR='_'
        ;;
      n)
        DRY_RUN=1
        ;;
      e)
        EXTEND=1
        ;;
      v)
        VERBOSE=1
        ;;
      d)
        DEBUG=1
        ;;
      h)
        print_usage
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
  done
  if [ $TO_LOWERCASE -eq 1 -a $TO_UPPERCASE -eq 1 ]; then
    echo "'-l' and '-u' can't be used together." >&2
    exit 1
  fi
  if [ $REMOVE_SPECIAL_CHARS -eq 1 -a $REPLACE_SPECIAL_CHARS -eq 1 ]; then
    echo "'-r' and '-x' can't be used together." >&2
    exit 1
  fi
}


### SLUGIFY

function slugify(){
  # echos the slugify version of all args consolidated

  local name="$@"
  local safechars='-_. a-zA-Z0-9'

  if [ -z "$name" ]; then
    echo "[ERROR] need a string to slugify."
    exit 2
  fi

  ## HANDLE CHARACTERS

  # convert to uppercase
  if [ $TO_UPPERCASE -eq 1 ]; then
    name=$(echo "$name" | tr a-zäöü A-ZÄÖÜ)
  fi

  # convert to lowercase
  if [ $TO_LOWERCASE -eq 1 ]; then
    name=$(echo "$name" | tr A-ZÄÖÜ a-zäöü)
  fi

  # replace special chars
  if [ $REPLACE_SPECIAL_CHARS -eq 1 ]; then
    name=$(echo "${name//[^${safechars}]/$REPLACE_CHAR}")
  fi

  # remove special chars
  if [ $REMOVE_SPECIAL_CHARS -eq 1 ]; then
    name=$(echo "${name//[^${safechars}]/}")
  fi

  ## HANDLE SPACES

  # remove dashes?
  if [ $KEEP_DASHES -eq 0 ]; then
    name=$(echo "${name//-/' '}")
  fi

  # remove underscores?
  if [ $KEEP_UNDERSCORES -eq 0 ]; then
    name=$(echo "${name//_/ }")
  fi

  # remove dots?
  if [ $KEEP_DOTS -eq 0 ]; then
    name=$(echo "${name//./ }")
  fi

  # consolidate spaces
  if [ $CONSOLIDATE_SPACES -eq 1 ]; then
    name=$(echo "${name}" | tr -s '[:space:]')
  fi

  # keep spaces around dashes and underscores?
  if [ $KEEP_SPACES_AROUND_DASHSCORES -eq 0 ]; then
    name=$(echo "${name// -/-}")
    name=$(echo "${name//- /-}")
    name=$(echo "${name// _/_}")
    name=$(echo "${name//_ /_}")
  fi

  ## REPLACE SPACE

  name=$(echo "${name// /$SPACE_CHAR}")

  echo "$name"
}

## MODES

function rename_with_slug(){
  # creates a newname with slugify and tries to rename the file
  name="$@"
  echo "- $name"
  newname=$(slugify "$@")
  echo "  $newname"
  if [ $DRY_RUN -eq 0 ]; then
    echo "  -> rename"
    # TODO: rename file
  fi
}


## MAIN

if [ $MAIN -eq 1 ]; then
  # parse commandline
  get_arguments "$@"
  shift $((OPTIND-1))
  # check args
  if [ $# -eq 0 ]; then
    print_usage 1
  fi
  # print verbose stuff
  if [ $DEBUG -eq 1 ]; then
    print_options
    echo "#" >&2
    echo "# ARGUMENTS" >&2
    echo "# =========" >&2
    for fn in "$@"; do
      echo "# - $fn" >&2
    done
  fi
  # loop over args
  if [ $EXTEND -eq 1 ]; then
    echo "$(slugify $@)"
  else
    for fn in "$@"; do
      rename_with_slug $fn
    done
  fi
fi
