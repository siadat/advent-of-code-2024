rm -f /tmp/day4.x-mas.*
cat day4/input | nl | while read -r row line; do
	echo "$line" | grep -o . | nl | while read -r col char; do
		case "$char" in
			A)
				# each A may be crossed by 2 diagonals
				echo -n "$char" >> /tmp/day4.x-mas.A.$col.$row.diagonal1
				echo -n "$char" >> /tmp/day4.x-mas.A.$col.$row.diagonal2
				;;
			M|S)
				# each M or S may be part of 4 crosses
				echo -n "$char" >> /tmp/day4.x-mas.A.$((col-1)).$((row-1)).diagonal1
				echo -n "$char" >> /tmp/day4.x-mas.A.$((col+1)).$((row+1)).diagonal1
				echo -n "$char" >> /tmp/day4.x-mas.A.$((col-1)).$((row+1)).diagonal2
				echo -n "$char" >> /tmp/day4.x-mas.A.$((col+1)).$((row-1)).diagonal2
				;;
		esac
	done
done
#  Filter A locations where both diagonal1 and diagonal2 contain MAS or SAM
grep -e MAS -e SAM -l /tmp/day4.x-mas.A.* \
	| sed -r 's/.diagonal.$//' \
	| sort \
	| uniq -c \
	| awk '$1 == 2' \
	| nl
