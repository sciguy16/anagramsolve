#!/bin/bash

awkChunk() {
	# $1 is count
	# $2 is letter
	#echo letter $2 occurs $1 times > /dev/stderr
	LETTER=$2
	NOTLETTER="[^$LETTER]"
	COUNT=$1

	case $COUNT in
		1)
			echo "/^${NOTLETTER}*${LETTER}${NOTLETTER}*\$/"
			;;
		*)
			OUT="${NOTLETTER}*${LETTER}${NOTLETTER}*"
			while [[ $COUNT -gt 1 ]] ; do
				OUT="${OUT}${LETTER}${NOTLETTER}*"
				COUNT=$(($COUNT-1))
			done
			echo "/^${OUT}\$/"
			;;
	esac
}

wordToAwkThing() {
	#echo $WORD > /dev/stderr
	#echo '/a/ && /b/ && /c/ && /x/'
	WORD=$1

	OUT=""
	
	while read LETTERCOUNT ; do
		ACHNK=$(awkChunk $LETTERCOUNT)
		#echo "achnk is $ACHNK" > /dev/stderr
		OUT="$OUT $ACHNK &&"
		#echo "out is $OUT" > /dev/stderr
	done < <(printf $WORD | fold -w1 | sort | uniq -c)
	echo "${OUT} ! /[^$WORD]/"
}

if [[ "$#" -eq 1 ]] ; then
	WORD=$1
else
	WORD=toopta
fi

AWKTHING=$(wordToAwkThing $WORD)
#echo "awkthing is $AWKTHING"
awk "${AWKTHING}" /usr/share/dict/words
