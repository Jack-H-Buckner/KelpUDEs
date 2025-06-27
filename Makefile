#######################################################
### Run cross validation tests for the kelp watch UDES
### Jack Buckner, Oregon State University, May 2025
#######################################################
#
#
DIRPATH=~/github/#/home/ceoas/bucknejo/
#
#
MODELNAME=UDE_model
#
#
PROCS=15
#
#
NNINPUTS="[1,2]"
#
#
LINEARINPUTS="[]"
#
#
REGWEIGHT=1e5
#
#
PROCERRORS=0.025
#
#
NODE=kawashiro01
#
#
all:
	@echo ""
	@echo "    This folder is use to run cross validation for "
	@echo ""
	@echo ""
	@echo "    Please type.....   "
	@echo "    		make run_cv MODELNAME=UDE_model NNINPUTS='\"[1,2]\"' LINEARINPUTS= '\"[]\"'' REGWEIGHT=1e5 PROCERRORS=0.025 PROCS=15 NODE=kawashiro01"
#
#
run_cv:
	hqsub -P $(PROCS) "julia --threads=$(PROCS) $(DIRPATH)/KelpUDEs/src/run.jl $(MODELNAME) $(NNINPUTS) $(LINEARINPUTS) $(REGWEIGHT) $(PROCERRORS) $(DIRPATH)" -r solve-$(MODELNAME)--StdOut -q ceoas@$(NODE);\
#
#
clean: 
	rm -r -f *StdOut;

#
#
print_reg:
	@for reg in $(REGLIST); do \
	@echo "$${reg}"
	done; 
