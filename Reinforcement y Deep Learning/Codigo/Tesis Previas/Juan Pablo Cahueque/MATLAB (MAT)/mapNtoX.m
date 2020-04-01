function [ real_coord ] = mapNtoX(pos,gridsize,step )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    real_coord = pos.*(gridsize/step)-gridsize/2;

end

