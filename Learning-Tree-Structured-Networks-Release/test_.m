%%
X = exampleINPUT.t2a1;
U = exampleINPUT.t2a2;
[Beta,sigma] = FitLinearGaussianParameters(X, U);
%%
load PA8SampleCases.mat
P = exampleINPUT.t3a1;
G = exampleINPUT.t3a2;
dataset = exampleINPUT.t3a3;
 D1 = squeeze(dataset(1,:,:));
 loglikelihood = ComputeLogLikelihood(P, G, dataset);
 loglikelihood-exampleOUTPUT.t3

 %% learning parameters with known graph structures
 % 可能有多个图结构
clear
load PA8SampleCases.mat
dataset = exampleINPUT.t4a1;
G = exampleINPUT.t4a2;
labels = exampleINPUT.t4a3;
[P,loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels);
% P没问题
% loglikelihood 也没问题
loglikelihood - exampleOUTPUT.t4o2
%% -----------------------------------
% ClassifyDataset
clear
load PA8SampleCases.mat
dataset = exampleINPUT.t5a1;
labels = exampleINPUT.t5a2;
P = exampleINPUT.t5a3;
G = exampleINPUT.t5a4;
accuracy = ClassifyDataset(dataset, labels, P, G);
load PA8Data.mat
%%
load PA8Data.mat
[P1 likelihood1] = LearnCPDsGivenGraph(trainData.data, G1, trainData.labels);
accuracy1 = ClassifyDataset(testData.data, testData.labels, P1, G1);
%VisualizeModels(P1, G1);
[P2 likelihood2] = LearnCPDsGivenGraph(trainData.data, G2, trainData.labels);
accuracy2 = ClassifyDataset(testData.data, testData.labels, P2, G2);
%VisualizeModels(P2, G2);
%%
% ---Learning Graph Structures---
% given a scoring function
% maximum spanning tree

% edge weights
clear
load PA8SampleCases.mat
dataset = exampleINPUT.t6a1;
[A,W] = LearnGraphStructure(dataset);
A == exampleOUTPUT.t6o1
mean(W-exampleOUTPUT.t6o2)
%% LearnGraphAndCPDs
clear
load PA8SampleCases.mat
load PA8Data.mat
dataset = exampleINPUT.t7a1;
labels = exampleINPUT.t7a2;
[P,G,loglikelihood] = LearnGraphAndCPDs(dataset, labels);
%all(exampleOUTPUT.t7o2 ==G)
% G check
% P 不对,值是对的，顺序不对是因为beta和theta顺序不对，详见LearnGraphAndCPDs
% sum(sum(P.clg(2).theta - exampleOUTPUT.t7o1.clg(2).theta))

%loglikelihood
loglikelihood - exampleOUTPUT.t7o3
%%
clear
load PA8Data.mat
[P3,G3,likelihood3] = LearnGraphAndCPDs(trainData.data, trainData.labels);
ClassifyDataset(testData.data, testData.labels, P3, G3);
%likelihood对了
%accuracy不对
