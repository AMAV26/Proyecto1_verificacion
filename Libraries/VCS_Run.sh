#!/bin/bash
source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh;
rm -rfv `ls | grep -v ".*\.sv\|.*\.sh"`;
vcs -Mupdate test_tb.sv -o salida -full66 -debug_acc+all -debug_region+cell+encrypt -sverilog -l log_test  +lint=TFIPC-L -kdb -cm line+tgl+cond+fsm+branch+assert +ntb_random_seed=312131233;
./salida  
##cp FifoFlops.sv FifoFlops_tb.sv Quiz1

