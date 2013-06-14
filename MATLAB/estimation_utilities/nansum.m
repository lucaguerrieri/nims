function [sumvec] = sumnan(mat,direc)


if ~exist('direc')
    direc = 1;
end

mat(isnan(mat)) = 0;

sumvec = sum(mat,direc);

