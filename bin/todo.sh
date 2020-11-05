#!/usr/bin/env bash

# export TODO_DIR=$(dirname "$0")
TODO_DIR=${HOME}/Documents
TODO_FILE="$TODO_DIR/todo.txt"
DONE_FILE="$TODO_DIR/done.txt"

AUTO_LIST=true

color_red=$(tput bold;tput setaf 1)            # bright red text
color_green=$(tput setaf 2)                    # dim green text
color_yellow=$(tput bold;tput setaf 3)         # bright yellow text
color_fawn=$(tput setaf 3) ; color_beige=$fcolor_awn       # dark yellow text
color_blue=$(tput bold;tput setaf 4)           # bright blue text
color_purple=$(tput setaf 5) ; color_magenta=$color_purple # magenta text
color_pink=$(tput bold;tput setaf 5)           # bright magenta text
color_cyan=$(tput bold;tput setaf 6)           # bright cyan text
color_gray=$(tput setaf 8)                     # dim white text
color_white=$(tput bold;tput setaf 7)          # bright white text
color_normal=$(tput sgr0)                      # normal text

color_A=$color_yellow
color_B=$color_green
color_C=$color_blue
color_context=$color_red
color_project=$color_red
color_done=$color_gray

die() {
    echo "$*"
    exit 1
}

cleaninput() {
    # Replace CR and LF with space; tasks always comprise a single line.
    input=${input//$'\r'/ }
    input=${input//$'\n'/ }

    if [ "$1" = "for sed" ]; then
      # This action uses sed with "|" as the substitution separator, and & as
      # the matched string; these must be escaped.
      # Backslashes must be escaped, too, and before the other stuff.
      input=${input//\\/\\\\}
      input=${input//|/\\|}
      input=${input//&/\\&}
    fi
}

_add() {
  input="$1"
  cleaninput
  uppercasePriority
  # input=$(echo "$input" | sed -e 's/^\(([A-Z]) \)\{0,1\}/\1'"$(date '+%Y-%m-%d') /")
  echo "$input" >> "$TODO_FILE"
}

_pri() {
  item=$1
  getTodo $item

  newpri=$( echo "$2" | tr '[:lower:]' '[:upper:]' )
  [ "$#" -ne 3 ] && newpri="A"
  oldpri=
  [[ "$todo" = \(?\)\ * ]] && oldpri=${todo:1:1}
  [ "$oldpri" != "$newpri" ] && sed -i.bak -e "${item}s/^(.) //" -e "${item}s/^/($newpri) /" "$TODO_FILE"

  [ "$oldpri" = "$newpri" ] && echo "TODO: $item already prioritized ($newpri)."
}

_remove() {
  item=$1
  getTodo $item
  sed -i.bak -e "${item}s/^.*//" "$TODO_FILE"
}

_done() {
    getTodo $1

    # Check if this item has already been done
    if [ "${todo:0:2}" != "x " ]; then
      now=$(date '+%Y-%m-%d')
      # remove priority once item is done
      sed -i.bak "${item}s/^(.) //" "$TODO_FILE"
      sed -i.bak "${item}s|^|x $now |" "$TODO_FILE"
    else
      echo "TODO: $item is already marked done."
    fi
}

_undone() {
    getTodo $1
    if [ "${todo:0:2}" == "x " ]; then
      sed -i.bak "${item}s|^x [1-9][0-9]\{3\}-[0-9]\{1,2\}-[0-9]\{1,2\} ||" "$TODO_FILE"
      sed -i.bak "${item}s|^x ||" "$TODO_FILE"
    fi
}

getTodo() {
  local item=$1
  todo=$(sed "$item!d" "${TODO_FILE}")
  [ -z "$todo" ] && die "$TODO_FILE: No task $item."
}

getPadding() {
    ## We need one level of padding for each power of 10 $LINES uses.
    LINES=$(sed -n '$ =' "${TODO_FILE}")
    printf %s ${#LINES}
}

_colorize() {
  items=$(echo "$items" | sed -e " \
  s/^\([0-9]\{0,2\} *\)\(x.*\)/\1$color_done\2$color_normal/; \

  ")

  #  s/\(\+[[:alnum:]\_\.\-\/]*\)/$red\1$normal/; \
  # s/\(\@[[:alnum:]\_\.\-\/]*\)/$green\1$normal/; \
}

uppercasePriority() {
    lower=( {a..z} )
    upper=( {A..Z} )
    for ((i=0; i<26; i++)) ; do
        upperPriority="${upperPriority};s/^[(]${lower[i]}[)]/(${upper[i]})/"
    done
    input=$(echo "$input" | sed "$upperPriority")
}

filtercommand() {
    filter=${1:-}
    shift
    post_filter=${1:-}
    shift

    for search_term ; do
        ## See if the first character of $search_term is a dash
        if [ "${search_term:0:1}" != '-' ]; then
            # hide lines that don't match $search_term
            filter="${filter:-}${filter:+ | }grep -i "$search_term""
        else
            # hide lines that match $search_term
            # Remove the first character (-) before adding to our filter command
            filter="${filter:-}${filter:+ | }grep -v -i "${search_term:1}""
        fi
    done

    [ -n "$post_filter" ] && {
        filter="${filter:-}${filter:+ | }${post_filter:-}"
    }
    printf %s "$filter"
}

auto_list() {
  [ "$AUTO_LIST" = true ] && _list
}

_list() {
  PADDING=$(getPadding)
  items=$(sed = $TODO_FILE | \
    sed -e "s/^\(([A-Z]) \)\{0,1\} *[1-9][0-9]\{3\}-[0-9]\{1,2\}-[0-9]\{1,2\} /\1 /;s/ \{2,\}//" | \
    sed -e '''
            N
            s/^/     /
            s/ *\([ 0-9]\{'"$PADDING"',\}\)\n/\1 /
            /^[ 0-9]\{1,\} *$/d
         ''')

  filter_command=$(filtercommand '' '' "$@")
  [ "${filter_command}" ] && items=$(echo -n "$items" | eval "${filter_command}")

  items=$(echo -n "$items" \
    | sed '''
        s/^     /00000/;
        s/^    /0000/;
        s/^   /000/;
        s/^  /00/;
        s/^ /0/;
      ''' \
    | env LC_COLLATE=C sort -f -k2
      )

  _colorize
  echo "$items"
}

action=${1:-"ls"}
case $action in

"add" | "a")
    shift; input=$*
    _add "$input"
    auto_list
    ;;
"adda")
    shift; input=$*
    _add "$input"
    line=$(sed -n '$ =' "$TODO_FILE")
    _pri $line "A"
    auto_list
    ;;
"addx")
    shift; input=$*
    _add "$input"
    line=$(sed -n '$ =' "$TODO_FILE")
    _done $line
    auto_list
    ;;
"addm")
    if [[ -z "$2" ]]; then
        echo -n "Add: "
        read -e -r input
    else
        shift; input=$*
    fi

    # Set Internal Field Seperator as newline so we can loop across multiple lines
    SAVEIFS=$IFS
    IFS=$'\n'

    for line in $input ; do
        _add "$line"
    done
    IFS=$SAVEIFS
    ;;

"list" | "ls" )
    shift  ## Was ls; new $1 is first search term
    _list "$@"
    ;;
"do" | "done" )
    shift
    [ "$#" -eq 0 ] && die "usage: todo do ITEM#[, ITEM#, ITEM#, ...]"
    # Split multiple do's, if comma separated change to whitespace separated
    for item in ${*//,/ }; do
      _done $item
    done
    auto_list
    ;;
"undo" | "undone" )
    shift
    [ "$#" -eq 0 ] && die "usage: todo undo ITEM#[, ITEM#, ITEM#, ...]"
    # Split multiple do's, if comma separated change to whitespace separated
    for item in ${*//,/ }; do
      _undone $item
    done
    auto_list
    ;;
"append" | "app" )
    shift; item=$1; shift
    getTodo "$item"
    input=$*
    cleaninput "for sed"

    if sed -i.bak "${item} s|^.*|& ${input}|" "$TODO_FILE"; then
      auto_list
    else
        die "TODO: Error appending task $item."
    fi
    ;;
"del" | "rm" )
    _remove "$2"
    auto_list
    ;;
"archive" )
    sed -i.bak -e '/./!d' "$TODO_FILE" # defragment blank lines
    grep "^x " "$TODO_FILE" >> "$DONE_FILE"
    sed -i.bak '/^x /d' "$TODO_FILE"
    auto_list
    ;;
"pri" | "p" )
    shift
    _pri "$1" "$2"
    ;;
"depri" | "dp" )
    shift;
    [ $# -eq 0 ] && die "todo depri ITEM#[, ITEM#, ITEM#, ...]"

    # Split multiple depri's, if comma separated change to whitespace separated
    # Loop the 'depri' function for each item
    for item in ${*//,/ }; do
        getTodo "$item"
	[[ "$todo" = \(?\)\ * ]] && sed -i.bak -e "${item}s/^(.) //" "$TODO_FILE"
    done
    ;;
"cat" )
    cat $TODO_FILE;;
"edit" )
    cmd=${EDITOR:-vi}
    shift
    [[ "$1" =~ ^[0-9]+$ ]] && cmd="$cmd +$1"
    $cmd "$TODO_FILE"
    ;;
* )
    input=$*
    if [[ $# -ne 1 ]]; then _add "$input"; auto_list; else _list "$input"; fi
    ;;
esac
