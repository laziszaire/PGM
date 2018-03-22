function [P,loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the
%         the ith example belongs to class j and 0 elsewhere
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

loglikelihood = 0;
P.c = zeros(1,K);
P.c = sum(labels)/size(labels,1);
% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
vs= {'y','x','alpha'};
nvs = numel(vs);
Beta = zeros((nvs+1),nvs);
for k = 1:K
    Dk = dataset(labels(:,k)>0,:,:);
    for var = 1:size(G,1)
        X = squeeze(Dk(:,var,:));
        mu = zeros(nvs,1);
        sigma = mu;
        if G(var,1)==0
            %除了c没有其他parent
            for j = 1:nvs
                [mu(j),sigma(j)] = FitGaussianParameters(X(:,j));
            end
            P.clg(var).mu_y(1,k) = mu(1);
            P.clg(var).mu_x(1,k) = mu(2);
            P.clg(var).mu_angle(1,k) = mu(3);  
        else %有其他varibale作为parent
            U = squeeze(Dk(:,G(var,2),:));
            for j = 1:nvs
                [Beta(:,j),sigma(j)] = FitLinearGaussianParameters(X(:,j),U);
            end
            theta = Beta([end,1:end-1],:);%beta = [y,x,alpha,1], theta = [1,y,x,alpha]
            P.clg(var).mu_y = [];
            P.clg(var).mu_x = [];
            P.clg(var).mu_angle= [];
            P.clg(var).theta(k,:) = theta(:);
        end
        P.clg(var).sigma_y(1,k) = sigma(1);
        P.clg(var).sigma_x(1,k) = sigma(2);
        P.clg(var).sigma_angle(1,k) = sigma(3);
    end 
end

loglikelihood = ComputeLogLikelihood(P, G, dataset);
% These are dummy lines added so that submit.m will run even if you
% have not started coding. Please delete them.
% P.clg.sigma_x = 0;
% P.clg.sigma_y = 0;
% P.clg.sigma_angle = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('log likelihood: %f\n', loglikelihood);
end
