function res = distribute_EC(N,r)
% makes sure there are exactly r*N EC in 1:N and no two consecutive EC. 0<r<1

max_dist = round(1/r)+1;

tmp = [];
while length(tmp)~=round(r*N)
    ii = 1;
    count = 1;
    x = 1;
    tmp = [];
    while ii<=N
        R = rand(1);
        if (count>max_dist) || (R<r)
            tmp(x) = ii;
            x = x+1;
            ii = ii+1;
            count = 1;
        end;
        count = count+1;
        ii = ii+1;
    end;
end;
res = tmp;

return