#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1,mem=4000mb
#PBS -N AraParamScanSetup
#PBS -A PCON0003

#directories
WorkDir=$TMPDIR
tmpAraSim=$HOME/AraSim #AraSim directory
runName='ARAParamSpaceScan' #name of Parameter space scan            
ppn=20 #number of processors per node on cluster

########################### setup.txt file ####################################################   
#explanations of variables in AraSimGuide.pdf
input1="EXPONENT=18"
input2="ONLY_PASSED_EVENTS=1"
input3="NNU=100"
input4="NNU_PASSED=10"
input5="NOISE_EVENTS=16"
input6="NOISE_WAVEFORM_GENERATE_MODE=0"
input7="NOISE=0"
input8="NOISE_TEMP_MODE=0"
input9="NOISE_TEMP=325"
input10="DATA_BIN_SIZE=16384"
input11="INTERACTION_MODE=1"
input12="POSNU_RADIUS=3000"
input13="PICKNEARUNBIASED_R=5000"
input14="PICK_POSNU_DEPTH=0"
input15="MAX_POSNU_DEPTH=0"
input16="NNU_THIS_THETA=0"
input17="NNU_THETA=0"
input18="NNU_D_THETA=0"
input19="SECONDARIES=0"
input20="TAUDECAY=0"
input21="RAYSOL_RANGE=5000"
input22="USE_INSTALLED_TRIGGER_SETTINGS=0"
input23="TRIG_ANALYSIS_MODE=0"
input24="POWERTHRESHOLD=-6.15"
input25="TRIG_WINDOW=1.1E-7"
input26="TRIG_TIMEOUT=1E-6"
input27="TRIG_MODE=1"
input28="N_TRIG=3"
input29="N_TRIG_V=3"
input30="N_TRIG_H=3"
input31="TRIG_SCAN_MODE=0"
input32="TRIG_ONLY_BH_ON=0"
input33="TRIG_THRES_MODE=0"
input34="USE_MANUAL_GAINOFFSET=0"
input35="MANUAL_GAINOFFSET_VALUE=0"
input36="USE_CH_GAINOFFSET=0"
input37="USE_TESTBED_RFCM_ON=0"
input38="RFCM_OFFSET=80"
input39="CONSTANTCRUST=0"
input40="CONSTANTICETHICKNESS=0"
input41="FIXEDELEVATION=0"
input42="MOOREBAY=0"
input43="ATMOSPHERE=1"
input44="ICE_MODEL=0"
input45="NOFZ=1"
input46="GETCHORD_MODE=0"
input47="taumodes=0"
input48="DETECTOR=1"
input49="number_of_stations=1"
input50="station_spacing=2000"
input51="stations_per_side=4"
input52="core_x=10000"
input53="core_y=10000"
input54="number_of_strings_per_station=4"
input55="R_string=10"
input56="BORE_HOLE_ANTENNA_LAYOUT=0"
input57="z_max=200"
input58="BH_ANT_SEP_DIST_ON=0"
input59="z_btw=10"
input60="z_btw01=2"
input61="z_btw12=15"
input62="z_btw23=2"
input63="READGEOM=0"
input64="CALPULSER_ON=0"
input65="CALPUL_AMP=0.15"
input66="DATA_SAVE_MODE=2"
input67="WRITE_ALL_EVENTS=0"
input68="FILL_TREE_MODE=2"
input69="V_MIMIC_MODE=0"
input70="RANDOM_MODE=1"
input71="SIMULATION_MODE=0"
input72="EVENT_TYPE=0"
input73="LPM=1"
input74="NFOUR=1024"
input75="TIMESTEP=5E-10"
#######################################################################################################


#create run directories

cd $TMPDIR
mkdir $runName
cd $runName

for Var1 in {500..1000..250} #varying parameter 1   {Start..End..Interval}                                                      
do
    mkdir Var1Name$Var1
    cd Var1Name$Var1

    for Var2 in {1..3..1} #varying parameter 1                                                                                 
    do
        mkdir Var2Name$Var2
        cd Var2Name$Var2
        
	for Var3 in {500..2900..800} #varying parameter 1                                                                            
	do
            mkdir Var3Name$Var3
            cd Var3Name$Var3
            
	    for Var4 in {60..140..40} #varying parameter 1                                                                                 
	    do
                mkdir Var4Name$Var4
                cd Var4Name$Var4
                
		for Var5 in {0..200..50} #varying parameter 1                                                                                 
		do
                    mkdir Var5Name$Var5
                    cd Var5Name$Var5
                    #####Do file operations###########################################                                                     
 
                    counter=$((counter+1)) 
		    #print variable values for each run
                    echo "Counter = $counter ; Var1Name = $Var1 ; Var2Name = $Var2 ; Var3Name = $Var3 ; Var4Name = $Var4 ; Var5Name = $Var5 "

		    #define changing lines 
		    #Example-> input49="number_of_stations=$Var1"


		    for j in {1..75} #print all setup lines to setup.txt 
		    do
			lineName=input$j
			echo "${!lineName}" >> setup.txt
                    done
                    
		    runDir=$runName'/'Var1Name$Var1'/'Var2Name$Var2'/'Var3Name$Var3'/'Var4Name$Var4'/'Var5Name$Var5

		    #create job file to run jobs
		    echo '#!/bin/bash' >> run_arasim_multithread.sh
                    echo '#PBS -l nodes=1:ppn='$ppn >> run_arasim_multithread.sh
                    echo '#PBS -l walltime=00:10:00' >> run_arasim_multithread.sh #change walltime as necessary                   
                    echo '#PBS -N '$runName'_job_'$counter >> run_arasim_multithread.sh #change job name as necessary          
                    echo '#PBS -j oe'  >> run_arasim_multithread.sh
                    echo '#PBS -A PCON0003' >> run_arasim_multithread.sh #change group if necessary 
		    echo 'cd ' $tmpAraSim >> run_arasim_multithread.sh
		    for (( i=1; i<=$ppn;i++))
                    do
                        echo './AraSim ' $runDir'/setup.txt '$i $runDir' &'  >> run_arasim_multithread.sh
                    done

		    echo 'wait' >> run_arasim_multithread.sh
		    echo 'cd '$runDir >> run_arasim_multithread.sh
		    echo 'hadd Result.root AraOut*' >> run_arasim_multithread.sh
		    echo 'rm AraOut*' >> run_arasim_multithread.sh
		    
		    chmod u+x run_arasim_multithread.sh  #make .sh file executable
                    ##################################################################
                    cd ..
                done
                cd ..
            done
            cd ..
        done
        cd ..
    done
    cd ..
done
cd

mv $WorkDir/$runName $HOME  #move directories to HOME

		    