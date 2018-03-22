% File: EM_cluster.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P,loglikelihood,ClassProb] = EM_cluster(poseData, G, InitialClassProb, maxIter)

% INPUTS
% poseData: N x 10 x 3 matrix, where N is number of poses;
%   poseData(i,:,:) yields the 10x3 matrix for pose i.
% G: graph parameterization as explained in PA8
% InitialClassProb: N x K, initial allocation of the N poses to the K
%   classes. InitialClassProb(i,j) is the probability that example i belongs
%   to class j
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K, conditional class probability of the N examples to the
%   K classes in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to class j

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
ClassProb = InitialClassProb;
loglikelihood = zeros(maxIter,1);

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];
P.clg.mu_x = [];
P.clg.mu_y = [];
P.clg.mu_angle = [];
P.clg.theta = [];
% EM algorithm
for iter=1:maxIter
    
    % M-STEP to estimate parameters for Gaussians
    %
    % Fill in P.c with the estimates for prior class probabilities
    % Fill in P.clg for each body part and each class
    % Make sure to choose the right parameterization based on G(i,1)
    %
    % Hint: This part should be similar to your work from PA8
    
%     P.c = zeros(1,K);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P = Mstep(ClassProb,G,poseData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % E-STEP to re-estimate ClassProb using the new parameters
    %
    % Update ClassProb with the new conditional class probabilities.
    % Recall that ClassProb(i,j) is the probability that example i belongs to
    % class j.
    %
    % You should compute everything in log space, and only convert to
    % probability space at the end.
    %
    % Tip: To make things faster, try to reduce the number of calls to
    % lognormpdf, and inline the function (i.e., copy the lognormpdf code
    % into this file)
    %
    % Hint: You should use the logsumexp() function here to do
    % probability normalization in log space to avoid numerical issues
    
%     ClassProb = zeros(N,K);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ClassProb = E_step(P,G,poseData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Compute log likelihood of dataset for this iteration
    % Hint: You should use the logsumexp() function here
%     loglikelihood(iter) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     loglikelihood(iter) = ComputeLogLikelihood(P, G, poseData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Print out loglikelihood
    disp(sprintf('EM iteration %d: log likelihood: %f', ...
        iter, loglikelihood(iter)));
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end
    
    % Check for overfitting: when loglikelihood decreases
    if iter > 1
        if loglikelihood(iter) < loglikelihood(iter-1)
            break;
        end
    end
    
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
end

function P = Mstep(ClassProb,G,dataset)
% MLE估计参数
% ClassProb 是各instance对某class影响的权重

P.c = mean(ClassProb);
K = size(ClassProb,2);
[~,nO,nvs] = size(dataset);%vs= {'y','x','alpha'};
Beta = zeros((nvs+1),nvs);

for k = 1:K
    W_k = ClassProb(:,k);%influence weights of instance for class k
    Gk=G;if numel(size(G))==3,Gk = squeeze(G(:,:,k));end
    for i_O = 1:nO
        [Oi_has_parent,Oi_parent_id] = deal(Gk(i_O,1),Gk(i_O,2));%bug fixed，下次别这样复制了
        X = squeeze(dataset(:,i_O,:));
        [y,x,angle] = deal(X(:,1),X(:,2),X(:,3));
        if ~Oi_has_parent
            [P.clg(i_O).mu_y(1,k),P.clg(i_O).sigma_y(1,k)]= FitG(y,W_k);
            [P.clg(i_O).mu_x(1,k),P.clg(i_O).sigma_x(1,k)]= FitG(x,W_k);
            [P.clg(i_O).mu_angle(1,k),P.clg(i_O).sigma_angle(1,k)]= FitG(angle,W_k);
        elseif Oi_has_parent
            % parameters for P(Oi|C,Opi) = P(yi|c,Opi)*P(xi|c,Opi)*P(anglei|c,Opi)
            X_parent = squeeze(dataset(:,Oi_parent_id,:));
            %cellfun(@(e) all(e=='y'),vs)
            [Beta(:,1),P.clg(i_O).sigma_y(1,k)]= FitLG(y,X_parent,W_k);
            [Beta(:,2),P.clg(i_O).sigma_x(1,k)]= FitLG(x,X_parent,W_k);
            [Beta(:,3),P.clg(i_O).sigma_angle(1,k)]= FitLG(angle,X_parent,W_k);
            theta = Beta([end,1:end-1],:);
            P.clg(i_O).theta(k,:) = theta(:);
        end
    end
end
end

function ClassProb = E_step(P,G,dataset)
%conditional class prob: P(c|O)

[M,~,~] =size(dataset);
K = numel(P.clg(1).sigma_y);
logp_cO_ = zeros(M,K);
logpO_ = logp_cO_(:,1);
parfor i = 1:M
    %joint: p(c,O)
    [logpO_(i),logp_cO_(i,:)] = logpO(squeeze(dataset(i,:,:)),P,G);
end
% condition on p(O) ==> p(c|O) = p(c,O)/p(O)
% logp(c|O) = logp(c,O)-logp_O
% ClassProb = exp(logCO - logPO);

logp_c_given_O= bsxfun(@minus,logp_cO_,logpO_);
ClassProb = exp(logp_c_given_O);
end



function loglikelihood = ComputeLogLikelihood(P, G, dataset)
%logp(O)
% probability of the dataset, not include the class

N_instance = size(dataset,1);
loglikelihood =0;
parfor i = 1:N_instance
    loglikelihood = loglikelihood+logpO(squeeze(dataset(i,:,:)),P,G);
end
end