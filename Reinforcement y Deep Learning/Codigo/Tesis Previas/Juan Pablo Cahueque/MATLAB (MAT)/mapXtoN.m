function [ mapped_pos ] = mapXtoN( pos,gridsize,step )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    mapped_pos = [round((pos(1)+gridsize/2)*(step/gridsize)),round((pos(2)+gridsize/2)*(step/gridsize))];

end

