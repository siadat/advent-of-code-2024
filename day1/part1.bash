cat day1/input | awk '{print $1}' | sort -n > /tmp/sorted1
cat day1/input | awk '{print $2}' | sort -n > /tmp/sorted2

paste /tmp/sorted1 /tmp/sorted2 | while read -r left right; do
	echo "$left - $right" | bc | perl -pe 's/^-//'
done | paste -sd+ | bc
