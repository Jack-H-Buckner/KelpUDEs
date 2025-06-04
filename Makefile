#######################################################
### Run cross validation tests for the kelp watch UDES
### Jack Buckner, Oregon State University, May 2025
#######################################################
#
#
DIRPATH=~/github/#/home/ceoas/bucknejo/
#
#
all:
	@echo ""
	@echo "    This folder is use to run cross validation for"
	@echo ""
	@echo ""
	@echo "    Please type.....   "
	@echo "    		make model "
#
#
run_cv:
	@for training in $(TRAININGLIST); do \
	hqsub -P $(PROCS) "julia --threads=$(PROCS) $(DIRPATH)StateSpaceUDEs/Jornada_Range/src/cross_validation.jl $(MODEL) $${training}  $(DATASET) $(REG) $(DIRPATH)" -r solve-$(MODEL)-$${training}-StdOut -q ceoas@$(NODE);\
	done; 
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
