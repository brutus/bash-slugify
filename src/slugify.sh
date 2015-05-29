#!/usr/bin/env bash
#
# BASH SLUGIFY
#
# AUTHOR: Brutus [DMC] <brutus.dmc@googlemail.com>
# LICENSE: GNU General Public License v3 or above -
#          http://www.opensource.org/licenses/gpl-3.0.html'
#
# ERROR CODES:
#
# 0: all went well
# 1: error parsing arguments
# 2: original string is empty
# 3: slugified string is empty

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
IGNORE_EXT=0

# replacement options
SPACE_CHAR='-'
REPLACEMENT_CHAR='_'

# mode options
EXTEND=0
MOVE=0
DRY_RUN=0
FORCE=0

# other options
VERBOSE=0
DEBUG=0


### ARGUMENTS

OPTS_STRING=':lurxDUPASEc:C:semnfvdh'
OPTION_STRING='[(l|u)|(r|x)|D|U|P|A|S|E|(c <char>|s)|C <char>|e|m|n|f|v|d|h]…'
USAGE="usage: slugify ${OPTION_STRING} <filename>…"
DESCRIPTION='Slugifies filenames. List or changes the names of given files.'

HELP="${USAGE}

${DESCRIPTION}

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
  -h  print help"


function print_usage(){
  echo "${USAGE}"
  exit ${1:-0}
}


function print_help(){
  echo "${HELP}"
  exit ${1:-0}
}


function print_options(){
  >&2 echo '# OPTIONS'
  >&2 echo '# ======='
  >&2 echo '#'
  >&2 echo '# [character options]'
  >&2 echo "# TO_UPPERCASE: ${TO_UPPERCASE}"
  >&2 echo "# TO_LOWERCASE: ${TO_LOWERCASE}"
  >&2 echo "# REMOVE_SPECIAL_CHARS: ${REMOVE_SPECIAL_CHARS}"
  >&2 echo "# REPLACE_SPECIAL_CHARS: ${REPLACE_SPECIAL_CHARS}"
  >&2 echo '#'
  >&2 echo '# [space options]'
  >&2 echo "# KEEP_DASHES: ${KEEP_DASHES}"
  >&2 echo "# KEEP_UNDERSCORES: ${KEEP_UNDERSCORES}"
  >&2 echo "# KEEP_DOTS: ${KEEP_DOTS}"
  >&2 echo "# KEEP_SPACES_AROUND_DASHSCORES: ${KEEP_SPACES_AROUND_DASHSCORES}"
  >&2 echo "# CONSOLIDATE_SPACES: ${CONSOLIDATE_SPACES}"
  >&2 echo "# IGNORE_EXT: ${IGNORE_EXT}"
  >&2 echo '#'
  >&2 echo '# [replacement options]'
  >&2 echo "# SPACE_CHAR: '${SPACE_CHAR}'"
  >&2 echo "# REPLACEMENT_CHAR: '${REPLACEMENT_CHAR}'"
  >&2 echo '#'
  >&2 echo '# [mode options]'
  >&2 echo "# EXTEND: ${EXTEND}"
  >&2 echo "# MOVE: ${MOVE}"
  >&2 echo "# DRY_RUN: ${DRY_RUN}"
  >&2 echo "# FORCE: ${FORCE}"
  >&2 echo '#'
  >&2 echo '# [other options]'
  >&2 echo "# VERBOSE: ${VERBOSE}"
  >&2 echo "# DEBUG: ${DEBUG}"
}


function get_arguments() {
  local set_space_char=0
  while getopts ${OPTS_STRING} opt "$@"; do
    case ${opt} in
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
      P)
        KEEP_DOTS=1
        ;;
      A)
        KEEP_SPACES_AROUND_DASHSCORES=1
        ;;
      S)
        CONSOLIDATE_SPACES=0
        ;;
      E)
        IGNORE_EXT=0
        ;;
      c)
        SPACE_CHAR=${OPTARG}
        set_space_char=$((${set_space_char} + 1))
        ;;
      C)
        REPLACEMENT_CHAR=${OPTARG}
        ;;
      s)
        SPACE_CHAR='_'
        set_space_char=$((${set_space_char} + 1))
        ;;
      e)
        EXTEND=1
        ;;
      m)
        MOVE=1
        ;;
      n)
        DRY_RUN=1
        ;;
      f)
        FORCE=1
        ;;
      v)
        VERBOSE=1
        ;;
      d)
        DEBUG=1
        ;;
      h)
        print_help
        ;;
      \?)
        echo "Invalid option: -${OPTARG}" >&2
        exit 1
        ;;
      :)
        echo "Option -${OPTARG} requires an argument." >&2
        exit 1
        ;;
    esac
  done
  if [ ${TO_LOWERCASE} -eq 1 -a ${TO_UPPERCASE} -eq 1 ]; then
    echo "'-l' and '-u' can't be used together." >&2
    print_usage 1
  fi
  if [ ${REMOVE_SPECIAL_CHARS} -eq 1 -a ${REPLACE_SPECIAL_CHARS} -eq 1 ]; then
    echo "'-r' and '-x' can't be used together." >&2
    print_usage 1
  fi
  if [ ${set_space_char} -eq 2 ]; then
    echo "'-c' and '-s' can't be used together." >&2
    print_usage 1
  fi
}


### SLUGIFY

function slugify(){
  # echos the slugify version of all args consolidated

  local name="$@"
  local gluechars='-_. '
  local safechars="${gluechars}a-zA-Z0-9"

  if [ -z "${name}" ]; then
    echo "[ERROR] need a string to slugify."
    exit 2
  fi

  if [ ${DEBUG} -eq 1 ]; then
    echo "# SLUG 1: '${name}' (${#name})" >&2
  fi

  ## HANDLE CHARACTERS

  # convert to uppercase
  if [ ${TO_UPPERCASE} -eq 1 ]; then
    name=$(echo "${name}" | tr a-zäöü A-ZÄÖÜ)
  fi

  # convert to lowercase
  if [ ${TO_LOWERCASE} -eq 1 ]; then
    name=$(echo "${name}" | tr A-ZÄÖÜ a-zäöü)
  fi

  # replace special chars
  if [ ${REPLACE_SPECIAL_CHARS} -eq 1 ]; then
    name=$(echo "${name//[^${safechars}]/$REPLACEMENT_CHAR}")
  fi

  # remove special chars
  if [ ${REMOVE_SPECIAL_CHARS} -eq 1 ]; then
    name=$(echo "${name//[^${safechars}]/}")
  fi

  if [ ${DEBUG} -eq 1 ]; then
    echo "# SLUG 2: '${name}' (${#name})" >&2
  fi

  ## HANDLE SPACES

  # remove dashes?
  if [ ${KEEP_DASHES} -eq 0 ]; then
    name=$(echo "${name//-/' '}")
  fi

  # remove underscores?
  if [ ${KEEP_UNDERSCORES} -eq 0 ]; then
    name=$(echo "${name//_/ }")
  fi

  # remove dots?
  if [ ${KEEP_DOTS} -eq 0 ]; then
    name=$(echo "${name//./ }")
  fi

  # consolidate spaces
  if [ ${CONSOLIDATE_SPACES} -eq 1 ]; then
    name=$(echo "${name}" | tr -s '[:space:]')
  fi

  if [ ${DEBUG} -eq 1 ]; then
    echo "# SLUG 3: '${name}' (${#name})" >&2
  fi

  # keep spaces around dashes and underscores?
  if [ ${KEEP_SPACES_AROUND_DASHSCORES} -eq 0 ]; then
    name=$(echo "${name// -/-}")
    name=$(echo "${name//- /-}")
    name=$(echo "${name// _/_}")
    name=$(echo "${name//_ /_}")
  fi

  # trim spaces

  name=$(echo "${name}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # replace space

  name=$(echo "${name// /$SPACE_CHAR}")

  if [ ${DEBUG} -eq 1 ]; then
    echo "# SLUG 4: '${name}' (${#name})" >&2
  fi

  # return slug

  echo "${name}"
}


## MODES

function run(){
  # creates a newname with slugify and tries to rename the file

  ## BUILD NAME

  # get fullname
  local fullname="$@"

  # verbose output (full name)
  if [ ${VERBOSE} -eq 1 ]; then
    echo "- '${fullname}'"
    padding='  '
  else
    padding=''
  fi

  # check if file exists
  if [ ! -f "${fullname}" ]; then
    if [ ${MOVE} -eq 1 ]; then
      echo "${padding}[WARNING] '${fullname}' not found." >&2
      return 1
    fi
  fi

  # get filename
  local path="${fullname%/*}"
  local name="${fullname##*/}"
  local ext="${fullname##*.}"

  # check path
  if [ "${path}" == "${fullname}" ]; then
    path=''
  else
    path="${path}/"
  fi

  # check name
  name="${name%.*}"  # remove extension
  if [ -z "${name}" ]; then
    name=".${ext}"
    ext=''
  fi

  # check extension
  if [ ! -z "${ext}" ]; then
    if [ "${ext}" == "${fullname}" ]; then
      ext=''
    else
      if [ ${IGNORE_EXT} -eq 0 ]; then
        ext="$(slugify "${ext}")"
      fi
      ext=".${ext}"
    fi
  fi

  # verbose output (basename only)
  if [ ${VERBOSE} -eq 1 ]; then
    echo "${padding}'${name}'"
  fi

  ## BUILD NEW NAME

  newname="$(slugify "${name}")"

  # check newname
  if [ -z "${newname}" ]; then
    echo "${padding}[ERROR] '${name}' results in an empty string." >&2
    return 1
  fi

  # verbose output (new name)
  if [ ${VERBOSE} -eq 1 ]; then
    echo "${padding}'${newname}'"
  fi

  # build new fullname
  local newfullname="${path}${newname}${ext}"

  ## DO YOUR THING

  if [ ${MOVE} -eq 1 ]; then

    # RENAME

    if [ "${fullname}" != "${newfullname}" ]; then
      echo "${padding}${fullname} -> ${newfullname}"
      if [ -f "${newfullname}" ]; then
        echo "${padding}[WARNING] '${newfullname}' already exists." >&2
        if [ ${FORCE} -eq 0 ]; then
          return
        fi
      fi
      mv "${fullname}" "${newfullname}"
    fi

  else

    # JUST LIST

    echo "${padding}${newfullname}"

  fi
}


## MAIN

function main(){

  ## PARSE COMMANDLINE

  get_arguments "$@"
  shift $((OPTIND-1))

  # check args
  if [ $# -eq 0 ]; then
    echo "[ERROR] at least one argument is needed. Try '-h' for help." >&2
    echo >&2
    print_usage 1
  fi

  # print verbose stuff
  if [ ${DEBUG} -eq 1 ]; then
    print_options
    echo "#" >&2
    echo "# ARGUMENTS" >&2
    echo "# =========" >&2
    for fn in "$@"; do
      echo "# - '$fn' (${#fn})" >&2
    done
  fi

  ## LOOP OVER ARGS

  # retun one slug for all arguments (consolidated)
  if [ ${EXTEND} -eq 1 ]; then
    newname="$(slugify "$@")"
    echo "${newname}"
    if [ -z "${newname}" ]; then
      exit 3
    fi

  # rename each file given as arg
  else
    for fn in "$@"; do
      run "${fn}"
    done
  fi
}


if [ ${MAIN} -eq 1 ]; then
  main "$@"
fi
