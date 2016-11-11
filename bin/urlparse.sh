#!/bin/bash

#
# URI parsing function
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@]host[:port][/path][?[arg1=val1]...][#fragment]
#
function uri_parser() {
    # uri capture
    uri="$@"

    # safe escaping
    uri="${uri//\`/%60}"
    uri="${uri//\"/%22}"

    # top level parsing
    pattern='^(([a-z]{3,16})://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]+)(:([0-9]+))?)(\/[^?]*)?(\?[^#]*)?(#.*)?$'
    [[ "$uri" =~ $pattern ]] || return 1;

    # component extraction
    uri=${BASH_REMATCH[0]}
    uri_schema=${BASH_REMATCH[2]}
    uri_address=${BASH_REMATCH[3]}
    uri_user=${BASH_REMATCH[5]}
    uri_password=${BASH_REMATCH[7]}
    uri_host=${BASH_REMATCH[8]}
    uri_port=${BASH_REMATCH[10]}
    uri_path=${BASH_REMATCH[11]}
    uri_query=${BASH_REMATCH[12]}
    uri_fragment=${BASH_REMATCH[13]}

    # path parsing
    count=0
    path="$uri_path"
    pattern='^/+([^/]+)'
    while [[ $path =~ $pattern ]]; do
        eval "uri_parts[$count]=\"${BASH_REMATCH[1]}\""
        path="${path:${#BASH_REMATCH[0]}}"
        let count++
    done

    # query parsing
    count=0
    query="$uri_query"
    pattern='^[?&]+([^= ]+)(=([^&]*))?'
    while [[ $query =~ $pattern ]]; do
        eval "uri_args[$count]=\"${BASH_REMATCH[1]}\""
        eval "uri_arg_${BASH_REMATCH[1]}=\"${BASH_REMATCH[3]}\""
        query="${query:${#BASH_REMATCH[0]}}"
        let count++
    done

    # return success
    return 0
}


uri=$1

# perform parsing and handle failure
uri_parser "$uri" || { exit 1; }

if [ -n "$2" ]; then
  echo $2
else
  #  echo "uri               = $uri"
  echo "uri_schema        = $uri_schema"
  #echo "uri_address       = $uri_address"
  echo "uri_user          = $uri_user"
  echo "uri_password      = $uri_password"
  echo "uri_host          = $uri_host"
  echo "uri_port          = $uri_port"
  echo "uri_path          = $uri_path"
  echo "uri_query         = $uri_query"
  echo "uri_fragment      = $uri_fragment"

  # path segments
  #echo "uri_parts[0]      = ${uri_parts[0]}"
  #echo "uri_parts[1]      = ${uri_parts[1]}"
  #echo "uri_parts[2]      = ${uri_parts[2]}"
  # query arguments
  #echo "uri_args[0]       = ${uri_args[0]}"
  #echo "uri_args[1]       = ${uri_args[1]}"
  #echo "uri_args[2]       = ${uri_args[2]}"
  # query arguments values
  #echo "uri_arg_param     = $uri_arg_param"
  #echo "uri_arg_array[0]  = ${uri_arg_array[0]}"
  #echo "uri_arg_param2    = $uri_arg_param2"
fi
