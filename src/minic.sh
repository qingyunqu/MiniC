#!/bin/bash
eeyoreFile="./MiniC_to_Eeyore/eeyore"
optimizeFile="./optimization/optimize"
tiggerFile="./Eeyore_to_Tigger/tigger"
riscv32File="./Tigger_to_RISCV32/riscv32"

optimize_flag=0
minic_file=""
output_file=""

if [ ! -f "$eeyoreFile" ]; then
	cd ./MiniC_to_Eeyore/
	make
	cd ..
fi
if [ ! -f "$optimizeFile" ]; then
	cd ./optimization/
	make
	cd ..
fi
if [ ! -f "$tiggerFile" ]; then
	cd ./Eeyore_to_Tigger/
	make
	cd ..
fi
if [ ! -f "$riscv32File" ]; then
	cd ./Tigger_to_RISCV32/
	make
	cd ..
fi

while getopts "c:Oo:h" arg
do
	case $arg in
		h)
			echo "Using ./minic.sh -c [file] -o [output] [-O](for optimize)"
			exit
			;;
		c)
			minic_file=$OPTARG
			;;
		O)
			optimize_flag=1
			;;
		o)
			output_file=$OPTARG
			;;
		?)
			exit
			;;
	esac
done

if [ $optimize_flag == 0 ]; then
	$eeyoreFile < $minic_file > ./tmp.e
	$tiggerFile < ./tmp.e > ./tmp.t
	$riscv32File < ./tmp.t > $output_file
	rm ./tmp.e
	rm ./tmp.t
	exit
else
	$eeyoreFile < $minic_file > ./tmp.e
	$optimizeFile < ./tmp.e > ./tmp.oe
	$tiggerFile < ./tmp.oe > ./tmp.t
	$riscv32File < ./tmp.t > $output_file
	rm ./tmp.e
	rm ./tmp.oe
	rm ./tmp.t
	exit
fi
			
