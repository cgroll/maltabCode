%% add common utilities to path

addpath(genpath('../../commonUtilities'))

%% Download SP500 stock price data

relDataPath = '../../finDataMatlab/';
outDir = '../../finDataMatlab/private_data/rawData/feds200628/';

% parse XML file
fname = fullfile(relDataPath, 'private_data/rawData/feds200628/feds200628.xml');
parsedData = parseXML(fname);

%% init resulting table

allDataTable = cell2table(cell(0, 4), 'VariableNames', {'Name', 'Status', 'Value', 'Date'});
allParamsTable = cell2table(cell(0, 4), 'VariableNames', {'Name', 'Status', 'Value', 'Date'});

%% remove empty nodes

xxParams = parsedData.Children(10).Children;
xxInds = arrayfun(@(x)~isempty(x.Children), xxParams);
paramsData = xxParams(xxInds);

%%

% get number of params
nParams= length(paramsData);

for ii=1:nParams
    display(ii)
    
    % get current parameter name
    thisLabel = paramsData(ii).Attributes(5).Value; % make index 4 for short name
    
    % get entries
    xxEntries = paramsData(ii).Children;
    xxInds = arrayfun(@(x)~isempty(x.Attributes), xxEntries);
    thisEntries = xxEntries(xxInds);
    
    thisVarStatus = arrayfun(@(x)x.Attributes(1).Value, thisEntries, 'UniformOutput', false);
    thisVarObs = arrayfun(@(x)x.Attributes(2).Value, thisEntries, 'UniformOutput', false);
    thisVarTime = arrayfun(@(x)x.Attributes(3).Value, thisEntries, 'UniformOutput', false);

    xxTable = cell2table([thisVarStatus' thisVarObs' thisVarTime'],...
        'VariableNames', {'Status', 'Value', 'Date'});
    xxTable.Name = repmat({thisLabel}, size(xxTable, 1), 1);
    
    % attach to overall table
    allParamsTable = [allParamsTable; xxTable];
        
end

%% transform variables to desired types

cleanParamsTable = allParamsTable;

% transform observations to numeric type
cleanParamsTable.Value = cellfun(@(x)str2double(x), cleanParamsTable.Value);

% replace missing observations by NaN
xxInds = strcmp(cleanParamsTable.Status, 'ND');
cleanParamsTable.Value(xxInds) = NaN;

% remove status variable
cleanParamsTable.Status = [];

% transform dates to numeric date format
cleanParamsTable.Date = datenum(cleanParamsTable.Date);

%% unstack and sort

paramsDataTable = unstack(cleanParamsTable, 'Value', 'Name');
paramsDataTable = sortrows(paramsDataTable, 'Date');

%% write to disk

fname = fullfile(outDir, 'paramsData_FED.csv');
writetable(paramsDataTable, fname);

%% remove empty nodes

xxVars = parsedData.Children(8).Children;
xxInds = arrayfun(@(x)~isempty(x.Children), xxVars);
variableData = xxVars(xxInds);

%%

% get number of variables
nVars = length(variableData);

for ii=1:nVars
    display(ii)
    
    % get current variable name
    thisLabel = variableData(ii).Attributes(6).Value;
    
    % get entries
    xxEntries = variableData(ii).Children;
    xxInds = arrayfun(@(x)~isempty(x.Attributes), xxEntries);
    thisEntries = xxEntries(xxInds);
    
    thisVarStatus = arrayfun(@(x)x.Attributes(1).Value, thisEntries, 'UniformOutput', false);
    thisVarObs = arrayfun(@(x)x.Attributes(2).Value, thisEntries, 'UniformOutput', false);
    thisVarTime = arrayfun(@(x)x.Attributes(3).Value, thisEntries, 'UniformOutput', false);

    xxTable = cell2table([thisVarStatus' thisVarObs' thisVarTime'],...
        'VariableNames', {'Status', 'Value', 'Date'});
    xxTable.Name = repmat({thisLabel}, size(xxTable, 1), 1);
    
    % attach to overall table
    allDataTable = [allDataTable; xxTable];
        
end

%% transform variables to desired types

cleanDataTable = allDataTable;

% transform observations to numeric type
cleanDataTable.Value = cellfun(@(x)str2double(x), cleanDataTable.Value);

% replace missing observations by NaN
xxInds = strcmp(cleanDataTable.Status, 'ND');
cleanDataTable.Value(xxInds) = NaN;

% remove status variable
cleanDataTable.Status = [];

% transform dates to numeric date format
cleanDataTable.Date = datenum(cleanDataTable.Date);

%% unstack and sort

yieldData = unstack(cleanDataTable, 'Value', 'Name');
yieldData = sortrows(yieldData, 'Date');

%% write to disk

fname = fullfile(outDir, 'yieldData_FED.csv');
writetable(yieldData, fname);
