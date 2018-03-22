function Fsp = FactorsProduct(Factors)

Fsp = Factors(1);
for i = 2:length(Factors)
    Fsp = FactorProduct(Fsp,Factors(i));
end
end