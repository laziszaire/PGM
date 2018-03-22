%ComputeInitialPotentials
load PA4Sample.mat
ComputeInitialPotentials(InitPotential.INPUT);
GetNextCliques(GetNextC.INPUT1,GetNextC.INPUT2);
CliqueTreeCalibrate(SumProdCalibrate.INPUT);
a = ComputeExactMarginalsBP( ExactMarginal.INPUT);

FactorMaxMarginalization(FactorMax.INPUT1,FactorMax.INPUT2);
ComputeExactMarginalsBP(MaxMarginals.INPUT);
maxMarginals = ComputeExactMarginalsBP(OCRNetworkToRun, [], 1);
MAPAssignment = MaxDecoding(maxMarginals);
DecodedMarginalsToChars(MAPAssignment)