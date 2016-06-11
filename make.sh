tests() {
	for i in $(find ./tests -type f)
	do
	    echo "Performing test: $i"
	    ./lsm.lua "$i"
	done
}

tests