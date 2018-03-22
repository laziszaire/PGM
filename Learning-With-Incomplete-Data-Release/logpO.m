function [logpO_,logp_cO_] = logpO(Os,P,G)
%logp(O): scalar

% G, graph structure,10 variable,their parent and class
% P, parameters, mu, sigma and theta,classp
% Os, an instance, 10*3  numveriable*(y, x, alpha)

logp_cO_ = logp_cO(Os,P,G);
logpO_ = logsumexp(logp_cO_); %marginal out c: log(P(O)) = for i in numel(c),sum(P(O,c(i)))
end