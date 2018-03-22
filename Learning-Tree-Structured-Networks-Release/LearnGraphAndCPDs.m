function [P,G,loglikelihood] = LearnGraphAndCPDs(dataset, labels)

% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha) 
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

G = zeros(10,2,K); % graph structures to learn
% initialization
for k=1:K
    G(2:end,:,k) = ones(9,2);
end

% estimate graph structure for each class
for k=1:K
    % fill in G(:,:,k)
    % use ConvertAtoG to convert a maximum spanning tree to a graph G
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%
    datasetk = dataset(labels(:,k)>0,:,:);
    Ak = LearnGraphStructure(datasetk);
    G(:,:,k) = ConvertAtoG(Ak);
end

% estimate parameters
loglikelihood =zeros(K,1);
P.c = zeros(1,K);
P.c = sum(labels)/size(labels,1);
% compute P.c
% the following code can be copied from LearnCPDsGivenGraph.m
% with little or no modification
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
vs= {'y','x','alpha'};
nvs = numel(vs);
Beta = zeros((nvs+1),nvs);
for k = 1:K
    Gk = squeeze(G(:,:,k));
    Dk = dataset(labels(:,k)>0,:,:);
    for var = 1:size(Gk,1)
        X = squeeze(Dk(:,var,:));
        mu = zeros(nvs,1);
        sigma = mu;
        if Gk(var,1)==0
            %除了c没有其他parent
            for j = 1:nvs
                [mu(j),sigma(j)] = FitGaussianParameters(X(:,j));
            end
            P.clg(var).mu_y(1,k) = mu(1);
            P.clg(var).mu_x(1,k) = mu(2);
            P.clg(var).mu_angle(1,k) = mu(3);  
        else %有其他varibale作为parent
            U = squeeze(Dk(:,Gk(var,2),:));
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
% loglikelihood = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('log likelihood: %f\n', loglikelihood);
end