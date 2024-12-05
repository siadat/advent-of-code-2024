root=/dev/shm/day5
rm -rf $root

# Read the rules
cat day5/input | grep --fixed-strings '|' | while IFS='|' read -r prev next; do
	mkdir -p $root/forward/{$next,$prev}
	touch $root/forward/{$next,$prev}/direct
	echo "$next" >> $root/forward/$prev/direct
done

# Check the sequences
mkdir -p $root/full_nexts
cat day5/input | grep , | nl | while read -r idx sequence; do
	dir=$root/sequence$idx
	while read -r page; do
		dir=$dir/$page
		mkdir -p $dir
		ln -s $root/forward/$page $dir/nexts
	done < <(echo "$sequence" | grep -Po '\d+')

	dir=$root/sequence$idx
	while read -r page; do
		dir=$dir/$page
		if grep -q -w $page -R $dir; then
			echo "Bad: $idx $sequence" > /dev/stderr
			continue 2
		fi
	done < <(echo "$sequence" | grep -Po '\d+')

	echo "Good: $idx $sequence" > /dev/stderr
	length="$(echo "$sequence" | grep -Po '\d+' | wc -l)"
	middle_idx=$"$(( (length+1) / 2))"
	echo "$sequence" | grep -Po '\d+' | sed -n "$middle_idx"p
done | paste -sd+ | bc
