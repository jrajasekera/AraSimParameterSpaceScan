#!/bin/bash            

tmpAraSim=$HOME/AraSim #location of AraSim
runName=ARAParamSpaceScan #name of parameter space scan

cd $tmpAraSim

if [ ! -f ./jobList.txt ]; then #see if there is an existing job file                                                                        
 
    echo "Creating new job List"
    for Var1 in {500..1000..250} # varying parameter 1      {Start..End..Interval}                                                          
    do
	for Var2 in {1..3..1} #Antenna radius from station                                                                                    
	do
	    for Var3 in {500..2900..800} 
            do
		for Var4 in {60..140..40} 
		do
		    for Var5 in {0..200..50} 
                    do
			echo "cd $runName/Var1Name$Var1/Var2Name$Var2/Var3Name$Var3/Var4Name$Var4/Var5Name$Var5" >> jobList.txt
		    done
		done
	    done
	done
    done
else
    echo "Picking up from last job"
fi

numbLeft=$(wc -l < ./jobList.txt)
while [ $numbLeft -gt 0 ];
do
    jobs=$(showq -w user=cond0091 | grep "cond0091") #change username here                  

    echo '__________Current Running Jobs__________'
    echo "$jobs"
    echo ''
    runningJobs=$(showq -w user=cond0091 | grep "cond0091" | wc -l) #change unsername here 

    echo Number of Running Jobs = $runningJobs
    echo Number of jobs left = $numbLeft
    if [ $runningJobs -le 10 ];then
        line=$(head -n 1 jobList.txt)
        $line
        echo Submit Job && pwd
        qsub run_arasim_multithread.sh
        cd $tmpAraSim
        sed -i 1d jobList.txt
    else
        echo "Full Capacity"
    fi
    sleep 1
    numbLeft=$(wc -l < ./jobList.txt)
done
