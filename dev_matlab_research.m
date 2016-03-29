%% dev script. target: get processed data

sp500Prices = readtableTS('./finDataMatlab/private_data/rawData/sp500Prices.csv');

%% find missing values

% find missing entries
isMissing = isnan(sp500Prices{:, :});

% sum up missing entries
missPerAsset = sum(isMissing, 1);

% sort asset with regards to number of missing observations
[~, I] = sort(missPerAsset);

isMissingSorted = isMissing(:, I);

%% visualize

colormap(jet)
imagesc(isMissingSorted', [0, 1])
title('Missing observations')
xlabel('Time')
ylabel('Asset')
xtime(sp500Prices.Properties.RowNames, 4)
grid on

%%

[nObs, nAss] = size(sp500Prices);
nMissAfterBeg = zeros(1, nAss);
for ii=1:nAss
    firstObs = find(~isMissing(:, ii), 1, 'first');
    nMissAfterBeg(1, ii) = sum(isnan(isMissing(firstObs:end, ii)));
end

if ~any(nMissAfterBeg > 0)
    fprintf('No observations are missing after the first observation.\n')
end

%% find offset date for maximum number of observations

nObsAfterDate = zeros(nObs, 1);
for ii=1:nObs
    % find first asset with observation
    firstAss = find(~isMissingSorted(ii, :), 1, 'first');
    
    % count numbers of observations
    nObsAfterDate(ii) = sum(sum(~isMissingSorted(ii:end, firstAss:end)));
end

plot(nObsAfterDate)

%% define subset with 350 assets

% get observations per date
nObsPerDate = sum(~isMissingSorted, 2);

% find first date with more observations than threshold
threshObs = 350;
firstDateInd = find(nObsPerDate >= threshObs, 1, 'first');

% get associated data subset
subsetDates = sp500Prices(firstDateInd:end, :);
missFirstObsInds = isnan(subsetDates{1, :});
sp500SubSet = subsetDates(:, ~missFirstObsInds);

% guarantee no missing prices
assert(sum(sum(isnan(sp500SubSet{:, :}))) == 0)

%% normalize prices

% get new dimensions
[nObsShort, nAssShort] = size(sp500SubSet);

xx = sp500SubSet{:, :};
xxNormed = xx./repmat(xx(1, :), nObsShort, 1);
normedSp500 = embed(xxNormed, sp500SubSet);

%%

% convert strings to numeric dates
serialDates = datenum(normedSp500.Properties.RowNames);

% plot with dates on x axis
semilogy(serialDates, normedSp500{:, :})
datetick 'x'
grid on
grid minor
xlabel('Time')
ylabel('Price')

%% compute statistics

overallRets = (normedSp500{end, :} - normedSp500{1, :})...
    ./normedSp500{1, :};
overallRetsPct = (overallRets - 1)*100;

hist(overallRetsPct)

%% zero returns

discRets = computeReturns(sp500Prices, 'discrete');

isZeroRet = (discRets{:, :} == 0);

plot(numDates(discRets), sum(isZeroRet, 2)/nAss)
datetick 'x'
grid on
grid minor
xlabel('Time')
ylabel('Zero return frequency')

%%

logRets = computeReturns(sp500SubSet, 'logarithmic');

%% visualize log returns

plot(numDates(logRets), logRets{:, 1})
datetick 'x'
grid on; grid minor

%% fit model: univariate unconditional t

[nObs, nAss] = size(sp500SubSet);

% preallocation
nuHat = zeros(nAss, 1);
paramsHat = zeros(nAss, 3);

for ii=1:nAss
    % get de-meaned percentage returns
    fittingData = 100*(logRets{:, ii} - mean(logRets{:, ii}));

    % fit Student's t distribution
    nuHat(ii) = tfit(fittingData);
    
    % fit scaled Student's t distribution
    thisParams = mle(fittingData, 'distribution', 'tlocationscale');
    paramsHat(ii, :) = thisParams;
    
    display(ii)
end

%%

f = figure('pos', [50 50 1200 600]);

subplot(1, 2, 1)
hist(nuHat, 30)
grid on; grid minor;

subplot(1, 2, 2)
hist(paramsHat(:, 3), 30)
grid on; grid minor;

%% fit GARCH(1,1) model

% preallocation
garchParamsHat = zeros(nAss, 4);
sigmaHat = zeros(nObs-1, nAss);

for ii=1:nAss
    % get de-meaned percentage returns
    fittingData = 100*(logRets{:, ii} - mean(logRets{:, ii}));
    
    % fit GARCH
    [thisParams, ~, thisVars] = ...
        tarch(fittingData, 1, 0, 1, 'STUDENTST');

    garchParamsHat(ii, :) = thisParams';
    sigmaHat(:, ii) = sqrt(thisVars);
    
    display(ii)

end


%% plot autoregressive parameter

hist(garchParamsHat(:, 3), 30)
grid on

%% estimate t copula

copNus = zeros(nAss, nAss);
copRhos = zeros(nAss, nAss);

for ii=1:nAss
    for jj=(ii+1):nAss
        thisData = [logRets{:, ii} logRets{:, jj}];
        
        % transform to copula data
        uVals = ranks(thisData);
        
        [rhoHat, nuHat] = copulafit('t', uVals);
        copRhos(ii, jj) = rhoHat(1, 2);
        copRhos(jj, ii) = rhoHat(1, 2);
        copNus(ii, jj) = nuHat;
        copNus(jj, ii) = nuHat;
        display(jj)
    end
    
    display(ii)
end

%%

corrMatr = corr(logRets{:, :});
colormap(jet)
imagesc(corrMatr, [-1 1])

%%

hist(corrMatr(:), 30)


%%

colormap(jet)
imagesc(copRhos, [-1, 1])
title('Asset correlations')
xlabel('Asset')
ylabel('Asset')

%%
xx = copNus(:);
xx = xx(xx<100);
hist(xx, 300)

%% EGARCH

% preallocation
egarchParamsHat = zeros(nAss, 4);
egarchSigmaHat = zeros(nObs-1, nAss);

for ii=1:nAss
    % get de-meaned percentage returns
    fittingData = 100*(logRets{:, ii} - mean(logRets{:, ii}));
    
    % fit EGARCH
    [thisParams, ~, thisVars] = egarch(fittingData, 1, 1 ,1);

    egarchParamsHat(ii, :) = thisParams';
    egarchSigmaHat(:, ii) = sqrt(thisVars);
    
end

%%

figure('pos', [50 50 1200 600])
subplot(1, 2, 1)
plot(egarchSigmaHat)
grid on; axis tight
ylim([0 80])

subplot(1, 2, 2)
plot(sigmaHat)
grid on; axis tight
ylim([0 80])

%%

hist(egarchParamsHat(:, 4), 30)
