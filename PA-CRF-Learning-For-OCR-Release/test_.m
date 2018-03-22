%% logistic regression
% StochasticGradientDescent
load Train1X.mat
load Train1Y.mat
thetaOpt = LRTrainSGD(Train1X,Train1Y,0);
pred = LRPredict(Train1X, thetaOpt);
acc = LRAccuracy(Train1Y, pred);
disp('accuracy is '+string(acc))

%regularization
load Train1X.mat
load Train1Y.mat
load Test1X.mat
load Test1Y.mat
thetaOpt = LRTrainSGD(Train1X,Train1Y,0);
pred_test = LRPredict(Test1X, thetaOpt);
acc_test = LRAccuracy(Test1Y, pred_test);
disp('no regularization accuracy is '+string(acc_test))


load Validation1X.mat
load Validation1Y.mat
load Part1Lambdas.mat
load ValidationAccuracy.mat
allAcc = LRSearchLambdaSGD(Train1X, Train1Y, Validation1X, Validation1Y, Part1Lambdas);
[~,idx] = max(allAcc);
best_lambda = Part1Lambdas(idx);
thetaOpt_ = LRTrainSGD(Train1X,Train1Y,best_lambda);
pred_test_ = LRPredict(Test1X, thetaOpt_);
acc_test1 = LRAccuracy(Test1Y, pred_test_);
disp('no regularization test accuracy is '+string(acc_test1))


%% CRF
clear
load Part2Sample
% log linear model
% feature: f(varibales.val) ==> R
% parameters: feature weights
% parameter sharing
[nll, grad] = InstanceNegLogLikelihood(sampleX, sampleY, sampleTheta, sampleModelParams);


