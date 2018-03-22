function features = ComputeUnconditionedSingletonFeatures (len, modelParams)
% Creates indicator features on assignments to single variables in the
% sequence.
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

nSingleFeatures = len * modelParams.numHiddenStates;
features(nSingleFeatures) = EmptyFeatureStruct();

K = modelParams.numHiddenStates;
featureIdx = 0;

for st = 1:K
    paramVal = st;
    for v = 1:len
        featureIdx = featureIdx + 1;
        features(featureIdx).var = v;
        %one feature: one assignment
        features(featureIdx).assignment = st; %st, one of states{a:z, 1:26}, 
        features(featureIdx).paramIdx = paramVal;% one assignment, one feature, one parameter.

    end
end

end

% K = modelParams.numHiddenStates;
% features = repmat(EmptyFeatureStruct(),K,len);
% features.var = repmat(1:len,K,1);
% features.assignment = repmat((1:K)',1,len);
% features.paramIdx = repmat((1:K)',1,len);