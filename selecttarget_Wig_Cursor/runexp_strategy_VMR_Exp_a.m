start_x = 950;
start_y = 600;
mov_len = 354;

%==========================================================================
theta=3*randn(70,1);
xstart_1=xstart+mov_len*cosd(theta);
ystart_1=xstart+mov_len*sind(theta);


Rot_sign=sign(randn(10,1));
Train_tgt= repmat([VR 0 start_x start_y-mov_len start_x start_y 1 750 0 666 0 888 0 999;VR 0 start_x start_y start_x start_y 1 750 0 666 0 888 0 999],210,1);    %%all the movement including the outward and inward
VR_angle_1=NaN(1,60);VR_angle_2=NaN(1,10);VR_angle_3=NaN(1,120);VR_angle_4=NaN(1,20);
 deta_angle1=0.5; deta_angle2=-0.25; 
 
 