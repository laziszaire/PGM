function n = NumParamsForConditionedFeatures (features, numObservedStates)
% Number of parameters "consumed" by a set of conditioned features.
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

maxParam = max([features.paramIdx]);
n = maxParam + numObservedStates - 1 - mod(maxParam - 1, numObservedStates);
%some parameters is not used in feaures, because it is not observed in the dataset
% -1 because if maxparam at the end, mod()=0, so we dont add numObservedStates
% left to n = numObservedStates - 1 - mod(maxParam - 1,numObservedStates)
end
