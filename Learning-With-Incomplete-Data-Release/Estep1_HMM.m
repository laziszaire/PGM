function [M, PCalibrated] = Estep1_HMM(P,G,actionData1,poseData)
%soft assignement of hidden variables: marginal of hidden variables

K = numel(P.c);
F = get_factors(actionData1.marg_ind,P,G,K,poseData);
[M, PCalibrated] = ComputeExactMarginalsHMM(F);
end


function fs = get_factors(marg_ind,P,G,K,poseData)
%factor value in log space

nS = numel(marg_ind);

%p(S1)
pS1 = struct('var',1,'card',K,'val',log(P.c));

%p(S'|S)
pSS = repmat(struct('var',[],'card',[K,K],'val',log(reshape(P.transMatrix,1,[]))),nS-1,1);%log space
for i = 1:nS-1
    pSS(i).var = [i,i+1];
end

%p(P|S),observed P ==> phi(S)

pPS = repmat(struct('var',[],'card',K,'val',[]),nS,1);
for i = 1:nS
    logpPS = logpPS_(G,P,squeeze(poseData(marg_ind(i),:,:))); %do need prior probability
    pPS(i).val = logpPS;
    pPS(i).var = i;%ith hidden state of an action i.
end
fs = [pS1;pSS;pPS];
end

function logpPS = logpPS_(G,P,pose)
%p(P|S),observed P ==> phi(S)

nO = size(G,1);
K = numel(P.c);
logP = zeros(nO,K);
for k = 1:K
    for i_O=1:nO
        sigmas = [P.clg(i_O).sigma_y(k),P.clg(i_O).sigma_x(k),P.clg(i_O).sigma_angle(k)];
        if isempty(P.clg(i_O).mu_y)
            %compute mu of CLG
            parent = [1,squeeze(pose(G(i_O,2),:))];
            theta_k = reshape(P.clg(i_O).theta(k,:),4,3);
            mus = parent*theta_k;
        else
            mus = [P.clg(i_O).mu_y(k),P.clg(i_O).mu_x(k),P.clg(i_O).mu_angle(k)];
        end
        logP(i_O,k) = logOi(pose(i_O,:),mus,sigmas);
    end
end
    logpPS = sum(logP);%factor product of Os
% fixed bug, next and  do not normalize,    logpPS = bsxfun(@minus,logpPS,logsumexp(logpPS));% p(P|S) 
end