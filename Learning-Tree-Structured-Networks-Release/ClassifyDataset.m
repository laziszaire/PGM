function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logCO = zeros(N,2);
for i = 1:N
    logCO(i,:) = logcO(squeeze(dataset(i,:,:)),P,G);
end
preds = logCO(:,1)>logCO(:,2);
accuracy = labels(:,1)==preds;
accuracy = sum(accuracy)/numel(accuracy);
fprintf('Accuracy: %.2f\n', accuracy);
end


function logCO = logcO(D1,P,G)
% joint p(c,O)
% G, graph structure,10 variable and their parent
% P, parameters, mu, sigma and theta,classp
% D, an instance, 10*3  numveriable*(y, x, alpha)

%return joint P(C,O)
N_variables =size(D1,1);
cp = P.c;
logc = log(cp);
logO_cpd = 0*logc;
    for i = 1:N_variables
        logO_cpd = logO_cpd + logcpd(G(i,:),P.clg(i),D1(i,:),D1); %factor product
    end
logCO = logO_cpd+logc; %bayessian rule
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