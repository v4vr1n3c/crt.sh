#!/bin/bash
#
# SubDOMAIN enumeration by CRT.sh
# Author: Dr. V4vr1n3c - 2019
#


#Variables
DOMAIN="$1"
DIR="$PWD/$1"
TMPFILE="/tmp/$(basename $0).$DOMAIN.$$.tmp"
TMPFILERESULTS="/tmp/$(basename $0).$DOMAIN.results.$$.tmp"
USERAGENT="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_2; en-us) AppleWebKit/525.7 (KHTML, like Gecko) Version/3.1 Safari/525.7"

[ -z "$DOMAIN" ] && echo "usage: $0 <DOMAIN>" && exit 1

echoerr(){ echo "$@" 1>&2; }

#Sanitize the DOMAIN, for a regex grep search
REGEXDOMAIN="${DOMAIN/\./\\.}"

echo -e "[+] Retrieving DOMAIN infomation from crt.sh"
echo -e ""

#Download the crt.sh DOMAIN information
#todo detect if show-progress is supported
wget  -A "*?id*" -I / -L -N -r -l1 -qO "$TMPFILE" -e robots=off -U "$USERAGENT" --no-remove-listing "https://crt.sh/?q=%25$DOMAIN" --show-progress

#Extract altnames
grep -P -o 'DNS:.*?<BR>' "$TMPFILE" | tr -d "DNS:" | tr -d "<BR>" >> $TMPFILERESULTS

#Extract subDOMAINs identified.
grep -o "[a-zA-Z0-9.-]*$REGEXDOMAIN" "$TMPFILE" >> $TMPFILERESULTS


echo -e "[+]##########################################[+]"
echo -e "[+]SUBDOMAINS FOUND[+]"
echo -e "[+][+]"
#Make results lower case, then eliminate duplicates
cat $TMPFILERESULTS | tr A-Z a-z | sort -u | uniq 
echo -e "[+]##########################################[+]"
echo -e "[+][+]"
echo -e " "
echo -e "[+] Making directory $DIR"

#Create directory + DOMAIN.txt
if [ ! -z "$DIR" ]; then 
    mkdir $DIR  
    cd $DIR
    cat $TMPFILERESULTS | sort | uniq   >> DOMAINS.txt 
fi

#Exclude temp file
rm "$TMPFILE"
rm $TMPFILERESULTS 

