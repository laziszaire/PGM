function logpO_given_c_Op_ = logpO_given_c_Op(Gi,Pi_clg,Oi,Os)
%log(p(O|c,Opi) 1xK

% Gi: [has_parent,Opi]*numberclass
% Pi_clg: parameters gaussian
% Oi: the variable id
% Os: value of the all variables 10x3

Gi = reshape(Gi,2,[]);
K = numel(Pi_clg.sigma_y);
if size(Gi,2)==1,Gi = repmat(Gi,1,K);end
logpO_given_c_Op_ = zeros(1,K);
for k = 1:K
    sigmas_k = [Pi_clg.sigma_y(k);Pi_clg.sigma_x(k);Pi_clg.sigma_angle(k)];
    if Gi(1,k)==0  %Gaussian
        mus_k= [Pi_clg.mu_y(k);Pi_clg.mu_x(k);Pi_clg.mu_angle(k)];
    else           %CLG
        theta_ = reshape(Pi_clg.theta',4,3,K);%[1,y,x,alpha]*[y,x,alpha]*num_class
        parent = [1,Os(Gi(2,k),:)];
        mus_k = parent*squeeze(theta_(:,:,k));
    end
    logpO_given_c_Op_(k) = logOi(Oi,mus_k,sigmas_k); %log(O|c=k,Op)
end

end
