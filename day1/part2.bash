cat day1/input | col1 > /tmp/col1
cat day1/input | col2 > /tmp/col2

cat /tmp/col1 | while read -r line; do
	freq="$(cat /tmp/col2 | grep -w "$line" | uniq -c | col1)"
	if [ -z "$freq" ]; then
		continue
	fi
	echo "$line * $freq" | bc
done | paste -sd+ | bc
