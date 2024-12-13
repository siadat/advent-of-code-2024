cat day7/input | while IFS=: read res line; do
	num_count=$(echo $line | wc -w)
	open_parens="($(yes '(' | head -n $num_count | paste -sd '')"
	nums="$(echo $line | sed -e 's/ /\{+,\\*\}/g')"
	permutations="$(eval "echo '$open_parens'$nums==$res" | sed 's/ / \|\| /g')"
	echo "$permutations" | while read eq; do
		echo "(($eq)*$res"
	done | sed -r -e "s/[0-9]+/\0\)/g" | tee /dev/stderr | bc
done | tee /dev/stderr | paste -sd+ | bc
