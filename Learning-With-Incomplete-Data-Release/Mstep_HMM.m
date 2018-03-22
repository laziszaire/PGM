function P = Mstep_HMM(ClassProb,PairProb,G,actionData,poseData)
%MLE of parameters

% ClassProb is the soft assignments of the hidden states in log space
K = size(ClassProb, 2);

% p(S1): K*1£¬K is number of class for pose

s1_ind = cellfun(@(a) a(1),{actionData.marg_ind});
P.c = norm_(sum(ClassProb(s1_ind,:)));

% p(S|S') 
% P.transMatrix
% pairProb -- p(s',s) == margianl out s' ==>p(s)
% transition  p(s'|s) = p(s',s)/p(s)

dirchlet = size(PairProb,1) * .05;
allPairProb = PairProb([actionData.pair_ind],:);
P.transMatrix = norm_m(sum(reshape(allPairProb',K,K,[]),3)+dirchlet);%dirchlet

%p(O|s) ==> P.clg
P.clg = est_clg(G,poseData,ClassProb);
end


function clg = est_clg(G,dataset,classProb)
%
%dataset:posedata
clg.sigma_x = [];
clg.sigma_y = [];
clg.sigma_angle = [];
clg.mu_x = [];
clg.mu_y = [];
clg.mu_angle = [];
clg.theta = [];
K = size(classProb,2);
nO = size(G,1);
for k = 1:K
    Gk = G;if numel(size(G))==3,Gk = G(:,:,k);end
    W_k = classProb(:,k);
    for i_O = 1:nO
         X = squeeze(dataset(:,i_O,:));
        [y,x,angle] = deal(X(:,1),X(:,2),X(:,3));
        [has_parent,id_parent] = deal(Gk(i_O,1),Gk(i_O,2));
        if has_parent
            X_parent = squeeze(dataset(:,id_parent,:));
            [Beta(:,1),clg(i_O).sigma_y(1,k)]= FitLG(y,X_parent,W_k);
            [Beta(:,2),clg(i_O).sigma_x(1,k)]= FitLG(x,X_parent,W_k);
            [Beta(:,3),clg(i_O).sigma_angle(1,k)]= FitLG(angle,X_parent,W_k);
            theta = Beta([end,1:end-1],:);
            clg(i_O).theta(k,:) = theta(:);
        elseif ~has_parent
            [clg(i_O).mu_y(1,k),clg(i_O).sigma_y(1,k)]= FitG(y,W_k);
            [clg(i_O).mu_x(1,k),clg(i_O).sigma_x(1,k)]= FitG(x,W_k);
            [clg(i_O).mu_angle(1,k),clg(i_O).sigma_angle(1,k)]= FitG(angle,W_k);
        end
    end
end
end



function p = norm_m(measure)

p = bsxfun(@rdivide,measure,sum(measure,2));
end

function p = norm_(measure)

p = measure/sum(measure);
end