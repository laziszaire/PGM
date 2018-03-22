%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);
flist = C.factorList;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.edges = C.edges;
for i = 1:N
    [P.cliqueList(i),flist] = clique_init(C.nodes{i},flist,C.factorList);
end
end


%% subfunc
function [clique,flist] = clique_init(node,flist,flist_all)
%init the clique
clique.var = node;
for i = 1:numel(clique.var)
    for j = 1:numel(flist_all)
        idx = (clique.var(i) == flist_all(j).var);
        if any(idx)
         clique.card(i) = flist_all(j).card(idx);
         break;
        end
    end
end
clique.val = ones(1,prod(clique.card));%init clique to all 1s
if isempty(flist),return,end
to_del = [];
for fi = 1:numel(flist)
    if all(ismember(flist(fi).var,clique.var))
        clique = ComputeJointDistribution([clique;flist(fi)]);
        to_del(end+1)=fi;
    end
end
flist(to_del)=[];
end