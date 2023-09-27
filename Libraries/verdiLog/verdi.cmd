simSetSimulator "-vcssv" -exec "./salida" -args " " -uvmDebug on
debImport "-i" "-simflow" "-dbdir" "./salida.daidir"
srcTBInvokeSim
srcTBRunSim
srcTBSimQuit
debExit
