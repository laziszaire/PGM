function logO = logOi(Di,mus,sigmas)
% ����Oi variable������log����, varibale ~ N(mus(i),sigmag(i))
% log(y)+log(x)+log(alpha)

num_yxalpha = numel(mus);
logO = 0;
for i = 1:num_yxalpha
    logO = logO+ lognormpdf(Di(i),mus(i),sigmas(i));
end
end