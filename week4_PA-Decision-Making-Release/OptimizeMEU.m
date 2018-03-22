% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU,OptimalDecisionRule_] = OptimizeMEU( I )

% Inputs: An influence diagram I with a single decision node and a single utility node.
%         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
%              the child variable = D.var(1)
%         I.DecisionFactors = factor for the decision node.
%         I.UtilityFactors = list of factors representing conditional utilities.
% Return value: the maximum expected utility of I and an optimal decision rule
% (represented again as a factor) that yields that expected utility.

% We assume I has a single decision node.
% You may assume that there is a unique optimal decision.
D = I.DecisionFactors(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE...
%
% Some other information that might be useful for some implementations
% (note that there are multiple ways to implement this):
% 1.  It is probably easiest to think of two cases - D has parents and D
%     has no parents.
% 2.  You may find the Matlab/Octave function setdiff useful.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EUF = CalculateExpectedUtilityFactor( I );
assigns = assignments_F(EUF);
index = D.var(1) ~= EUF.var;% parent joint
parents_assig = assigns(:,index);
[~,~,ic] = unique(parents_assig,'rows');
uc = unique(ic);
OptimalDecisionRule_.var  = EUF.var;
OptimalDecisionRule_.card  = EUF.card;
OptimalDecisionRule_.val  = 0*(1:prod(EUF.card));
Indx = 1:length(ic);
for i = 1:length(uc);
    index1 = ic == uc(i);
    [~,idx]= max(EUF.val(index1));%
    a = Indx(index1);
    OptimalDecisionRule_.val(a(idx)) = 1;
end
a = FactorProduct(EUF,OptimalDecisionRule_);
MEU = sum(a.val);
end
