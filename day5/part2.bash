root=/dev/shm/day5
rm -rf $root

# Read the rules
cat day5/input | grep --fixed-strings '|' | while IFS='|' read -r prev next; do
	mkdir -p $root/forward/{$next,$prev}
	touch $root/forward/{$next,$prev}/direct
	echo "$next" >> $root/forward/$prev/direct
done

# Check and correct the sequences
cat day5/input | grep , | nl | while read -r seqIdx sequence; do
	is_corrected=
	while true; do
		dir=$root/sequence$seqIdx
		echo "Checking sequence$seqIdx $sequence..." > /dev/stderr
		rm -rf $root/sequence$seqIdx
		while read -r pageIdx page; do
			dir=$dir/$page
			mkdir -p $dir
			ln -s $root/forward/$page $dir/nexts
			echo $pageIdx > $dir/pageIdx
		done < <(echo "$sequence" | grep -Po '\d+' | nl)

		dir=$root/sequence$seqIdx
		while read -r pageIdx page; do
			dir=$dir/$page
			matches="$(grep -w $page -R $dir --exclude="pageIdx" -l)"
			while read -r match; do
				if [ -z "$match" ]; then continue; fi
				badIdx=$(cat $(dirname $(dirname $match))/pageIdx)
				IFS=',' read -r -a sequence_array <<< "$sequence"
				tmp=${sequence_array[$((pageIdx-1))]}
				sequence_array[$((pageIdx-1))]=${sequence_array[$((badIdx-1))]}
				sequence_array[$((badIdx-1))]=$tmp
				sequence=$(IFS=,; echo "${sequence_array[*]}")
				is_corrected=true
				continue 3
			done < <(echo "$matches" | tail -1)
		done < <(echo "$sequence" | grep -Po '\d+' | nl)
		break
	done

	if [ -z "$is_corrected" ]; then
		continue
	fi
	echo "Good: sequence$seqIdx $sequence" > /dev/stderr
	length="$(echo "$sequence" | grep -Po '\d+' | wc -l)"
	middle_idx=$"$(( (length+1) / 2))"
	echo "$sequence" | grep -Po '\d+' | sed -n "$middle_idx"p
done | paste -sd+ | bc
