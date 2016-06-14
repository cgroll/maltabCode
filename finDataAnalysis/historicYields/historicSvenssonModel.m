% analysis estimated historic Svensson parameters, 1961 to present

addpath(genpath('../../commonUtilities'))
dataDir = '../../finDataMatlab';

%% load historic estimated parameters

fname = fullfile(dataDir, 'private_data/rawData/feds200628/paramsData_FED.csv');
paramsTable = readtable(fname);

%% define maturities of interest

maturs = [0.1 1:30];

%% evaluate model for given maturities and given day

% select parameters for some given day
dayDate = '2006-05-09';
xxInd = find(paramsTable.Date == datenum(dayDate));

thisParams = paramsTable{xxInd, 2:end};
thisDate = paramsTable.Date(xxInd);

% get yields / foward rates
[yields, fowRates] = svenssonYields(thisParams, maturs');

%% plot rates

plot(maturs, [fowRates' yields'])
title(['Date: ' datestr(thisDate)])
grid on;
grid minor;
legend('forward rates', 'yields', 'Location', 'Southoutside')

%% get all historic yields

% get yields / foward rates
[yields, fowRates] = svenssonYields(paramsTable{:, 2:end}, maturs');

%% plot yields over time

% do not plot each day
freq = 5;

% make grid matrices
maturGrid = repmat(maturs, size(paramsTable, 1), 1);
timeGrid = repmat(paramsTable.Date, 1, length(maturs));

mesh(timeGrid(1:freq:end,:), maturGrid(1:freq:end,:), yields(1:freq:end,:))
datetick 'x'

%% plot forward rates over time

mesh(timeGrid(1:freq:end, :), maturGrid(1:freq:end,:), fowRates(1:freq:end,:))
datetick 'x'
