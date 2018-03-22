% function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y).
%
% Inputs:
% X            Data.                           (numCharacters x numImageFeatures matrix)
%              X(:,1) is all ones, i.e., it encodes the intercept/bias term.
% y            Data labels.                    (numCharacters x 1 vector)
% theta        CRF weights/parameters.         (numParams x 1 vector)
%              These are shared among the various singleton / pairwise features.
% modelParams  Struct with three fields:
%   .numHiddenStates     in our case, set to 26 (26 possible characters)
%   .numObservedStates   in our case, set to 2  (each pixel is either on or off)
%   .lambda              the regularization parameter lambda
%
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)

% featureSet is a struct with two fields:
%    .numParams - the number of parameters in the CRF (this is not numImageFeatures
%                 nor numFeatures, because of parameter sharing)
%    .features  - an array comprising the features in the CRF.
%
% Each feature is a binary indicator variable, represented by a struct
% with three fields:
%    .var          - a vector containing the variables in the scope of this feature
%    .assignment   - the assignment that this indicator variable corresponds to
%    .paramIdx     - the index in theta that this feature corresponds to
%
% For example, if we have:
%
%   feature = struct('var', [2 3], 'assignment', [5 6], 'paramIdx', 8);
%
% then feature is an indicator function over X_2 and X_3, which takes on a value of 1
% if X_2 = 5 and X_3 = 6 (which would be 'e' and 'f'), and 0 otherwise.
% Its contribution to the log-likelihood would be theta(8) if it's 1, and 0 otherwise.
%
% If you're interested in the implementation details of CRFs,
% feel free to read through GenerateAllFeatures.m and the functions it calls!
% For the purposes of this assignment, though, you don't
% have to understand how this code works. (It's complicated.)

featureSet = GenerateAllFeatures(X, modelParams);
% X is not variable

% Use the featureSet to calculate nll and grad.
% This is the main part of the assignment, and it is very tricky - be careful!
% You might want to code up your own numerical gradient checker to make sure
% your answers are correct.
%
% Hint: you can use CliqueTreeCalibrate to calculate logZ effectively.
%       We have halfway-modified CliqueTreeCalibrate; complete our implementation
%       if you want to use it to compute logZ.

nll = 0;
grad = zeros(size(theta));

%%%
% Your code here:
% build clique tree
features = featureSet.features;
factors = features2factors(features,modelParams,theta);
CliqueTree = CreateCliqueTree(factors); % F is array of factors, it is only to be a chain.
[CliqueTree, logZ] = CliqueTreeCalibrate(CliqueTree,0);

%nll
[features_val,theta_] = weighted_feature_counts(y,features,theta);% The weighted feature counts
nll_f = features_val(:)'*theta_(:); %特征项
nll_reg = .5*modelParams.lambda*sum(theta.^2); %正则化项
nll = logZ - nll_f + nll_reg;

% grad
% 期望是怎么来的啊？==>p*N
% 每次p个，N次就是p*N
numParams = numel(theta);
MEfc = model_expected_feature_counts(CliqueTree,features,numParams);
Dfc = data_feature_counts(features,features_val,numParams);
grad_reg = modelParams.lambda*theta;
grad = MEfc(:) - Dfc(:) + grad_reg(:);
end

%% subfuncs
function factors = features2factors(features,modelParams,theta)
%make factors from features

Nf = numel(features);
factors = repmat(EmptyFactorStruct(),Nf,1);% one feature, one factor

for i = 1:Nf
    factors(i).var = features(i).var;
    factors(i).card = ones(1,numel(features(i).var))*modelParams.numHiddenStates;
    a = zeros(prod(factors(i).card));
    factors(i).val = exp(a);
    val_indicator_assingment = exp(theta(features(i).paramIdx)*1);
    factors(i) = SetValueOfAssignment(factors(i),features(i).assignment,val_indicator_assingment);
end

end

function [features_val,theta_] = weighted_feature_counts(Y,features,theta)
%parameter sharing: size(features) != size(theta)

% theta_
theta_ = theta([features.paramIdx]);


% features 值是多少啊？和Y有关
fh =@(var,assi) all(Y(var)==assi);
features_val = cellfun(fh,{features.var},{features.assignment});
end

function mefc = model_expected_feature_counts(CliqueTree,features,numParams)
%model expected feature counts

mefc = zeros(numParams,1);
Nf = numel(features);
for i = 1:Nf
    for j = 1:numel(CliqueTree.cliqueList)
        if all(ismember(features(i).var,CliqueTree.cliqueList(j).var))
            clique_ = CliqueTree.cliqueList(j);break
        end
    end
    var_eli = setdiff(clique_.var,features(i).var);
    Clique_margin = FactorMarginalization(clique_,var_eli);
    %p
    prob = Clique_margin.val/sum(Clique_margin.val);
    
    %f
    aindx = AssignmentToIndex(features(i).assignment,Clique_margin.card);
    features_v = 0*prob;
    features_v(aindx) = 1;
    
    %expectation
    expectation = prob(:)'*features_v(:);
    
    mefc(features(i).paramIdx) =  mefc(features(i).paramIdx) + expectation;
end
end

function Dfc = data_feature_counts(features,features_val,numParams)
%data_feature_counts

Dfc = zeros(numParams,1);
for i = 1:numel(features)
    Dfc(features(i).paramIdx) = Dfc(features(i).paramIdx) + features_val(i);
end
end