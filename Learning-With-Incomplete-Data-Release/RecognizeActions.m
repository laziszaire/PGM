% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [accuracy, predicted_labels] = RecognizeActions(datasetTrain, datasetTest, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the instances in datasetTest, with N being the number of unknown test instances


% Train a model for each action
% Note that all actions share the same graph parameterization and number of max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i_aclass = 1:numel(datasetTrain)
    P(i_aclass) = EM_HMM(datasetTrain(i_aclass).actionData,...
        datasetTrain(i_aclass).poseData,...
        G,...
        datasetTrain(i_aclass).InitialClassProb,...
        datasetTrain(i_aclass).InitialPairProb,...
        maxIter);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_action = numel(datasetTest.actionData);
loglikelihood = zeros(n_action,numel(P));
for i_action = 1:n_action
    loglikelihood(i_action,:) = ll(P,G,datasetTest.actionData(i_action),datasetTest.poseData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
[~,predicted_labels] = max(loglikelihood,[],2);
a_ = predicted_labels == datasetTest.labels;
accuracy = sum(a_)/numel(a_);
end

function loglikelihoods = ll(P,G,actionData,poseData)
% given parameters, do inference: marginal==>softassignment
% loglikelihood

n_aclass = numel(P);
loglikelihoods = zeros(1,n_aclass);
for i_aclass = 1:n_aclass
    [~, PCalibrated] = Estep1_HMM(P(i_aclass),G,actionData,poseData);
    loglikelihoods(i_aclass) = logsumexp(PCalibrated.cliqueList(end).val);
end
end