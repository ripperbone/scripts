#!/bin/bash

usage(){
   THIS_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
   cat <<EOF

      Print addresses to an envelope so you can mail a letter.

      usage: ${THIS_SCRIPT}

      You can also pass the address details from stdin.

      cat FROM.txt TO.txt | ${THIS_SCRIPT}
      cat FROM.txt - | ${THIS_SCRIPT}

EOF
}

if [ $# -gt 0 ]; then
   usage
   exit 1
fi



# Read variables from standard input.

read -rp 'FROM NAME? ' FROM_NAME
read -rp 'FROM ADDRESS LINE 1? ' FROM_ADDRESS_LINE_1
read -rp 'FROM ADDRESS LINE 2? ' FROM_ADDRESS_LINE_2
read -rp 'TO NAME? ' TO_NAME
read -rp 'TO ADDRESS LINE 1? ' TO_ADDRESS_LINE_1
read -rp 'TO ADDRESS LINE 2? ' TO_ADDRESS_LINE_2


# Check variables were read correctly.

echo "FROM NAME: ${FROM_NAME}"
echo "FROM ADDRESS LINE 1: ${FROM_ADDRESS_LINE_1}"
echo "FROM ADDRESS LINE 2: ${FROM_ADDRESS_LINE_2}"
echo "TO NAME: ${TO_NAME}"
echo "TO ADDRESS LINE 1: ${TO_ADDRESS_LINE_1}"
echo "TO ADDRESS LINE 2: ${TO_ADDRESS_LINE_2}"

if [ ! "$(command -v enscript)" ]; then
   echo "Not found: enscript. Check that it's installed and on your PATH."
   exit 1
fi


# Send to printer.
enscript --landscape --font Helvetica@14 --no-header --media Env10 <<EOF
 $FROM_NAME
 $FROM_ADDRESS_LINE_1
 $FROM_ADDRESS_LINE_2




                                                           $TO_NAME
                                                           $TO_ADDRESS_LINE_1
                                                           $TO_ADDRESS_LINE_2

EOF

echo "done."
