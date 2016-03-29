%% add common utilities to path

addpath(genpath('../../commonUtilities'))

%% Download SP500 stock price data

relDataPath = '../../finDataMatlab/';

% specify start and end point of investigation period
dateBeg = '01011990';
dateEnd = '18032016';

% load ticker symbol table
fname = fullfile(relDataPath, 'public_data/SP500TickerTable.csv');
tickerSymbs = readtable(fname);

% SP500 components
tic
spCompPrices = getPrices(dateBeg, dateEnd, tickerSymbs.Ticker_symbol');
toc

% save to disk
fname = fullfile(relDataPath, 'private_data/rawData/sp500Prices.csv');
writetableTS(spCompPrices, fname)