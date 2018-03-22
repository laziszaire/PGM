%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)

if nargin<2,isMax=0;end

% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j.
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute message
%1. joint, init_potential 和 接受到的所有除了j的message的joint
%2. marginal, 把不是ij共有的随机变量marginal out
%3. 归一化
a = [];
switch isMax
    case 0
        [i,j] = GetNextCliques(P,MESSAGES);
        while i>0.1
            m2send = MESSAGES(setdiff(find(P.edges(:,i)>0),j),i);% message to send, do not send back message from j
            init = P.cliqueList(i);
            prod_ = combine_message_init(m2send,init);
            sepset = intersect(P.cliqueList(i).var,P.cliqueList(j).var); %empty sepset?
            message = FactorMarginalization(prod_, setdiff(prod_.var,sepset));
            message.val = message.val/sum(message.val); %normalize
            MESSAGES(i,j) = message;
            [i,j] = GetNextCliques(P,MESSAGES);
            a(end+1,:) = [i,j];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % YOUR CODE HERE
        %
        % Now the clique tree has been calibrated.
        % Compute the final potentials for the cliques and place them in P.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %compute potentials -- production
        %1. joint init_potential 和 接受到的所有message的joint
        for i = 1:numel(P.cliqueList)
            m_received= MESSAGES(P.edges(:,i)>0,i);
            belif = ComputeJointDistribution([m_received;P.cliqueList(i)]);
            P.cliqueList(i) = belif;
        end
    case 1
        [i,j] = GetNextCliques(P,MESSAGES);
        %1. log clique init
        for ii = 1:numel(P.cliqueList),P.cliqueList(ii).val = log(P.cliqueList(ii).val);end
        %2. cal message
        while i>0.1
            m2send = MESSAGES(setdiff(find(P.edges(:,i)>0),j),i);% message to send, do not send back message from j
            init = P.cliqueList(i);
            sum_ = combine_message_init(m2send,init,isMax);
            sepset = intersect(P.cliqueList(i).var,P.cliqueList(j).var); %
            message = FactorMaxMarginalization(sum_, setdiff(sum_.var,sepset));
            MESSAGES(i,j) = message;
            [i,j] = GetNextCliques(P,MESSAGES);
        end
        %3. cal belifs
        for i = 1:numel(P.cliqueList)
            m_received= MESSAGES(P.edges(:,i)>0,i);
            belif = FacotrsSum([m_received;P.cliqueList(i)]);
            P.cliqueList(i) = belif;
        end
end
end


%%%%---subfunction ---
function prod_sum = combine_message_init(m2send,init,isMax)

if nargin<3,isMax=0;end
switch isMax
    case 0
        if isempty(m2send),m2send=[];end
        prod_sum = ComputeJointDistribution([m2send;init]);
    case 1
        if isempty(m2send),m2send=[];end
        prod_sum = FacotrsSum([m2send;init]);
end
end


function sum = FacotrsSum(F)
% Check for empty factor list
assert(numel(F) ~= 0, 'Error: empty factor list');
if (length(F) == 0)
    % There are no factors, so create an empty factor list
    sum = struct('var', [], 'card', [], 'val', []);
else
    sum = F(1);
    for i = 2:length(F)
        % Iterate through factors and incorporate them into the joint distribution
        sum = FactorSum(sum, F(i));
    end
end
end

function C = FactorSum(A,B)
%factor sum
% Check for empty factors
if (isempty(A.var)), C = B; return; end;
if (isempty(B.var)), C = A; return; end;

% Check that variables in both A and B have the same cardinality
[dummy iA iB] = intersect(A.var, B.var);
if ~isempty(dummy)
	% A and B have at least 1 variable in common
	assert(all(A.card(iA) == B.card(iB)), 'Dimensionality mismatch in factors');
end
C.var = union(A.var,B.var);
[~, mapA] = ismember(A.var, C.var);
[~, mapB] = ismember(B.var, C.var);
C.card = zeros(1, length(C.var));
C.card(mapA) = A.card;
C.card(mapB) = B.card;
C.val = zeros(1,prod(C.card));
assignments = IndexToAssignment(1:prod(C.card), C.card);
indxA = AssignmentToIndex(assignments(:, mapA), A.card);
indxB = AssignmentToIndex(assignments(:, mapB), B.card);
C.val = A.val(indxA) + B.val(indxB);
end