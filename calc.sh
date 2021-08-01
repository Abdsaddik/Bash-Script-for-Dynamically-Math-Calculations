#!/bin/bash

# if the number of passed parameters is equal to zero
# -> no parameters are passed -> exit the script with error value 1
empty(){
if [ "$#" -lt 2 ]
then
        echo "too few parameters"
        return 1
fi
}
check_syntax(){
if ! [[ "$1" =~ ^[+-]?[0-9]+?[.]?[0-9]+$ ]]
        then
        echo "only integers and floats are allowed"
        return 1
fi
# in case the user passed the sign + , then remove it to avoid errors by the command bc
if [[ "$var" =~ ^[+][0-9]+$ ]]
        then 
        var=${var#+} 
fi
}

# loop over the passed parameters and check if they are integers
# in case of false -> bash scipt stops and returns error value 1
# in cae of true -> SUM value is added to the next parameter
sum(){
VAL=0
for var;do
        check_syntax $var
        VAL=$( bc <<< $VAL+$var )
done
echo $VAL
}

# do multiplication for the passed parameters
multi(){
VAL=1
for var;do
        check_syntax $var
        # in case the user passed the sign + , then remove it to avoid errors by the command bc
        # if [[ "$var" =~ ^[+][0-9]+$ ]]; then var=${var#+}; fi
        VAL=$( bc -l <<< "$VAL*$var" )
done
echo $VAL
}

# concat the passed parameters together
concat(){
        val="$1"
        while test "$#" -gt 0; do
                shift 1
                val+="$1"
        done
        echo "$val"
}
#################################################################

# save the first passed parameter to the variable val
val=$1
cnt=0
if [ -p /dev/stdin ]; then
        while  IFS= read line ; do
                ARR[cnt]="$line"
                let cnt=cnt+1
                shift
        done

else

# save the passed parameters except the first parameter $1 to the array ARR
        while [ "$#" -gt 0 ]; do
                if [ "$cnt" -gt 0 ]; then
                        ARR[$cnt-1]="$1"
                fi
                let cnt=cnt+1
                shift
        done
fi


case "$val" in
-add | -sum)
        empty ${ARR[*]}
        sum ${ARR[*]}
        exit 0
        ;;
-mul)
        empty ${ARR[*]}
        multi ${ARR[*]}
        exit 0
        ;;
-con)
        concat ${ARR[*]}
        exit 0
        ;;
-h | --help)
        echo "supported parameters are:
-add            calculate the value of adding the passed parameters
-mul            calculate the value of multiplying the passed parameters
-con            concatenate the passed parameters together
-h or --help    print help command"

        exit 0
        ;;
*)
        echo "invalid parameter is passed"; exit 1
        ;;
"")     echo "you should pass an option!"; exit 1
        ;;
esac
