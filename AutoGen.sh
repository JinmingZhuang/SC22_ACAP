input="./input.cfg"

for ((n=1;n<=20;n++));
do
	read -r line
	if (( ${n} == 1 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        platform="${Value[0]}";
	elif (( ${n} == 2 ))
	then
		IFS=':' read -ra Key <<< "$line";
		value_temp="${Key[1]}"; 
		unset IFS
		IFS=';' read -ra Value <<< "$value_temp";
		Ker_Gen="${Value[0]}"; 
	elif (( ${n} == 8 ))
	then
		IFS=':' read -ra Key <<< "$line";
		value_temp="${Key[1]}"; 
		unset IFS
		IFS=';' read -ra Value <<< "$value_temp";
		IO_Gen="${Value[0]}";
	elif (( ${n} == 10 ))
	then
		IFS=':' read -ra Key <<< "$line";
		value_temp="${Key[1]}"; 
		unset IFS
		IFS=';' read -ra Value <<< "$value_temp";
		row_num="${Value[0]}";
	elif (( ${n} == 12 ))
	then
		IFS=':' read -ra Key <<< "$line";
		value_temp="${Key[1]}"; 
		unset IFS
		IFS=';' read -ra Value <<< "$value_temp";
		col_num="${Value[0]}";
	elif (( ${n} == 13 ))
	then
		IFS=':' read -ra Key <<< "$line";
		value_temp="${Key[1]}"; 
		unset IFS
		IFS=';' read -ra Value <<< "$value_temp";
		Sys_Gen="${Value[0]}";
	elif (( ${n} == 14 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        data_type="${Value[0]}"; 
    elif (( ${n} == 15 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        x="${Value[0]}";
    elif (( ${n} == 16 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        y="${Value[0]}";
    elif (( ${n} == 17 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        z="${Value[0]}";
    elif (( ${n} == 18 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        l_buff="${Value[0]}";
    elif (( ${n} == 19 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        r_buff="${Value[0]}";
    elif (( ${n} == 20 ))
    then
        IFS=':' read -ra Key <<< "$line";
        value_temp="${Key[1]}"; 
        unset IFS
        IFS=';' read -ra Value <<< "$value_temp";
        o_buff="${Value[0]}";
    fi
done < "$input"


dir_name="${data_type}_${x}_${y}_${z}_${l_buff}_${r_buff}_${o_buff}_${platform}";
if (( ${Ker_Gen} == 1 ))
then
	cd ./KernelGen;
	./KernelGen.sh;
	cd ..;
	if (( ${IO_Gen} == 1 ))
	then
		if (( ${Sys_Gen} == 0 ))
		then
			cd ./IOGen;
			./IOGen.sh;
			cd ./${data_type}_${row_num}_8_${col_num}_${platform};
			./run_aie.sh;
			cd ..;
		elif (( ${Sys_Gen} == 1 ))
		then
			cd ./IOGen;
			./IOGen.sh;
			cd ./${data_type}_12_8_4_${platform};
			./run_aie.sh;
			cd ../../SysGen;
			./SysGen.sh;
			cd ./${dir_name};
			./run_sys.sh;
			cd ..;
		fi
	else
		cd ../;
	fi
else
	echo "
Parameter:\"KernelGen\" should be 1
	"
fi
