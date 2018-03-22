function [mu,sigma] = FitGaussianParameters(X)
% X: (N x 1): N examples (1 dimensional)
% Fit N(mu, sigma^2) to the empirical distribution
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

mu = 0;
sigma = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%
% maximum likelihood estimation
% likelihood  = prod(1/(sqrt(2*pi)*sigma)*exp(-(x-mu)^2/(2*sigma^2)))
% ll(sigma,mu) = N*log(1/(sqrt(2*pi)*sigma)-sum((x-mu)^2/(2*sigma^2))
% g_mu = mu-sum(x)
mu = mean(X);
%ll = -N*log(sqrt(2*pi))-N*log(sigma)-sum((x-mu)^2)/(2*sigma^2)
%   = -N*log(sqrt(2*pi))-N/2*log(sigma^2)-sum((x-mu) ^2)/(2*sigma^2)
%¶ÔsigmaÇóÆ«µ¼
%g_sigma = -N*2*sigma/(2*sigma^2)+sum((x-mu)^2)/(sigma^3) = 0
% ==>  -N/sigma + sum((x-mu)^2)/sigma^3=0
% ==> sigma^2 = sum((x-mu)^2)/N
sigma = std(X,1);
end
