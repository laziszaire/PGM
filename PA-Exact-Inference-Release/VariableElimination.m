% VariableElimination takes in a list of factors F and a list of variables to eliminate
% and returns the resulting factor after running sum-product to eliminate
% the given variables.
%
%   Fnew = VariableElimination(F, Z) 
%   F = list of factors
%   Z = list of variables to eliminate
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function Fnew = VariableElimination(F, Z)

% List of all variables
V = unique([F(:).var]);

% Setting up the adjacency matrix.
edges = zeros(length(V));

for i = 1:length(F)
    for j = 1:length(F(i).var)
        for k = 1:length(F(i).var)
            edges(F(i).var(j), F(i).var(k)) = 1;
        end
    end
end

variablesConsidered = 0;

while variablesConsidered < length(Z)
    
    % Using Min-Neighbors where you prefer to eliminate the variable that has
    % the smallest number of edges connected to it. 
    % Everytime you enter the loop, you look at the state of the graph and 
    % pick the variable to be eliminated.
    bestVariable = 0;
    bestScore = inf;
    for i=1:length(Z)
      idx = Z(i);
      score = sum(edges(idx,:));
      if score > 0 && score < bestScore
	bestScore = score;
	bestVariable = idx;
      end
    end

    variablesConsidered = variablesConsidered + 1;
    [F, edges] = EliminateVar(F, edges, bestVariable);
    
end

Fnew = F;
end

% Function used in production of clique trees
% F = list of factors
% E = adjacency matrix for variables
% Z = variable to eliminate
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function [newF E] = EliminateVar(F, E, Z)

  % Index of factors to multiply (b/c they contain Z)
  useFactors = [];

  % Union of scopes of factors to multiply
  scope = [];

  for i=1:length(F)
    if any(F(i).var == Z)
      useFactors = [useFactors i];
      scope = union(scope, F(i).var);
    end
  end

  % update edge map
  % These represent the induced edges for the VE graph.
  for i=1:length(scope)
    for j=1:length(scope)
      
      if i~=j
	E(scope(i),scope(j)) = 1;
	E(scope(j),scope(i)) = 1;
      end
    end
  end

  % Remove all adjacencies for the variable to be eliminated
  E(Z,:) = 0;
  E(:,Z) = 0;


  % nonUseFactors = list of factors (not indices!) which are passed through
  % in this round
  nonUseFactors = setdiff(1:length(F),[useFactors]);

  for i=1:length(nonUseFactors)
    
    % newF = list of factors we will return
    newF(i) = F(nonUseFactors(i));
    
    % newmap = ?
    newmap(nonUseFactors(i)) = i;
  
  end

  % Multiply factors which involve Z -> newFactor
  newFactor = struct('var', [], 'card', [], 'val', []);
  for i=1:length(useFactors)
    newFactor = FactorProduct(newFactor,F(useFactors(i)));
  end

  newFactor = FactorMarginalization(newFactor,Z);
  newF(length(nonUseFactors)+1) = newFactor;

end
