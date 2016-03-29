%% add common utilities to path

addpath(genpath('../../commonUtilities'))

%% download ticker symbols

getSP500TickerTable('../../finDataMatlab/public_data/SP500TickerTable.csv')