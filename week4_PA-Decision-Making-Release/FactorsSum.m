function sums = FactorsSum(Factors)
sums = Factors(1);
for i = 2:length(Factors)
    sums = FactorSum(sums,Factors(i));
end
end