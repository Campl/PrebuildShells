#!/bin/bash
#parameter  contentFormat inputFileName outputFileName
function deduplication()
{
	IFS="\t"
	contentArray=()

	if [ $# -ne 3 ]
	then
		echo "PARAMETER NUM ERROR"
	fi
	
	if [ "$2" = "$3" ]
	then 
		echo "You are COVERING the source file,are you sure?(Y/N)"
		read cover
		case "$cover" in
			[Yy])
				lineNum=1
				DONE="false"
				until [ "$DONE" = "true" ]
				do read line || DONE="true"
					if [[ $line =~ $1 ]]
					then
						echo "$line"
						lineNoSpace=`echo "$line"|sed 's/ //g'`
						if [[ ${contentArray[@]} =~ $lineNoSpace ]]
						then								
							sed -i "${lineNum},${lineNum}d" "$2"
							echo "deleted"
						else
							contentArray=(${contentArray[@]} $lineNoSpace)
							lineNum=$[$lineNum+1]
							echo $lineNum
						fi
					else
						lineNum=$[$lineNum+1]
					fi
				done<"$2"
				return
				;;
			[Nn])
				return
				;;
			*)
				return
				;;
		esac
		

	fi

	#clean the output file
	echo -n "">"$3"
	DONE="false"
	until [ "$DONE" = "true" ]
	do read line || DONE="true"
		if [[ $line =~ $1 ]]
		then
			lineNoSpace=`echo "$line"|sed 's/ //g'`
			if [[ ${contentArray[@]} =~ $lineNoSpace ]]
			then
				continue
			else
				contentArray=(${contentArray[@]} $lineNoSpace)
				if [ "$DONE" = "true" ]
				then
					echo -n "$line">>"$3"
				else
					echo "$line">>"$3"
				fi
			fi
		else
			if [ "$DONE" = "true" ]
			then 
				echo -n "$line">>"$3"
			else 
				echo "$line">>"$3"
			fi
		fi
	done < "$2"
}
deduplication "<uses-permission.*/>" "AndroidManifest.xml" "output.xml"
echo "done"
read a
