#!/bin/bash

# check the syntax of the passed parameters
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

# if the number of passed parameters is equal to zero
# -> no parameters are passed -> exit the script with error value 1
# check the syntax correctness of the passed parameters 
check(){
if [ "$#" -lt 2 ]
then
        return 1
fi
for var; do check_syntax $var; if test $? -ne 0; then 
        return 1
        fi 
done
}

# loop over the passed parameters and check if they are integers
# in case of false -> bash scipt stops and returns error value 1
# in cae of true -> SUM value is added to the next parameter
sum(){
VAL=0
for var;do
        VAL=$( bc <<< $VAL+$var )
done
echo $VAL
}

# do multiplication for the passed parameters
multi(){
VAL=1
for var;do
        VAL=$( bc -l <<< "$VAL*$var" )
done
echo $VAL
}

# devide the first passed parameter on the followed passed parameters 
# one after one und print the result to the stdout
div(){
VAL=$1
while [ "$#" -gt 1 ]; do shift;
        VAL=$(bc -l <<< "scale=3; $VAL/$1")
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

if test "$val" = "-con"; then concat ${ARR[*]};  

elif [ "$val" = "-h" ] || [ "$val" = "--help" ] && [ ${#ARR[@]} -eq 0 ]; then
        echo "supported parameters are:
-add            calculate the value of adding the passed parameters
-mul            calculate the value of multiplying the passed parameters
-div            divide the first parameter to the rest of parameters
-con            concatenate the passed parameters together
-h or --help    print help command"


elif ! check ${ARR[*]} ; then         
        echo "too few parameters"
        exit 1
else
case "$val" in
-add | -sum)
        sum ${ARR[*]}
        ;;
-mul)
        multi ${ARR[*]}
        ;;
-div)   
        div ${ARR[*]}
        ;;
*)
        echo "invalid parameter is passed"
        exit 1
        ;;
"")     echo "you should pass an option!" 
        exit 1
        ;;
esac
fi
