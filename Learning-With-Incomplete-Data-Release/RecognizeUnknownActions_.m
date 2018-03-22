function predicted_labels = RecognizeUnknownActions_(datasetTrain, datasetTest, G, maxIter)

%Train
for i_aclass = 1:numel(datasetTrain)
    P(i_aclass) = EM_HMM(datasetTrain(i_aclass).actionData,...
        datasetTrain(i_aclass).poseData,...
        G,...
        datasetTrain(i_aclass).InitialClassProb,...
        datasetTrain(i_aclass).InitialPairProb,...
        maxIter);
end

%predict
n_action = numel(datasetTest.actionData);
loglikelihood = zeros(n_action,numel(P));
for i_action = 1:n_action
    loglikelihood(i_action,:) = ll(P,G,datasetTest.actionData(i_action),datasetTest.poseData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
[~,predicted_labels] = max(loglikelihood,[],2);


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