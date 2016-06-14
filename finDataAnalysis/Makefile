# NOTES and COMMENTS:
# - NEVER commit when targets are not up to date
#   ALWAYS run make before committing
# - dependencies should not be in submodule:
# 	 downloading submodule after normal repo will mess up timestamp
# - data output files may be in submodule
# - use make --dry-run to see what would happen

# gnu makefile for cfm

PROJ_DIR := .
PICS_DIR := finDataAnalysis/pics
PRIV_DATA_DIR := ../finDataMatlab/private_data
PUBLIC_DATA_DIR := ../finDataMatlab/public_data
DATA_SRC := data_src
PICS_SRC := src

############################################################
############## SPECIFY MAIN DATA FOR EACH PROCESSING SCRIPT:
############################################################

# SP500_TICKER_SYMBOLS := 

# SP500_RAW_DATA := raw_data/SP500TickerSymbols.csv raw_data/SP500.csv raw_data/SP500IndustryAffil.csv raw_data/index_data.csv
# SP500_PROCESSED_DATA := processed_data/SP500.csv
# GARCH_DATA := public_data/garch_norm_params.csv

# PRIV_DATA_NAMES := $(SP500_RAW_DATA) $(SP500_PROCESSED_DATA)
# PRIV_DATA_FULL_NAMES := $(addprefix $(PRIV_DATA_DIR)/,$(PRIV_DATA_NAMES))

DATA_FULL_NAMES := $(PUBLIC_DATA_DIR)/SP500TickerTable.csv $(PRIV_DATA_DIR)/rawData/sp500Prices.csv $(PRIV_DATA_DIR)/rawData/paramsData_FED.csv $(PRIV_DATA_DIR)/rawData/yieldData_FED.csv

RAW_DATA_FED_NAME := $(PRIV_DATA_DIR)/rawData/feds200628/feds200628.xml

# ################################################
# ############## CREATION OF PDFS
# ################################################

# # get list of all Julia source files for graphics
# PICS_SCRIPTS_NAMES := $(notdir $(wildcard $(PICS_SRC)/*.jl))
# PICS_FILE_NAMES := $(patsubst %.jl,%-1.svg,$(PICS_SCRIPTS_NAMES))
# #RPICS_FILE_NAMES := missing_values-1.svg visualize_volatilities-1.svg market_trend_power-1.svg
# PICS_FULL_NAMES := $(addprefix $(PICS_DIR)/,$(PICS_FILE_NAMES)) 

# PICS_FILE_NAMES_FOR_DELETION := $(patsubst %.jl,%-*.svg,$(PICS_SCRIPTS_NAMES))

# # add possibility to add other pictures also
# ALL_PICS_FULL_NAMES := $(PICS_FULL_NAMES)

# hierarchically highest target:
all: $(DATA_FULL_NAMES) $(ALL_PICS_FULL_NAMES)
.PHONY: all

# # phony target to create all data
# .PHONY: data
# data: $(DATA_FULL_NAMES)

###############################################
############## CREATION OF MAIN_DATA:
###############################################

# get SP500 ticker symbols from Wikipedia
$(PUBLIC_DATA_DIR)/SP500TickerTable.csv: data_src/dwnloadSP500Tickers.m
	matlab -nodesktop -nosplash -nodisplay -r "cd('data_src'); dwnloadSP500Tickers; exit"

# download SP500 data from Yahoo finance
$(PRIV_DATA_DIR)/rawData/sp500Prices.csv: data_src/dwnloadSP500Components.m
	echo "target $@"
	matlab -nodesktop -nosplash -nodisplay -r "cd('data_src'); dwnloadSP500Components; exit"

######### FED data
# NOTE: JAVA heap size needs to be increased!

# process FED data from XML format
$(PRIV_DATA_DIR)/rawData/yieldData_FED.csv: data_src/processFEDyieldData.m $(RAW_DATA_FED_NAME)
	echo "target $@"
	matlab -nodesktop -nosplash -nodisplay -r "cd('data_src'); processFEDyieldData; exit"

# process FED data from XML format
$(PRIV_DATA_DIR)/rawData/paramsData_FED.csv: data_src/processFEDyieldData.m $(RAW_DATA_FED_NAME)
	echo "target $@"
	matlab -nodesktop -nosplash -nodisplay -r "cd('data_src'); processFEDyieldData; exit"


# recipe for graphics
$(addprefix $(PICS_DIR)/,$(PICS_FILE_NAMES)): $(PICS_DIR)/%-1.svg: $(PICS_SRC)/%.jl
	make data
	julia $<

# additional targets:
# TAGS files
# datasets
# executable files
# benchmark results
# unit tests

print-%:
	@echo '$*=$($*)'

# help - The default goal
.PHONY: help
help:
	$(MAKE) --print-data-base --question

.PHONY: nbconvert
nbconvert:
	julia utils/nbconvert.jl

.PHONY: clean
clean:
	rm -f Makefile~

# in case pics-3.svg has been deleted, while pics-1.svg still exists,
# updating rule for figures does not reproduce pics-3.svg
.PHONY: renew_all_julia_pics
renew_all_julia_pics:
	cd pics; rm -v $(PICS_FILE_NAMES_FOR_DELETION); cd ../; make

new:
	make
