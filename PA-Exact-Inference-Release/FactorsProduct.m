function Fsp = FactorsProduct(Factors)

N = length(Factors);
Fsp = Factors(1);
if N<2,Fsp = Factors(1);return,end
for i = 2:length(Factors)
    Fsp = FactorProduct(Fsp,Factors(i));
end
end