function loglikelihood = ComputeLogLikelihood(P, G, dataset)
% returns the (natural) log-likelihood of data given the model and graph structure
%
% Inputs:
% P: struct array parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description)
%
%    NOTICE that G could be either 10x2 (same graph shared by all classes)
%    or 10x2x2 (each class has its own graph). your code should compute
%    the log-likelihood using the right graph.
%
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
%
% Output:
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N_instance = size(dataset,1); % number of examples
K = length(P.c); % number of classes

loglikelihood = 0;
% You should compute the log likelihood of data as in eq. (12) and (13)
% in the PA description
% Hint: Use lognormpdf instead of log(normpdf) to prevent underflow.
%       You may use log(sum(exp(logProb))) to do addition in the original
%       space, sum(Prob).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N_instance
    loglikelihood = loglikelihood+logPO_(squeeze(dataset(i,:,:)),P,G);
end
end


function logPO = logPO_(Os,P,G)
% G, graph structure,10 variable,their parent and class
% P, parameters, mu, sigma and theta,classp
% D, an instance, 10*3  numveriable*(y, x, alpha)

N_variables =size(Os,1);
cp = P.c;
logc = log(cp);
logO_cpd = 0*logc;
for i = 1:N_variables
    logO_cpd(i,:) = logcpd(squeeze(G(i,:,:)),P.clg(i),Os(i,:),Os); %(y,x,alpha) product
end
% prodcut of [P(O1|c),P(O2|c),...]
% bayesian P(O,c) = P(O|c)p(c)
logP = logc+sum(logO_cpd);
%marginal out c: P(O) = for i in numel(c),sum(P(O,c(i)))
logPO = log(sum(exp(logP))); %%
end


function logO_cpd = logcpd(Gi,Pi_clg,Oi,Os)
% log(y)+log(x)+log(alpha)
%Gi为2*numberclass

%logO_cpd :[1,K]
Gi = reshape(Gi,2,[]);
K = numel(Pi_clg.sigma_y);
if size(Gi,2)==1,Gi = repmat(Gi,1,K);end
logO_cpd = zeros(1,K);
for k = 1:K
    sigmas_k = [Pi_clg.sigma_y(k);Pi_clg.sigma_x(k);Pi_clg.sigma_angle(k)];
    if Gi(1,k)==0  %Gaussian
        mus_k= [Pi_clg.mu_y(k);Pi_clg.mu_x(k);Pi_clg.mu_angle(k)];
    else           %CLG
        theta_ = reshape(Pi_clg.theta',4,3,K);%[1,y,x,alpha]*[y,x,alpha]*num_class
        parent = [1,Os(Gi(2,k),:)];
        mus_k = parent*squeeze(theta_(:,:,k));
    end
    logO_cpd(k) = logOi(Oi,mus_k,sigmas_k); %log(O|c=k,Op)
end

end

function logO = logOi(Di,mus,sigmas)
% 计算Oi variable的条件log概率
% log(y)+log(x)+log(alpha)

num_yxalpha = numel(mus);
logO = 0;
for i = 1:num_yxalpha
    logO = logO+ lognormpdf(Di(i),mus(i),sigmas(i));
end
end