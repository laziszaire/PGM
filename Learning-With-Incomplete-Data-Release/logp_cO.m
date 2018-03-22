function logp_cO_ = logp_cO(Os,P,G)
% joint logp(c,O) 1*2

% G, graph structure,10 variable and their parent
% P, parameters, mu, sigma and theta,classp
% Os, an instance, 10*3  numveriable*(y, x, alpha)

%return joint P(C,O)
N_variables =size(Os,1);
cp = P.c;
logc = log(cp);
logpO_given_c_Op_ = 0*logc;
    for i = 1:N_variables
        logpO_given_c_Op_(i,:) = logpO_given_c_Op(G(i,:),P.clg(i),Os(i,:),Os);
    end
% sum(logO_cpd):  prodcut of [P(O1|c,Op1),P(O2|c,Op2),...] = P(O|c)
logp_cO_ = sum(logpO_given_c_Op_)+logc; %P(O,c) = P(O|c)p(c)
end

