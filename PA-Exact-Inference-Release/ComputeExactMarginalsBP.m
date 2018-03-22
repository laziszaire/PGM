%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1).
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the
%   network where M(i) represents the ith variable and M(i).val represents
%   the marginals of the ith variable.
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

if nargin<2,E=[];isMax=0;end
% initialization
% you should set it to the correct value in your code
%%% what to init?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P,isMax);
var1 = unique([F.var]);
N = numel(var1);
M = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
%exact
for i = 1:N
    idx = find(cellfun(@(x) ismember(var1(i),x),{P.cliqueList.var}));
    f = P.cliqueList(idx(1));%cliques中任意一个包含var的clique
    switch isMax
        case 0
            M(i) = FactorMarginalization(f,setdiff(f.var,var1(i)));
            M(i).val = M(i).val/sum(M(i).val);
        case 1
            % MAP log
            M(i) = FactorMaxMarginalization(f,setdiff(f.var,var1(i)));
    end
end





end
