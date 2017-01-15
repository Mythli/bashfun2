aliasDir () {
	folder=$1
	prefix=$2
	
	for f in $(find $1 -name '*.sh');
	do
		file=$(basename $f)
		name=$(echo $file | cut -f 1 -d '.')
		if [ -z "$prefix" ]
		then
			cName=$name
		else
			cName=$prefix$name
		fi

		echo $cName
		alias $cName="$f"
	done
}
