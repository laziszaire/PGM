% Copyright (C) Daphne Koller, Stanford University, 2012

function EU = SimpleCalcExpectedUtility(I)

  % Inputs: An influence diagram, I (as described in the writeup).
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return Value: the expected utility of I
  % Given a fully instantiated influence diagram with a single utility node and decision node,
  % calculate and return the expected utility.  Note - assumes that the decision rule for the 
  % decision node is fully assigned.

  % In this function, we assume there is only one utility node.
  F = [I.RandomFactors I.DecisionFactors];
  U = I.UtilityFactors(1);
  EU = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  % get p: marginals for parent of U 
  all_var = [F.var];
  Z = setdiff(all_var,U.var); 
  Fnew = VariableElimination(F, Z); % variable elimination: remove all the variable that is not in Utility factor                                                        
  p_U = FacotorsProduct(Fnew); %  prod.val is probablity of assignments in Utility factor
  
  % expectation: U*p
  EU = FactorProduct(p_U,U);    
  EU = sum(EU.val);
  
end


function prod = FacotorsProduct(Flist)
% factor product of a list of factor
% can be use to get a joint

prod = Flist(1);
  for i = 2:length(Flist)
      prod = FactorProduct(prod, Flist(i));%prod.val is probablity of assignments in Utility factor
  end
end
