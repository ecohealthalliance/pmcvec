#/usr/bin/env bash

# source dir of the files
URL='ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_bulk/'
OUTFILE=${1:-pmc_oabulk_tokenized.txt}
# get the filenmaes in the dir that end with .txt.tar.gz
textfiles=$(curl -s $URL | grep -oP '(?<=\s)[^\s]+\.txt\.tar\.gz$')

rm -f -- $OUTFILE
touch $OUTFILE
# Loop over each file, downloading and processing in a pipe
for textfile in $textfiles
do
  echo "$URL$textfile"
  curl -sL $URL$textfile |  # download the file
    pv -N Download -c |
    tar -xz --wildcards '*.txt' --to-command="paste -s -d ' '" |  # uncompress
    grep -oP '(?<===== Body).*(?===== Refs)' | # get the body
    sed -e "s/[^[:alnum:][:space:]']\+/ /g"     |  # remove punctuation except apostrophes
    tr "\t" " "                 | # replace tabs with spaces
    tr -s " "                    |  # remove extra spaces
    tr "[:upper:]" "[:lower:]" >> $OUTFILE  # change to lowercase
done