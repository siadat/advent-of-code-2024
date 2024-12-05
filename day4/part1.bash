cols="$(cat day4/input | wc -L)"
rows="$(cat day4/input | wc -l)"
(
	# horizontal
	cat day4/input
	# vertical
	seq 1 $cols | while read -r i; do
		cat day4/input | cut -c $i-$i | paste -sd ''
	done
	# diagonals
	rm -f /tmp/diagonal1.*
	rm -f /tmp/diagonal2.*
	cat day4/input | nl | while read -r row line; do
		echo "$line" | grep -o . | nl | while read -r col char; do
			file1line=/tmp/diagonal1.$((col + row - 1))
			file2line=/tmp/diagonal2.$((col - row + 1))
			echo -n "$char" >> $file1line
			echo -n "$char" >> $file2line
		done
	done
	paste -d '\n' /tmp/diagonal1.*
	paste -d '\n' /tmp/diagonal2.*
) \
	| sed -u -r 's#(X|S)#\1\1#g' \
	| grep -o --line-buffered -C20 --color -e XMAS -e SAMX \
	| nl
