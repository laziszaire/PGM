function [MEU,OptimalDecisionRule_] = cal_OptimalDecisionRule(EUF,D)

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