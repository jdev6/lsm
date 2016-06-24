opt=$1
optlist="tests, sublime"
flags=""

[[ "$opt" == "" ]] && read -p "Enter opt ($optlist): " opt && read -p "Additional flags: " flags


sublime() {
	#copy sublime syntax file to sublime syntax files location
	from="misc/lsm.sublime-syntax"
	dest="$HOME/.config/sublime-text-3/Packages/User/"

	mkdir -p $dest && cp $from $dest && echo "succesfully copied $from to $dest"
}

tests() {
	for i in $(find ./tests -type f)
	do
	    echo "   ,,,,,,,,,,,,,,,,,,,,,,,,,,,"
	    echo "Performing test: $i"
	    echo "   ,,,,,,,,,,,,,,,,,,,,,,,,,,,"
	    lsm "$i" $flags
	done
}

$opt