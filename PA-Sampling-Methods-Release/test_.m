%block sampling
load('exampleIOPA5.mat')
disp('logBS')
[V, G, F, A] = deal(exampleINPUT.t6a1,exampleINPUT.t6a2,exampleINPUT.t6a3,exampleINPUT.t6a4);
LogBS = BlockLogDistribution(V, G, F, A);
disp(~any(round(LogBS - exampleOUTPUT.t6)))

sumabs = @(a) sum(abs(a(:)));
%gibbs trans
disp('gibbs trans')
clear
load('exampleIOPA5.mat')
[A, G, F] = deal(exampleINPUT.t7a1{1},exampleINPUT.t7a2{1},exampleINPUT.t7a3{1});
Anext = GibbsTrans(A, G, F);
disp(sumabs(Anext - exampleOUTPUT.t7{1})<.001)

%MCMC inference
clear
load('exampleIOPA5.mat')
[toy_network, toy_factors] = ConstructToyNetwork(1, .1);
nvar = length(toy_network.names);
A0 = exampleINPUT.t8a8{1};
E = exampleINPUT.t8a3{1};
[G,F,mix_time]= deal(exampleINPUT.t8a1{1},exampleINPUT.t8a2{1},exampleINPUT.t8a5{1});
[M, all_samples] = MCMCInference(G,F, E, 'Gibbs', mix_time, ...
                                                  exampleINPUT.t8a6{1}, 1, A0);
t8o1 = exampleOUTPUT.t8o1{1};
sumabs(t8o1(1).val-M(1).val)

%MHUniformTrans    baseline
clear
load('exampleIOPA5.mat')
[A, G, F] = deal(exampleINPUT.t9a1{1},exampleINPUT.t9a2{1},exampleINPUT.t9a3{1});
Aout = MHUniformTrans(A, G, F);
sumabs(exampleOUTPUT.t9{1}-Aout)

%MHSWTrans1
[A, G, F, variant] = deal(exampleINPUT.t10a1{1},exampleINPUT.t10a2{1},exampleINPUT.t10a3{1},exampleINPUT.t10a4{1});
Aout = MHSWTrans(A, G, F, variant);
sumabs(Aout - exampleOUTPUT.t10{1})


%MHSWTrans2
clear
load('exampleIOPA5.mat')
[A, G, F, variant] = deal(exampleINPUT.t11a1{1},exampleINPUT.t11a2{1},exampleINPUT.t11a3{1},exampleINPUT.t11a4{1});
Aout = MHSWTrans(A, G, F, variant);
sumabs(Aout - exampleOUTPUT.t11{1})

%MCMCInference.m PART 2
clear
load('exampleIOPA5.mat')
[G, F, E, TransName, mix_time,num_samples, sampling_interval, A0] =...
                      deal(exampleINPUT.t12a1{1},exampleINPUT.t12a2{1},exampleINPUT.t12a3{1},exampleINPUT.t12a4{1},...
                          exampleINPUT.t12a5{1},exampleINPUT.t12a6{1},exampleINPUT.t12a7{1},exampleINPUT.t12a8{1});
[M11, all_samples11] = MCMCInference(G, F, E, TransName, mix_time, ...
                                                  num_samples, sampling_interval, A0);
sumabs(M11(1).val - exampleOUTPUT.t12o1{1}(1).val)                                   
    %
clear
load('exampleIOPA5.mat')
[G, F, E, TransName, mix_time,num_samples, sampling_interval, A0] =...
                      deal(exampleINPUT.t12a1{2},exampleINPUT.t12a2{2},exampleINPUT.t12a3{2},exampleINPUT.t12a4{2},...
                          exampleINPUT.t12a5{2},exampleINPUT.t12a6{2},exampleINPUT.t12a7{2},exampleINPUT.t12a8{2});
[M12, all_samples12] = MCMCInference(G, F, E, TransName, mix_time, ...
                                                  num_samples, sampling_interval, A0);
sumabs(M12(1).val - exampleOUTPUT.t12o1{2}(1).val)