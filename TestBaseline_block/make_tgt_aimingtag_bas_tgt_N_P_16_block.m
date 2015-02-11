function make_tgt_aimingtag_bas_tgt_N_P_o(VR)
close all;
% target file format
%   column      function
%   1           Visual rotatiton angle
%   2           Via point movement (no=0, yes=1)
%   3 and 4     Target coordinates
%   5 and 6     Via point coordinates
%   7           Visual feedback (no=0, yes=1). if 0, make column #8 = 98 or 99
%   8           Movement type (any value ~= 98 or 99, used in parsing/post-processing)
%   9           Wait time (in addition to the minimum of 0.25s)
%   10          Show the experiment a, or c
%   11          Show the aimingtarget fixed in baseline block
%   12          Show the aimingtarget fixed in training block
%   13          shown the cursor rataion when rotated
%   14          show the aimingtarget of selection
%   15          show the sign of test experiment on Baseline block 1:baseline 0: no

% add a return to center movement to each set and then
% terminate with a line of 9 zeros (0 0 0 0 0 0 0 0 0)

mov_len = 354; % movement length in pixels, 100 pixels per inch
start_x = 950;
start_y = 600;
base_block=800;
%% Baseline  (total 100 trials)
%introdcue the rotation to stimulate the subject to move toward to the aiming target
%% set the cursor target position without cursor rotation at these trials
k=1;k1=1;
for i=1:1:2*base_block
    if find(mod(i,10)~=2)
        Num1(k)=i;
        k=k+1;
    end
    if find(mod(i,10)==2)
        Num2(k1)=i;
        k1=k1+1;
    end
end
Num_N=[1:2 11:12 21:22 31:32 41:42 51:52 61:62 71:72 81:82 91:92 101:102 111:112 121:122 131:132 141:142 151:152];
Num3=Num2(Num_N);
Num_noRT=[Num1 Num3];             %%select the trials without cursor rotation
Num_noRT=sort([Num1 Num3]);

X_T=[];
j=1;
for i=1:1:length(Num_noRT)
    if mod(Num_noRT(i),2)==0
        X_T(j)=Num_noRT(i);
        j=j+1;
    end
end

%%randomly set the position of aiming target when curosr without rotation
integ_angle_int = 0:30:180;
rep_angle=repmat(integ_angle_int,1,96);      % 7*96=672
fam_mov = length(rep_angle);
fam_mov_order = rep_angle(randperm(fam_mov));
set_aimtgt_x = start_x+mov_len*cosd(fam_mov_order); % calculate end point x
set_aimtgt_y = start_y-mov_len*sind(fam_mov_order); % calculate end point y

fam_tgt_i = repmat([VR 0 start_x start_y start_x start_y 1 750 0 666 777 0 0 0 1],2*base_block,1);
fam_tgt_i(X_T(1:end),3) = set_aimtgt_x;       % chose the trials of rotation and set its position
fam_tgt_i(X_T(1:end),4) = set_aimtgt_y;



%==========================================================================
%exceptly select the trials of cursor roation and set the targte position
aimtag_x1 = start_x+mov_len*cosd(0); % calculate end point x
aimtag_y1= start_y-mov_len*sind(0); % calculate end point y

aimtag_x2 = start_x+mov_len*cosd(30); % calculate end point x
aimtag_y2= start_y-mov_len*sind(30); % calculate end point y

aimtag_x3 = start_x+mov_len*cosd(60); % calculate end point x
aimtag_y3= start_y-mov_len*sind(60); % calculate end point y

aimtag_x4 = start_x+mov_len*cosd(90); % calculate end point x
aimtag_y4= start_y-mov_len*sind(90); % calculate end point y

aimtag_x5 = start_x+mov_len*cosd(120); % calculate end point x
aimtag_y5= start_y-mov_len*sind(120); % calculate end point y

aimtag_x6 = start_x+mov_len*cosd(150); % calculate end point x
aimtag_y6= start_y-mov_len*sind(150); % calculate end point y

aimtag_x7 = start_x+mov_len*cosd(180); % calculate end point x
aimtag_y7= start_y-mov_len*sind(180); % calculate end point y


%%set the cursor target position as a whole
cur_RT_x1=[aimtag_x1 aimtag_x3];       % 8 trails in 800 and 0 and 60 degres with same aiming target

%determin the position of cursor targt X_position
cur_RT_x2_N=[aimtag_x2 aimtag_x4];       % 24 trails in 800 and 30 and 90 degres with same aiming target
cur_RT_x3_N=[aimtag_x4 aimtag_x6];       % 24 trails in 800 and 90 and 150 degres with same aiming target
cur_RT_x2_P=[aimtag_x4 aimtag_x2];       % 24 trails in 800 and 30 and 90 degres with same aiming target
cur_RT_x3_P=[aimtag_x6 aimtag_x4];       % 24 trails in 800 and 90 and 150 degres with same aiming target

cur_RT_x4=[aimtag_x5 aimtag_x7];       % 8 trails in 800 and 120 and 180 degres with same aiming target


%determin the position of cursor targt Y_position
cur_RT_y1=[aimtag_y1 aimtag_y3];

cur_RT_y2_N=[aimtag_y2 aimtag_y4];
cur_RT_y3_N=[aimtag_y4 aimtag_y6];
cur_RT_y2_P=[aimtag_y4 aimtag_y2];
cur_RT_y3_P=[aimtag_y6 aimtag_y4];

cur_RT_y4=[aimtag_y5 aimtag_y7];

%%selet the trials of rotation from the 1-1600
k=1;
for i=1:1:2*base_block
    if find(mod(i,10)==2)
        Num(k)=i;
        k=k+1;
    end
end
Rot_ii=[3:1:10 13:1:20 23:1:30 33:1:40 43:1:50 53:1:60 63:1:70 73:1:80 83:1:90 93:1:100 103:1:110 113:1:120 123:1:130 133:1:140 143:1:150 153:1:160];
ii=Num(Rot_ii); %%select the 22-92 122-192

j=1;
Rot_M=ones(64,2)*NaN;       %128 trials for rotation
for i=1:2:length(ii)
    Rot_M(j,:)=[ii(i),ii(i+1)];
    j=j+1;
end
Ran_num=randperm(64);

Rot_cursor1_P=Rot_M(Ran_num(1:12),:);
Rot_cursor2_P=Rot_M(Ran_num(13:24),:);
Rot_cursor1_N=Rot_M(Ran_num(25:36),:);
Rot_cursor2_N=Rot_M(Ran_num(37:48),:);

Rot_cursor3=Rot_M(Ran_num(49:56),:);
Rot_cursor4=Rot_M(Ran_num(57:64),:);

%%randomly determine the position of cursor roation
for i=1:1:12
    %% Firstly CW rotation
    fam_tgt_i(Rot_cursor1_P(i,:),3)=cur_RT_x2_P;
    fam_tgt_i(Rot_cursor1_P(i,:),4)=cur_RT_y2_P;
    fam_tgt_i(Rot_cursor2_P(i,:),3)=cur_RT_x3_P;
    fam_tgt_i(Rot_cursor2_P(i,:),4)=cur_RT_y3_P;
    
    %%Firstly CCW rotation
    fam_tgt_i(Rot_cursor1_N(i,:),3)=cur_RT_x2_N;
    fam_tgt_i(Rot_cursor1_N(i,:),4)=cur_RT_y2_N;
    fam_tgt_i(Rot_cursor2_N(i,:),3)=cur_RT_x3_N;
    fam_tgt_i(Rot_cursor2_N(i,:),4)=cur_RT_y3_N;
end

for i=1:1:8
    fam_tgt_i(Rot_cursor3(i,:),3)=cur_RT_x1;
    fam_tgt_i(Rot_cursor3(i,:),4)=cur_RT_y1;
    fam_tgt_i(Rot_cursor4(i,:),3)=cur_RT_x4;
    fam_tgt_i(Rot_cursor4(i,:),4)=cur_RT_y4;
end

%%set the cursor rotation at the trials
for i=1:1:12
    fam_tgt_i(Rot_cursor1_P(i,:),1)=[30,-30];
    fam_tgt_i(Rot_cursor1_P(i,:)+1,1)=[30,-30];
    fam_tgt_i(Rot_cursor1_P(i,:),13)=[30,-30];
    fam_tgt_i(Rot_cursor1_P(i,:)+1,13)=[30,-30];
    
    fam_tgt_i(Rot_cursor2_P(i,:),1)=[30,-30];
    fam_tgt_i(Rot_cursor2_P(i,:)+1,1)=[30,-30];
    fam_tgt_i(Rot_cursor2_P(i,:),13)=[30,-30];
    fam_tgt_i(Rot_cursor2_P(i,:)+1,13)=[30,-30];
    
    fam_tgt_i(Rot_cursor1_N(i,:),1)=[-30,30];
    fam_tgt_i(Rot_cursor1_N(i,:)+1,1)=[-30,30];
    fam_tgt_i(Rot_cursor1_N(i,:),13)=[-30,30];
    fam_tgt_i(Rot_cursor1_N(i,:)+1,13)=[-30,30];
    
    fam_tgt_i(Rot_cursor2_N(i,:),1)=[-30,30];
    fam_tgt_i(Rot_cursor2_N(i,:)+1,1)=[-30,30];
    fam_tgt_i(Rot_cursor2_N(i,:),13)=[-30,30];
    fam_tgt_i(Rot_cursor2_N(i,:)+1,13)=[-30,30];
end

for j=1:1:8
    fam_tgt_i(Rot_cursor3(j,:),1)=[-30,30];
    fam_tgt_i(Rot_cursor3(j,:)+1,1)=[-30,30];
    fam_tgt_i(Rot_cursor3(j,:),13)=[-30,30];
    fam_tgt_i(Rot_cursor3(j,:)+1,13)=[-30,30];
    
    fam_tgt_i(Rot_cursor4(j,:),1)=[-30,30];
    fam_tgt_i(Rot_cursor4(j,:)+1,1)=[-30,30];
    fam_tgt_i(Rot_cursor4(j,:),13)=[-30,30];
    fam_tgt_i(Rot_cursor4(j,:)+1,13)=[-30,30];
end

%% set the cursor target position at the cursor rotation trials

bas_tgt1_int=fam_tgt_i(1:100,:);
bas_tgt2_int=fam_tgt_i(101:200,:);
bas_tgt3_int=fam_tgt_i(201:300,:);
bas_tgt4_int=fam_tgt_i(301:400,:);
bas_tgt5_int=fam_tgt_i(401:500,:);
bas_tgt6_int=fam_tgt_i(501:600,:);
bas_tgt7_int=fam_tgt_i(601:700,:);
bas_tgt8_int=fam_tgt_i(701:800,:);
bas_tgt9_int=fam_tgt_i(801:900,:);
bas_tgt10_int=fam_tgt_i(901:1000,:);
bas_tgt11_int=fam_tgt_i(1001:1100,:);
bas_tgt12_int=fam_tgt_i(1101:1200,:);
bas_tgt13_int=fam_tgt_i(1201:1300,:);
bas_tgt14_int=fam_tgt_i(1301:1400,:);
bas_tgt15_int=fam_tgt_i(1401:1500,:);
bas_tgt16_int=fam_tgt_i(1501:1600,:);

bas_a_tgt1 = [bas_tgt1_int;bas_tgt1_int(49,:);zeros(1,15)];
bas_a_tgt2 = [bas_tgt2_int;bas_tgt2_int(49,:);zeros(1,15)];
bas_a_tgt3 = [bas_tgt3_int;bas_tgt3_int(49,:);zeros(1,15)];
bas_a_tgt4 = [bas_tgt4_int;bas_tgt4_int(49,:);zeros(1,15)];
bas_a_tgt5 = [bas_tgt5_int;bas_tgt5_int(49,:);zeros(1,15)];
bas_a_tgt6 = [bas_tgt6_int;bas_tgt6_int(49,:);zeros(1,15)];
bas_a_tgt7 = [bas_tgt7_int;bas_tgt7_int(49,:);zeros(1,15)];
bas_a_tgt8 = [bas_tgt8_int;bas_tgt8_int(49,:);zeros(1,15)];
bas_a_tgt9 = [bas_tgt9_int;bas_tgt9_int(49,:);zeros(1,15)];
bas_a_tgt10 = [bas_tgt10_int;bas_tgt10_int(49,:);zeros(1,15)];
bas_a_tgt11 = [bas_tgt11_int;bas_tgt11_int(49,:);zeros(1,15)];
bas_a_tgt12 = [bas_tgt12_int;bas_tgt12_int(49,:);zeros(1,15)];
bas_a_tgt13 = [bas_tgt13_int;bas_tgt13_int(49,:);zeros(1,15)];
bas_a_tgt14 = [bas_tgt14_int;bas_tgt14_int(49,:);zeros(1,15)];
bas_a_tgt15 = [bas_tgt15_int;bas_tgt15_int(49,:);zeros(1,15)];
bas_a_tgt16 = [bas_tgt16_int;bas_tgt16_int(49,:);zeros(1,15)];

%% Combine all movements into a single target set
all_tgt_ = {bas_a_tgt1;bas_a_tgt2;bas_a_tgt3;bas_a_tgt4;bas_a_tgt5;bas_a_tgt6;bas_a_tgt7;bas_a_tgt8;bas_a_tgt9;bas_a_tgt10;bas_a_tgt11;bas_a_tgt12;bas_a_tgt13;bas_a_tgt14;bas_a_tgt15;bas_a_tgt16};
%% Write tgt files
if sign(VR)>0, ch = 'P'; else ch = 'N'; end
f_prefix = ['vmr_aimingtag_',ch];
if ~isdir([pwd '\tgt_files_aimingtag_base16\']), mkdir([pwd '\tgt_files_aimingtag_base16\']);end
for i = 1:length(all_tgt_)
    dlmwrite([pwd,'\tgt_files_aimingtag_base16\',f_prefix,char('a'+i-1),'.tgt'],all_tgt_{i},' ');
end
%% Plot target files

f_prefix = ['vmr_aimingtag_',ch];
T = [];
B = [];
for i = 1:length(all_tgt_)
    F = load([pwd,'\tgt_files_aimingtag_base16\',f_prefix,char('a'+i-1),'.tgt'],'r');
    T = [T;F(2:end-1,:)];
    B = [B;1;0*F(3:end-1,1)];
end;

figure; plot(T(:,[1 9])); hold on;plot(60*B,'r');

return;