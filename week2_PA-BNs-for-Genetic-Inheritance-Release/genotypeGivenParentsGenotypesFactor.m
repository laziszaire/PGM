function genotypeFactor = genotypeGivenParentsGenotypesFactor(numAlleles, genotypeVarChild, genotypeVarParentOne, genotypeVarParentTwo)
% This function computes a factor representing the CPD for the genotype of
% a child given the parents' genotypes.

% THE VARIABLE TO THE LEFT OF THE CONDITIONING BAR MUST BE THE FIRST
% VARIABLE IN THE .var FIELD FOR GRADING PURPOSES

% When writing this function, make sure to consider all possible genotypes 
% from both parents and all possible genotypes for the child.

% Input:
%   numAlleles: int that is the number of alleles
%   genotypeVarChild: Variable number corresponding to the variable for the
%   child's genotype (goes in the .var part of the factor)
%   genotypeVarParentOne: Variable number corresponding to the variable for
%   the first parent's genotype (goes in the .var part of the factor)
%   genotypeVarParentTwo: Variable number corresponding to the variable for
%   the second parent's genotype (goes in the .var part of the factor)
%
% Output:
%   genotypeFactor: Factor in which val is probability of the child having 
%   each genotype (note that this is the FULL CPD with no evidence 
%   observed)

% The number of genotypes is (number of alleles choose 2) + number of 
% alleles -- need to add number of alleles at the end to account for homozygotes

genotypeFactor = struct('var', [], 'card', [], 'val', []);

% Each allele has an ID.  Each genotype also has an ID.  We need allele and
% genotype IDs so that we know what genotype and alleles correspond to each
% probability in the .val part of the factor.  For example, the first entry
% in .val corresponds to the probability of having the genotype with
% genotype ID 1, which consists of having two copies of the allele with
% allele ID 1, given that both parents also have the genotype with genotype
% ID 1.  There is a mapping from a pair of allele IDs to genotype IDs and 
% from genotype IDs to a pair of allele IDs below; we compute this mapping 
% using generateAlleleGenotypeMappers(numAlleles). (A genotype consists of 
% 2 alleles.)

[allelesToGenotypes, genotypesToAlleles] = generateAlleleGenotypeMappers(numAlleles);

% One or both of these matrices might be useful.
%
%   1.  allelesToGenotypes: n x n matrix that maps pairs of allele IDs to 
%   genotype IDs, where n is the number of alleles -- if 
%   allelesToGenotypes(i, j) = k, then the genotype with ID k comprises of 
%   the alleles with IDs i and j
%
%   2.  genotypesToAlleles: m x 2 matrix of allele IDs, where m is the 
%   number of genotypes -- if genotypesToAlleles(k, :) = [i, j], then the 
%   genotype with ID k is comprised of the allele with ID i and the allele 
%   with ID j

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INSERT YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
genotypeFactor.var = [genotypeVarChild,genotypeVarParentOne,genotypeVarParentTwo];
numGenotypes = size(genotypesToAlleles,1);
genotypeFactor.card = [numGenotypes,numGenotypes,numGenotypes];
% Fill in genotypeFactor.var.  This should be a 1-D row vector.
% Fill in genotypeFactor.card.  This should be a 1-D row vector.


% Replace the zeros in genotypeFactor.val with the correct values.
genotypeFactor.val = zeros(1, prod(genotypeFactor.card));
index = 1:prod(genotypeFactor.card);
assignments = IndexToAssignment(index,genotypeFactor.card);
for ri = 1:size(assignments,1)
    p = pgc(assignments(ri,:),genotypesToAlleles,allelesToGenotypes);
    genotypeFactor = SetValueOfAssignment(genotypeFactor, assignments(ri,:), p);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
end

function p = pgc(assignments,genotypesToAlleles,allelesToGenotypes)
%计算一条assignment的概率，p(子代|父母代)

%geno
childgeno = assignments(1);
parentsgeno = assignments(2:end);
parent1geno = parentsgeno(1);
parent2geno = parentsgeno(2);

%allele
p1allele = genotypesToAlleles(parent1geno,:);
p2allele = genotypesToAlleles(parent2geno,:);
callele = genotypesToAlleles(childgeno,:);

%
pc_allele = possible_allele(p1allele,p2allele);%父母可能生成的子代基因型
cgeno = fallelesToGenotypes(callele,allelesToGenotypes);% scalar e.g, aaA
pc_geno = fallelesToGenotypes(pc_allele,allelesToGenotypes);% vector,n*1 e.g., [Aaa,aaA,aAa,aaa]
a = cgeno == pc_geno;
p = sum(a)/numel(a);
end

function geno =  fallelesToGenotypes(alleles,allelesToGenotypes)

n = size(alleles,1);
geno = zeros(n,1);
for i = 1:n
geno(i) = allelesToGenotypes(alleles(i,1),alleles(i,2));
end
end

function pa = possible_allele(p1allele,p2allele)
%给的父母的基因型，子代可能的基因型

e = 1;
n = numel(p1allele);
pa = zeros(n*n,2);
for i=1:n
    for j = 1:n
    pa(e,:) = [p1allele(i),p2allele(j)];
    e = e+1;
    end
end
end

