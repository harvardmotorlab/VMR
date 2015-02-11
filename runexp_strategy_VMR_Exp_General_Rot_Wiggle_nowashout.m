
function runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_file_name_prefix,tgt_set)


%%this file does not save the angle of move_out just save the x_, y_ positioin
screenNumber = 0;

% Circle return is only on no feedback returns
% Main screen is on the right, secondary(tester) screen on the left
% For new comp with new psychtoolbox, flipped monitor and tablet
% target locations need to be changed
% getpoints function should also be changed
% for the flipped monitor
% AD mod: add larger reward region around target and make speed reward
% adaptive ar 50% of the last 20 movements for AD patient experiments

Screen('Preference','EmulateOldPTB',0);
Screen('Preference','TextRenderer',0);
Screen('Preference','DefaultFontSize',22);

load ting
load glass
ting=ting'; %#ok<NODEF>
ting=ting(:,1:17640);
glass=glass'; %#ok<NODEF>

psychtest=load([tgt_file_name_prefix,tgt_set,'.tgt']); % load target file

%fullwindow = [0 0 3800 1080];
% Open a window and paint the background black
%[win, winrect] = Screen('OpenWindow', screenNumber, [0 0 0]*255,fullwindow); two screens
[win, winrect] = Screen('OpenWindow', screenNumber, [0 0 0]*255);
usetablet = 1;
if  usetablet
    WinTabMex(0, win); %Initialize tablet driver, connect it to 'win'
end
ListenChar(2)

% Monitor Settings
resx=winrect(3);
resy=winrect(4);
xc=resx-950;      % center pixel n x, show on the first monitor
yc=resy-600;      % center pixel in y
rotx=xc;        % center of rotation x coord
roty=yc;        % center of rotation y coord
screenoffset=[resx resy resx resy];

%Program Constants
scaling=1;        % scaling of cursor display to hand movements, cursor moves scaling times as far as hand
target_time=.55;     % time of movement (includes timeinside); actual movement time is target_time-timeinside
wait_time=.0005;      % time in circle before target appears
wait_time2=0;      % wait time after target appears, to avoid false starts
timeinside=.3;      % time in the end target at below vel threshold until movement ends
timeinside_gen=.4;
Curinsidestart=.2;      % time in the end target at below vel threshold until movement ends
vstart_thresh=250;       % pixels per second 6.35 cm/s in hand space
vstop_thresh=300;
singletravthresh=354;   % movement must be at least 7.6 cm long  (control the distance from the start point of every trial)
singletravthresh_NA=200;
startvisthresh=40;      % pixels around center start      (control the size of circle in which cursor will appear)
ydist=20;               % spacing of entries on experimenter's monitor
maxsingletime=100;
maxvelrange=[.4 2];
reward_scale=1;         %3; % scaling factor for reward circle around the end point

% List of movement types
vflist=[1 2 3 4 19 20 25 26];
ptlist=[5 6 7 8 17 18 27 28];
dblist=[9 10 11 12 13 14 15 16 21 22 23 24];
nfbret=[98 99];
nfbout=199;
fbret=0;
sign_Num=1;
% Program Colors
startcol_exp=[0 0 0];        %movement start color__black for experiment control
startcol_user=[255 0 255];   %movement start color__purple for user control

waitcol=[255 255 0];   %wait for movemnt as yellow

goodcol = [0 255 0];
slowcol = [0 0 255];
fastcol = [255 0 0];
nextcol = slowcol;
no_vfb_col=[51 153 255];

cursorcol=[255 255 255];            %cursor color in experiment control screen_ white
nofeedcursorcol=[255 0 255];
% ATGT_selection_dotcol=[0 255 255];   %many dot aiming target color_ light white
ATGT_selection_dotcol=[255 0 0];
sel_aimingtargcol=[255 0 0];       %show aiming target with  red color        orange color([255 97 0])


%Texture Definitions showing the circle of target or cursor
CTGTsize=15;                   % radius of cursor target used for determine wheter the cursor arrive in the circle and maketext of cursor target
circlesize=CTGTsize;
startcirclesize=10;            % radius of starting point used for determine wheter the cursor arrive in the circle and maketext of starting point

cursorsize=5;                  % radius of cursor
ATGT_selection_dot_size=2;     % radius of many aiming target

ATGT_outer_size=25;
ATGT_inner_size=20;
targetsize = ATGT_outer_size;    % radius of the select aiming target

circletext=Screen('MakeTexture', win, 255*Circle(CTGTsize));                %cursor target
cursortext=Screen('MakeTexture', win, 255*Circle(cursorsize));              %cursor
ATGT_selection_dot_text=Screen('MakeTexture', win, 255*Circle(ATGT_selection_dot_size));  %aiming tgt selection dots

%show the selected aiming target as a hollow
AT_outer_circle = Circle(ATGT_outer_size);
AT_hollow_circle = AT_outer_circle;
iiq=ATGT_outer_size-ATGT_inner_size+[1:2*ATGT_inner_size];
AT_hollow_circle(iiq,iiq) = AT_hollow_circle(iiq,iiq) - Circle(ATGT_inner_size);
targtext=Screen('MakeTexture', win, 255*AT_hollow_circle);                  % make rge texture of aiming target

% Target File Modification (due to screen differences),This part has to
% be changed to modulate the position
philist=psychtest(:,1);
x1list=resx-psychtest(:,3);   %psychtest(:,3)and psychtest(:,4)are the position displaying in target file
y1list=resy-psychtest(:,4);
vis_feedback=psychtest(:,7);
movement_type=psychtest(:,8);
mark_endpoint=psychtest(:,9);
exp_type = psychtest(:,10);               %psychtest(:,10) is the position of aiming target in the training block
aim_fix_base = psychtest(:,11);           %psychtest(:,11) is the mark for different process of red ring:  777 mean  red ring is fixed  0
cursor_nofeedback = psychtest(:,12);          %psychtest(:,12) is the mark for training, 888 means red ring is selected by subjected
aim_rotation = psychtest(:,13)*pi/180;    %psychtest(:,13) is the position of aiming target in the training block
aim_selection = psychtest(:,14);          %psychtest(:,14) is the sign of selecting aiming target in the training

x1list_base=resx-psychtest(:,15);   %psychtest(:,15)and psychtest(:,16)are the position red ring shown in baseline
y1list_base=resy-psychtest(:,16);


wait_time_before_movement=mark_endpoint;
maxtrialnum=max(movement_type(movement_type<90));

% Variables that store data
MAX_SAMPLES=2e5; %about 100 minutes @ 120Hz = 100*60*120
timevec = zeros(MAX_SAMPLES,1);
thePoints=zeros(MAX_SAMPLES,2);
tabletPoints=zeros(MAX_SAMPLES*2,9); %double the samples since the tablet is sampled @ 200Hz
total_vel=zeros(MAX_SAMPLES,1);
total_displacement=zeros(MAX_SAMPLES,1);
deltax=zeros(MAX_SAMPLES,1);
deltay=zeros(MAX_SAMPLES,1);
timeincirc=zeros(size(psychtest,1),5);
allmaxvel=nan(size(psychtest,1),1);
testpositions=nan(size(psychtest,1),1);

%save the data of aiming angle
aimingtagpos_x_out=zeros(size(psychtest,1),1);  %save the position of the selected aiming targets
aimingtagpos_y_out=zeros(size(psychtest,1),1);  %every block should save the position; 5 represents five blocks of experiments

cursor_position=[];                        %save the position of cursor when move
cursor_position_1=[];

% Program variable predeclaration
aiming_flag = 0;
jumpthegun=0;
hitcirc_count=1;
insidecircle=0;
outsidecircle=0;
started=0;
ismoving=0;
firsttimeout=0;
ii=2;
t=1;
num=1;
k=15;
tab_k=15;
% Tablet Stuff
tablet_x_scale = 1/25.4;
tablet_x_offset = -19.2*2540;
tablet_y_scale = -1/25.4;
tablet_y_offset = 12*2540;

if usetablet,
    WinTabMex(2); %Empties the packet queue in preparation for collecting actual data
end

%define the position of starting circle and finishing circle
xstart=x1list(1);       % x and y locations of starting circle
ystart=y1list(1);
xloc1= x1list(ii);      % x and y locations of finishing circle(cursor target)
yloc1= y1list(ii);
centercircle_x1=xloc1;
centercircle_y1=yloc1;
startloc=[xstart-startcirclesize ystart-startcirclesize xstart+startcirclesize ystart+startcirclesize];                   %the position of start circle
p1loc=[centercircle_x1-circlesize centercircle_y1-circlesize centercircle_x1+circlesize centercircle_y1+circlesize];      %the position of cursor target

startTime = 0;
tic;
t_last_trial = GetSecs;
movement_start_time=startTime;
t_a=startTime;


% Hide the mouse cursor.
[~, ~, buttons]=GetMouse;
HideCursor;
SetMouse(xc,yc);       %determine the position of cursor at the first time which should be considered

%Define Arrow Keys
uparrow=38;
downarrow=40;
enternarrow=13;
space=32;

%%give different move_direction of right or left key in move_back or
%%move_out and they interchange the value

rightarrow_out=39;
leftarrow_out=37;
curtime=toc;
%angle for which testcursor starts
targetangle=atan((yloc1-ystart)/(xloc1-xstart));         %keep the angle between aiming target and start point is 90 degree  when move_out
%testangle=(2*round(rand(1))-1)*pi/2+targetangle;        % +/- 90,the transferation between the main screen and the less improtant screen
testangle_out=targetangle;                               %+pi/2 cursor displays at 180, 0: cursor displays at 90, -90: cursor displays at 0
testangle_back=atan((ystart-yloc1)/(xloc1-xstart));      %keep the angle between aiming target and start point is 90 degree  when move_back

testangle_out=0;                                         %Mariuce change the recarliation this value changing with different cursor target position

curkey=0;
curkey1=0;
firstpress=1;
teststarttime=curtime;

movelen=sqrt((x1list(1)-x1list(2))^2+(y1list(1)-y1list(2))^2);              %the radius of the circle
testcirclepath=movelen*[cos((0:180)/180*2*pi);sin((0:180)/180*2*pi)];       %the postion of many aiming target
testcirclepath2=repmat([x1list(1);y1list(1)],1,length(testcirclepath)*2-1 )+testcirclepath(:,sort([1 2:length(testcirclepath) 2:length(testcirclepath)]));
targetpost1=zeros(180,4);
keyaim = 1; % determine whether we select target via keyboard or mouse.
if usetablet,
    WinTabMex(2); %Empties the packet queue in preparation for collecting actual data
end
WaitSecs(0.25); % just in case wait
instant_showingtag=1;

%move the initial position of cursor to cursor target
SetMouse(xc,yc);
[mx_init, ~, ~] = GetMouse;

while ~any(buttons(2)) &&ii<length(philist)    %~any(buttons(2:end)), the button of corsor is not pressed,the button is 3 dim vector[~,~,~]which respresents left, mid and right button of corsor. if the rigjt botton is not pressed, the code in which is goning on
    k=k+1;
    Screen('Flip',win,0,0,1);
    %=========================================================================
    %     Here, GetMouse is only used so we know if a mouse button has been
    %     pressed. If so, the while loop will exit in the next run and the
    %     program will return to the command window.
    [~, ~, buttons] = GetMouse;
    [keyIsDown,keySecs,keyCode] = KbCheck;
    %     curkey1=find(keyCode);
    if usetablet,
        % Read information from the tablet
        pkt = WinTabMex(5);
        while ~isempty(pkt)
            tabletPoints(tab_k,1:8) = pkt(1:8)';
            tab_k = tab_k+1;
            pkt = WinTabMex(5);
        end
        mX = (tabletPoints(tab_k-1,1)-tablet_x_offset)*tablet_x_scale;
        mY = (tabletPoints(tab_k-1,2)-tablet_y_offset)*tablet_y_scale;
    end
    thePoints(k,:) = [mX mY]; % record full precision points of the botton in corsor
    curtime=toc;
    timevec(k)=curtime-startTime;
    
    % location to display cursor
    % rotate xy centers around middle of screen coords at (0,0)
    [dx dy]=rotatexy(mX-rotx,-(mY-roty),philist(ii));
    dx = scaling*dx+rotx;     % expand screen shift it back
    dy = -scaling*dy+roty;     % shift it back
    
    %Draw the sprite at the new location.
    %cursor=[min(max(dx-cursorsize,resx/2),resx-10)
    %below line is the original code line
    %cursor=[min(max(dx-cursorsize,resx/2),resx-10) min(max(dy-cursorsize,0),resy-10) max(min(dx+cursorsize,resx),resx/2+10) max(min(dy+cursorsize,resy),10)];
    cursor=[dx-cursorsize dy-cursorsize dx+cursorsize dy+cursorsize];          % if the cursor is wrong, this line may be the reason
    %%the preparetion of the circle during the reaching movement
    cursor_position(ii-1,1)=dx;
    cursor_position(ii-1,2)=dy;
    cursor_position_1(k,1)=dx;
    cursor_position_1(k,2)=dy;
    
    %==========================================================================================================================================================================
    if started==0    % inside start circle wait time (not yet started)
        if ~ismember(movement_type(ii),nfbret)  % if movement is not a no feedback return (feedback return is the target will appear on the screen that subject used)
            % yellow circle at start location
            Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S" instead of the circle
            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
        else % movement is a no feedback return     (subject will not see the feedback of target)
            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
        end
        
        if sqrt((dx-xstart)^2+(dy-ystart)^2)>startcirclesize     % cursor left start circle before start, play the glass
            
            if firsttimeout==1
                if sqrt((dx-xstart)^2+(dy-ystart)^2)>circlesize && ~ismember(movement_type(ii),nfbret)
                    Snd('Play',glass,fs1);
                end
                firsttimeout=0;
            end
            movement_start_time=curtime;
            t_a=movement_start_time;
        end
        
        if (curtime >= t_a + wait_time && sqrt((dx-xstart)^2+(dy-ystart)^2)<startcirclesize ) || ismember(movement_type(ii),nfbret)  % in circle for long enough
            firsttimeout=1;
            started=1;
            t_a=curtime;
            if ~ismember(movement_type(ii),nfbret)  % if it isn't a no feedback return
                Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S"
                Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],startcol_user);
                Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],waitcol);
                Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],waitcol);
            else
                Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
            end
            if ismember(movement_type(ii),nfbret)
                movement_start_time=curtime;
                ismoving=1;
            end
        end
    else    % wait time is over
        % for jump the guns, no jump the gun for nfb returns
        if curtime <= t_a + wait_time2 && ~ismember(movement_type(ii),nfbret)
            Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],waitcol);
            Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],waitcol);
            Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S"
            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],startcol_user);
            
            if sqrt((dx-xstart)^2+(dy-ystart)^2)>circlesize     % cursor left old target circle
                if firsttimeout==1 && (movement_type(ii)~=99)
                    firsttimeout=0;
                    Snd('Play',glass,fs1);
                    disp('??')
                    jumpthegun=1;
                end
                movement_start_time=curtime;
                t_a=curtime;
            elseif sqrt((dx-xstart)^2+(dy-ystart)^2)>startcirclesize
                movement_start_time=curtime;
                t_a=curtime;
            else
                jumpthegun=0;
            end
            % jump the gun time is over
        else
            firsttimeout=1;
            jumpthegun=0;
            
            for i=1:180
                targetpost1(i,:)=[testcirclepath(1:2,i)', testcirclepath(1:2,i)'] + [xstart ystart xstart ystart] + ATGT_selection_dot_size*[-1,-1, 1, 1];
            end
            
            if tgt_set~='f'&&tgt_set~='g'&&tgt_set~='l'&&tgt_set~='m'&&tgt_set~='r'&&tgt_set~='s'
                %%show the aiming target after the cursor reaches the "S", this block is aiming target without being selected by subjects
                if (tgt_set=='c'||tgt_set=='d')&&(cursor_nofeedback(ii)~=0)                                    %if code used for test the baseline block, need to comment this line
                    %baseline block of exp with fixed aimingtarget
                    if aim_fix_base(ii)==777
                        cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                        if mod(ii,2)==0&&philist(ii)==0
                            aim_tgt_x_out=xstart+movelen*cos(cursor_tgt_angle);
                            aim_tgt_y_out=ystart+movelen*sin(cursor_tgt_angle);
                            testcursor_out=[aim_tgt_x_out-targetsize aim_tgt_y_out-targetsize aim_tgt_x_out+targetsize aim_tgt_y_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                        elseif mod(ii,2)==0&&philist(ii)~=0
                            aim_tgt_x_out=xstart+movelen*cos(aim_rotation(ii)+cursor_tgt_angle);
                            aim_tgt_y_out=ystart+movelen*sin(aim_rotation(ii)+cursor_tgt_angle);
                            testcursor1_out=[aim_tgt_x_out-targetsize aim_tgt_y_out-targetsize aim_tgt_x_out+targetsize aim_tgt_y_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                        end
                    end
                    %%save the data after experiment
                    if mod(ii,2)==0
                        aimingtagpos_x_out(ii-1)=aim_tgt_x_out;
                        aimingtagpos_y_out(ii-1)=aim_tgt_y_out;
                    end
                elseif ((tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&&(cursor_nofeedback(ii)~=0))  %%insert 3 trials in all training block
                      
                    cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                    %%load the aiming target position of last trial
                    if ~aiming_flag && (mod(ii,2)==0)
                        if (tgt_set=='h')&& (ii==2||ii==26)
                            testangle_out=cursor_tgt_angle;
                        elseif ii==2&&tgt_set=='e'
                            testangle_out=0;                                   %if the cursor has relative position with target, used this line code
                        elseif ii==2&&(tgt_set=='i'|| tgt_set=='j'||tgt_set=='n')     % download the position of aiming target in last block
                            load('aimingtag_out.mat')
                            testangle_out=testangle_out;
                        end
                        aiming_flag = 1;
                    end
                    %%=========================================================
                    if  tgt_set=='h'&&aim_selection(ii)~=999
                        cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                        if  mod(ii,2)==0  %show the aiming target when it is fixed at 30 or -30
                            testcursorx_out=xstart+movelen*cos(aim_rotation(ii)+cursor_tgt_angle);
                            testcursory_out=ystart+movelen*sin(aim_rotation(ii)+cursor_tgt_angle);
                            testcursor1_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                            aimingtagpos_x_out(ii-1)=testcursorx_out;
                            aimingtagpos_y_out(ii-1)=testcursory_out;
                        end
                    elseif aim_selection(ii)==999
                        if mod(ii,2)==0
                            while ~any(curkey1==uparrow) && curkey~=1
                                [keyIsDown,keySecs,keyCode] = KbCheck;
                                [mx, my, buttons] = GetMouse;
                                if keyaim % if using key to aim
                                    %decide the changing angle of the moving cursor
                                    %===========================================================
                                    if keyIsDown
                                        if firstpress==1
                                            firstpresstime=keySecs;
                                            cursorspeed=.001;
                                        else
                                            timepress=keySecs-firstpresstime;
                                            if timepress<.1
                                                cursorspeed=.001;
                                            else
                                                cursorspeed=min(3*timepress/100,1.5);
                                            end
                                        end
                                        firstpress=0;
                                        %=============================================================
                                        %decide the position of the pressed key
                                        if sqrt((dx-xstart)^2+(dy-ystart)^2)<startcirclesize ||sqrt((dx-xstart)^2+(dy-ystart)^2)<circlesize&&curtime>Curinsidestart    % cursor left start circle or target
                                            curkey1=find(keyCode);
                                        end
                                        if buttons(1,3)==1
                                            curkey1=0;
                                        end
                                        if curkey1 == uparrow
                                            curkey1=uparrow;
                                        elseif curkey1 == leftarrow_out
                                            testangle_out=testangle_out-cursorspeed;
                                        elseif curkey1 == rightarrow_out
                                            testangle_out=testangle_out+cursorspeed;
                                        end
                                    else
                                        firstpress=1;
                                    end
                                else % if using mouse to select the aiming target
                                    displ=(mx-mx_init)/movelen;
                                    testangle=displ + pi/2;
                                end
                                cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                                cursor_tgt_angle_base = atan2( diff(y1list_base(ii-1:ii)), diff(x1list_base(ii-1:ii)) );
                                
                                if tgt_set=='e'
                                    testcursorx_out=xstart+movelen*cos(testangle_out+cursor_tgt_angle_base );
                                    testcursory_out=ystart+movelen*sin(testangle_out+cursor_tgt_angle_base );     %%red ring shown in the equal division point every time
                                else
                                    testcursorx_out=xstart+movelen*cos(testangle_out);
                                    testcursory_out=ystart+movelen*sin(testangle_out);                                %keep the position selected by the subject
                                end
                                
                                testcursor_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                                Screen('DrawTexture', win, targtext,[],testcursor_out,[],[],[],sel_aimingtargcol);
                                Screen('DrawTexture', win, targtext,[],screenoffset-testcursor_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                                %show the aiming targets
                                for i=1:180
                                    targetpostion=targetpost1(i,:);
                                    Screen('DrawTexture', win, ATGT_selection_dot_text,[],targetpostion,[],[],[],ATGT_selection_dotcol);
                                    Screen('DrawTexture', win, ATGT_selection_dot_text,[],screenoffset-targetpostion(1,[3,4,1,2]),[],[],[],ATGT_selection_dotcol);
                                end
                                %%display the cursor target when select the aiming targets
                                Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S"
                                Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
                                Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],goodcol);
                                Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],goodcol);
                                %==============================================================
                                %display the cursor when subjects select the aiming targets
                                if usetablet,
                                    % Read information from the tablet
                                    pkt = WinTabMex(5);
                                    while ~isempty(pkt)
                                        tabletPoints(tab_k,1:8) = pkt(1:8)';
                                        tab_k = tab_k+1;
                                        pkt = WinTabMex(5);
                                    end
                                    mX = (tabletPoints(tab_k-1,1)-tablet_x_offset)*tablet_x_scale;
                                    mY = (tabletPoints(tab_k-1,2)-tablet_y_offset)*tablet_y_scale;
                                end
                                thePoints(k,:) = [mX mY];                               % record full precision points of the botton in corsor location to display cursor
                                [dx dy]=rotatexy(mX-rotx,-(mY-roty),philist(ii));       % rotate xy centers around middle of screen coords at (0,0)
                                dx = scaling*dx+rotx;                                   % expand screen shift it back
                                dy = -scaling*dy+roty;                                  % shift it back
                                cursor=[dx-cursorsize dy-cursorsize dx+cursorsize dy+cursorsize];       %Draw the sprite at the new location.
                                Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                                Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],cursorcol);
                                Screen('Flip',win,0,0,1)
                            end
                            %show the selected aiming target
                            testcursor1_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                            %%save the aiming target position when subject selectthe aiming target
                            aimingtagpos_x_out(ii-1)=testcursorx_out;
                            aimingtagpos_y_out(ii-1)=testcursory_out;
                        end
                        if ii==length(x1list)-2
                            savefile = 'aimingtag_out.mat';
                            save(savefile, 'testcursorx_out', 'testcursory_out','testangle_out');
                        end
                    end
                end
            end
            % %%======================================================
            %%general learning block with selecting aiming target
            if  (tgt_set=='g'||tgt_set=='l'||tgt_set=='s')||((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)==0))
                if ((tgt_set=='c'||tgt_set=='d')&& (cursor_nofeedback(ii)==0))
                    if aim_fix_base(ii)==777
                        cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                        if mod(ii,2)==0&&philist(ii)==0
                            aim_tgt_x_out=xstart+movelen*cos(cursor_tgt_angle);
                            aim_tgt_y_out=ystart+movelen*sin(cursor_tgt_angle);
                            testcursor_out=[aim_tgt_x_out-targetsize aim_tgt_y_out-targetsize aim_tgt_x_out+targetsize aim_tgt_y_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                        elseif mod(ii,2)==0&&philist(ii)~=0
                            aim_tgt_x_out=xstart+movelen*cos(aim_rotation(ii)+cursor_tgt_angle);
                            aim_tgt_y_out=ystart+movelen*sin(aim_rotation(ii)+cursor_tgt_angle);
                            testcursor1_out=[aim_tgt_x_out-targetsize aim_tgt_y_out-targetsize aim_tgt_x_out+targetsize aim_tgt_y_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                        end
                    end
                    %%save the data after experiment
                    if mod(ii,2)==0
                        aimingtagpos_x_out(ii-1)=aim_tgt_x_out;
                        aimingtagpos_y_out(ii-1)=aim_tgt_y_out;
                    end
                end
                if (tgt_set=='g'||tgt_set=='l'||tgt_set=='s')||((tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)==0))
                    
                    if ~aiming_flag && (mod(ii,2)==0)
                        if ii==2&&((tgt_set=='k'||tgt_set=='o'||tgt_set=='p'|| tgt_set=='q'))  % download the position of aiming target in last block
                            load('aimingtag_out.mat')
                            testangle_out=testangle_out;
                        end
                        aiming_flag = 1;
                    end
                    if mod(ii,2)==0
                        while ~any(curkey1==uparrow) && curkey~=1
                            [keyIsDown,keySecs,keyCode] = KbCheck;
                            [mx, my, buttons] = GetMouse;
                            if keyaim % if using key to aim
                                %decide the changing angle of the moving cursor
                                %===========================================================
                                if keyIsDown
                                    if firstpress==1
                                        firstpresstime=keySecs;
                                        cursorspeed=.001;
                                    else
                                        timepress=keySecs-firstpresstime;
                                        if timepress<.1
                                            cursorspeed=.001;
                                        else
                                            cursorspeed=min(3*timepress/100,1.5);
                                        end
                                    end
                                    firstpress=0;
                                    %=============================================================
                                    %decide the position of the pressed key
                                    if sqrt((dx-xstart)^2+(dy-ystart)^2)<startcirclesize ||sqrt((dx-xstart)^2+(dy-ystart)^2)<circlesize&&curtime>Curinsidestart    % cursor left start circle or target
                                        curkey1=find(keyCode);
                                    end
                                    if buttons(1,3)==1
                                        curkey1=0;
                                    end
                                    if curkey1 == uparrow
                                        curkey1=uparrow;
                                    elseif curkey1 == leftarrow_out
                                        testangle_out=testangle_out-cursorspeed;
                                    elseif curkey1 == rightarrow_out
                                        testangle_out=testangle_out+cursorspeed;
                                    end
                                else
                                    firstpress=1;
                                end
                            else % if using mouse to select the aiming target
                                displ=(mx-mx_init)/movelen;
                                testangle=displ + pi/2;
                            end
                            %%determine the moving aiming target position
                            cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                            cursor_tgt_angle_base = atan2( diff(y1list_base(ii-1:ii)), diff(x1list_base(ii-1:ii)) );
                            if tgt_set=='e'
                                testcursorx_out=xstart+movelen*cos(testangle_out+cursor_tgt_angle_base );
                                testcursory_out=ystart+movelen*sin(testangle_out+cursor_tgt_angle_base );     %%red ring shown in the equal division point every time
                            elseif  (tgt_set=='g'||tgt_set=='l'||tgt_set=='s')
                                testcursorx_out=xstart+movelen*cos(testangle_out+cursor_tgt_angle );
                                testcursory_out=ystart+movelen*sin(testangle_out+cursor_tgt_angle );     %%red ring shown in the equal division point every time
                            elseif ((tgt_set=='h'||tgt_set=='i'||tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'||tgt_set=='p'|| tgt_set=='q'))
                                testcursorx_out=xstart+movelen*cos(testangle_out);
                                testcursory_out=ystart+movelen*sin(testangle_out);
                            end
                            testcursor_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                            Screen('DrawTexture', win, targtext,[],testcursor_out,[],[],[],sel_aimingtargcol);
                            Screen('DrawTexture', win, targtext,[],screenoffset-testcursor_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                            %show the aiming targets
                            for i=1:180
                                targetpostion=targetpost1(i,:);
                                Screen('DrawTexture', win, ATGT_selection_dot_text,[],targetpostion,[],[],[],ATGT_selection_dotcol);
                                Screen('DrawTexture', win, ATGT_selection_dot_text,[],screenoffset-targetpostion(1,[3,4,1,2]),[],[],[],ATGT_selection_dotcol);
                            end
                            %%display the cursor target when select the aiming targets
                            Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S"
                            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
                            Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],slowcol);
                            Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],slowcol);
                            
                            %==============================================================
                            %display the cursor when subjects select the aiming targets
                            if usetablet,
                                % Read information from the tablet
                                pkt = WinTabMex(5);
                                while ~isempty(pkt)
                                    tabletPoints(tab_k,1:8) = pkt(1:8)';
                                    tab_k = tab_k+1;
                                    pkt = WinTabMex(5);
                                end
                                mX = (tabletPoints(tab_k-1,1)-tablet_x_offset)*tablet_x_scale;
                                mY = (tabletPoints(tab_k-1,2)-tablet_y_offset)*tablet_y_scale;
                            end
                            thePoints(k,:) = [mX mY];                               % record full precision points of the botton in corsor location to display cursor
                            [dx dy]=rotatexy(mX-rotx,-(mY-roty),philist(ii));       % rotate xy centers around middle of screen coords at (0,0)
                            dx = scaling*dx+rotx;                                   % expand screen shift it back
                            dy = -scaling*dy+roty;                                  % shift it back
                            cursor=[dx-cursorsize dy-cursorsize dx+cursorsize dy+cursorsize];       %Draw the sprite at the new location.
                            Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                            Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],cursorcol);
                            Screen('Flip',win,0,0,1)
                        end
                        %After select the aiming target, before starting moveout, we show the selected aiming target
                        testcursor1_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                        Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                        Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                        %%save the data in experiment B and C, move_out direction
                        aimingtagpos_x_out(ii-1)=testcursorx_out;
                        aimingtagpos_y_out(ii-1)=testcursory_out;
                    end
                end
            end
            
            
            %%=========================================================================
            % make circle at p1
            if tgt_set~='f'&&tgt_set~='m'&&tgt_set~='r'            %other blocks, target is a circle
                Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],nextcol);
                Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],nextcol);
            elseif  tgt_set=='f'||tgt_set=='m'||tgt_set=='r'      %% target in NA-Gen block is changed into a red ring
                if mod(ii,2)==0
                    p1loc_aim=[centercircle_x1-targetsize centercircle_y1-targetsize centercircle_x1+targetsize centercircle_y1+targetsize];
                    Screen('DrawTexture', win, targtext,[],p1loc_aim,[],[],[],sel_aimingtargcol);
                    Screen('DrawTexture', win, targtext,[],screenoffset-p1loc_aim(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                else
                    Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],nextcol);
                    Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],nextcol);
                end
            end
            
            % make purple circle at start location
            if ~ismember(movement_type(ii),nfbret)
                Screen('DrawText', win, 'S', xstart-7, ystart-14,[255 255 255]);              %draw the start point as "S"
                Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],startcol_user);
            else
                Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
            end
            
            circlesize=9.5;        %%change the circle size into 10 (start point size) used for making sure that the cursor inside the start point and then next target appear and cursor disappear
            %Check if it is inside circle
            if sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<circlesize && insidecircle==0 && ismoving==1       % first time in circle
                t1=curtime;
                insidecircle=1;
            elseif sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<circlesize && ismoving==1
                insidecircle=1;
            else
                insidecircle=0;
            end
            circlesize=15;  %%return the circle size back to 15(target size)
            
            %==============================================================
            if tgt_set=='f'|| tgt_set=='m'|| tgt_set=='r'   %%Aiming target is fixed
                if sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh_NA && outsidecircle==0 && ismoving==1             %save the time when the distance of cursor larger than 200 and make sure cursor can reach target
                    t2=curtime;
                    outsidecircle=1;
                elseif sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh_NA && ismoving==1
                    outsidecircle=1;
                else
                    outsidecircle=0;
                end
            elseif (tgt_set=='g'||tgt_set=='l'||tgt_set=='s')||((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)==0))  
            %%Aiming target can be selected
                if sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh && outsidecircle==0 && ismoving==1             %save the time when the distance of cursor larger than 354 and make sure cursor can reach target
                    t2=curtime;
                    outsidecircle=1;
                elseif sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh && ismoving==1
                    outsidecircle=1;
                else
                    outsidecircle=0;
                end
            end
            
            %==============================================================
            % inside circle for long enough and then move on to next movement
            if  ( tgt_set=='a'||tgt_set=='b')||((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)~=0))
                if (insidecircle==1 && curtime-t1 >= timeinside && ismoving == 1) || ((~vis_feedback(ii) && ~ismember(movement_type(ii),[nfbret nfbout])) && (curtime-movement_start_time > maxsingletime || (max(total_vel((k-6):k)) < vstop_thresh && sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh)))
                    Snd('Wait');
                    Snd('Quiet');
                    Snd('Close');
                    if (insidecircle==1) && (curtime-movement_start_time<target_time-.1)   % got to circle too fast
                        if ismember(movement_type(ii),ptlist)
                            res=0;
                            nextcol=goodcol;
                            Snd('Play',ting,fs);
                        else
                            nextcol=fastcol;
                            res=-1;
                        end
                    elseif (insidecircle==1) && (curtime-movement_start_time>=target_time-.1&&curtime-movement_start_time<=target_time+.1)      % got to circle in good amount of time
                        res=0;
                        nextcol=goodcol;
                        Snd('Play',ting,fs);
                    else    %got to circle too slowly
                        res=1;
                        nextcol=slowcol;
                    end
                    timeincirc(hitcirc_count,:)=[movement_start_time-startTime movement_start_time-startTime curtime-startTime curtime-movement_start_time res];
                    % coords for new oval(s)
                    %===========================================================================================================
                    hitcirc_count=hitcirc_count+1;
                    aiming_flag = 0;
                    ii=ii+1;
                    t=t+1;
                    num=num+1;
                    t_last_trial = GetSecs;
                    curkey=0;
                    curkey1=0;
                    % coords for new oval(s)
                    xstart=xloc1;
                    ystart=yloc1;
                    xloc1= x1list(ii);
                    yloc1= y1list(ii);
                    centercircle_x1=xloc1;
                    centercircle_y1=yloc1;
                    startloc=[xstart-startcirclesize ystart-startcirclesize xstart+startcirclesize ystart+startcirclesize];
                    p1loc=[centercircle_x1-circlesize centercircle_y1-circlesize centercircle_x1+circlesize centercircle_y1+circlesize];
                    t_a=curtime;
                    t1=curtime;
                    % Reset variables for finding movement start
                    insidecircle=0;
                    started=0;
                    ismoving=0;
                end
            elseif (tgt_set=='f'|| tgt_set=='g'|| tgt_set=='l'||tgt_set=='m'|| tgt_set=='r'|| tgt_set=='s')||((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)==0))
                
                if (insidecircle==1 && curtime-t1 >= timeinside && ismoving == 1) || ((vis_feedback(ii) && ~ismember(movement_type(ii),[nfbret nfbout])) && (curtime-movement_start_time > maxsingletime || (max(total_vel((k-6):k)) < vstop_thresh && outsidecircle==1 && curtime-t2 >= timeinside_gen)))   %%sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh &&
                    curmoveindices=find(timevec(1:k)==movement_start_time,1):k;
                    % Find the Peak Velocity of Movement
                    curmaxvel=max(smooth(total_vel(curmoveindices)))*.0254/100;
                    Snd('Quiet');
                    % Change this control if you want to include a "too fast" condition
                    if curmaxvel>maxvelrange(1)&&curmaxvel<maxvelrange(2)&&(curtime-movement_start_time<=target_time)
                        res=0;
                    else          % too slow
                        res=1;
                    end
                    if ~vis_feedback(ii)
                        nextcol=no_vfb_col;
                    else
                        if res==-1   % got to circle too fast
                            nextcol=fastcol;
                        elseif res==0      % got to circle in good amount of time
                            %                             nextcol=goodcol;
                            nextcol=slowcol;
                            if ~ismember(movement_type(ii),nfbret)&&~vis_feedback(ii)
                                Snd('Play',ting,fs);
                            end
                        else    % got to circle too slowly
                            nextcol=slowcol;
                        end
                    end
                    timeincirc(hitcirc_count,:)=[movement_start_time-startTime movement_start_time-startTime curtime-startTime curtime-movement_start_time res];
                    % coords for new oval(s)
                    %===========================================================================================================
                    hitcirc_count=hitcirc_count+1;
                    aiming_flag = 0;
                    ii=ii+1;
                    t=t+1;
                    num=num+1;
                    t_last_trial = GetSecs;
                    curkey=0;
                    curkey1=0;
                    % coords for new oval(s)
                    xstart=xloc1;
                    ystart=yloc1;
                    xloc1= x1list(ii);
                    yloc1= y1list(ii);
                    centercircle_x1=xloc1;
                    centercircle_y1=yloc1;
                    startloc=[xstart-startcirclesize ystart-startcirclesize xstart+startcirclesize ystart+startcirclesize];
                    p1loc=[centercircle_x1-circlesize centercircle_y1-circlesize centercircle_x1+circlesize centercircle_y1+circlesize];
                    t_a=curtime;
                    t1=curtime;
                    t2=curtime;
                    % Reset variables for finding movement start
                    insidecircle=0;
                    outsidecircle=0;
                    started=0;
                    ismoving=0;
                end
            end
        end
    end
    
    %permiss next selection of aiming targets
    if  instant_showingtag==3;
        instant_showingtag=1;
    end
    %%%===============================================================================================================================================
    
    %     % if visual feedback present, draw cursor, otherwise don't     % if cursor is around ~startvisthresh radius circle of the middle in type 99 movements
    %%%%%%%%%%%%%%===========================================================
    if tgt_set=='a'||tgt_set=='b'
        if (vis_feedback(ii)==1 && (jumpthegun==0 && firsttimeout ==1) || sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || ((ismember(movement_type(ii),nfbret) || started==0) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0)
            Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
            Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
        else
            Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
        end
    else
        if ((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)~=0))
            if mod(ii,2)==0
                if (vis_feedback(ii)==1 && (jumpthegun==0 && firsttimeout ==1) || sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || ((ismember(movement_type(ii),nfbret) || started==0) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0)
                    Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                else
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                end
            end
            if mod(ii,2)~=0
                if sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<40    %||sqrt((dx-xstart)^2+(dy-ystart)^2)<20
                    if (vis_feedback(ii)==1 && ((jumpthegun==0 && firsttimeout ==1) || sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)) || (ismember(movement_type(ii),nfbret) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0 && jumpthegun==0) || (jumpthegun==1 && (sqrt((dx-xstart)^2 + (dy-ystart)^2)< startvisthresh)) || ((started==0 && ~ismember(movement_type(ii),nfbret)) && sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)
                        Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                        Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                    else
                        Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                    end
                else
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                end
            end
        elseif (tgt_set=='f'|| tgt_set=='g'|| tgt_set=='l'||tgt_set=='m'|| tgt_set=='r'|| tgt_set=='s')||((tgt_set=='c'||tgt_set=='d'||tgt_set=='e'||tgt_set=='h'||tgt_set=='i'|| tgt_set=='j'||tgt_set=='k'||tgt_set=='n'||tgt_set=='o'|| tgt_set=='p'|| tgt_set=='q')&& (cursor_nofeedback(ii)==0))          
            if mod(ii,2)==0&&sqrt((dx-xstart)^2+(dy-ystart)^2)<20
                vis_feedback(ii)=1;
                if (vis_feedback(ii)==1 && ((jumpthegun==0 && firsttimeout ==1) || sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)) || (ismember(movement_type(ii),nfbret) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0 && jumpthegun==0) || (jumpthegun==1 && (sqrt((dx-xstart)^2 + (dy-ystart)^2)< startvisthresh)) || ((started==0 && ~ismember(movement_type(ii),nfbret)) && sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)
                    Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                end
            elseif mod(ii,2)~=0&&sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<40
                vis_feedback(ii)=1;
                if (vis_feedback(ii)==1 && ((jumpthegun==0 && firsttimeout ==1) || sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)) || (ismember(movement_type(ii),nfbret) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0 && jumpthegun==0) || (jumpthegun==1 && (sqrt((dx-xstart)^2 + (dy-ystart)^2)< startvisthresh)) || ((started==0 && ~ismember(movement_type(ii),nfbret)) && sqrt((dx-xstart)^2 + (dy-ystart)^2) < startvisthresh)
                    Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
                end
            else
                Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
            end
        end
    end
    %%=====================================================================
    % the movements parameters of the cursor
    deltaxlast=diff(thePoints(k-1:k,1));
    deltaylast=diff(thePoints(k-1:k,2));
    
    total_displacementlast=sqrt(deltaxlast.^2+deltaylast.^2);
    total_vellast=total_displacementlast/diff(timevec(k-1:k))';
    deltax(k)=deltaxlast;
    deltay(k)=deltaylast;
    total_displacement(k)=total_displacementlast;
    total_vel(k)=total_vellast;
    
    % if no longer waiting and not jumping the gun, movement starts when velocity passes vstart_thresh
    if started==1 && insidecircle==0 && ismoving == 0 && jumpthegun==0 && total_vellast > vstart_thresh
        movement_start_time=curtime;
        ismoving = 1;
    elseif ismoving == 0
        movement_start_time=curtime;
    end
    
    %this following parts used to find the possible wrong point during
    %reaching movement
    %========================================================================================================================
    textxstart=resx/2-800;
    textystart=10;
    %     Screen('DrawText', win, ['dx: ' num2str(dx)], textxstart, textystart+13*ydist,[255 0 0]);
    %     Screen('DrawText', win, ['dy: ' num2str(dy)], textxstart, textystart+15*ydist,[255 0 0]);
    %     % %     Screen('DrawText', win, ['centercircle_x1: ' num2str(centercircle_x1)], textxstart, textystart+2*ydist,[255 0 0]);
    %     Screen('DrawText', win, ['centercircle_y1: ' num2str(centercircle_y1)], textxstart, textystart+3*ydist,[255 0 0]);
    %      Screen('DrawText', win, ['testcursorx1: ' num2str(testcursorx1)], textxstart, textystart+4*ydist,[255 0 0]);
    %      Screen('DrawText', win, ['testcursory1: ' num2str(testcursory1)], textxstart, textystart+5*ydist,[255 0 0]);
    %==============================================================================================================================
    
    % Draw additional info in the experiment window
    if hitcirc_count>1 % && mod(hitcirc_count,2)==0
        textxstart=resx/2-800;
        textystart=10;
        if isempty(find(timevec(1:k)>timeincirc(hitcirc_count-1,3),1))
            t_end=k;
        else
            t_end=find(timevec(1:k)>timeincirc(hitcirc_count-1,3),1)-1;
        end
        t_start=find(timevec(1:k)>timeincirc(hitcirc_count-1,1),1)-1;
        lastmaxvel=max(smooth(total_vel(t_start:t_end)))*.0254/100;
        allmaxvel(hitcirc_count)=lastmaxvel;
        
        % repmat([resx;resy],size(t_start:t_end)) is used to shift the cursor path line
        % the below code line is used to show the path of cursor on the tablet
        lastpath=repmat([resx;resy],size(t_start:t_end))-(scaling*(thePoints(t_start:t_end,:)'-repmat([rotx;roty],size(t_start:t_end)))+repmat([rotx;roty],size(t_start:t_end)));
        %lastpath=scaling*thePoints(t_start:t_end,:)'; %show the path of cursor on the screen
        lastpath2=lastpath(:,sort([1 2:length(lastpath) 2:length(lastpath)]));
        
        lastvel=smooth(total_vel(t_start:t_end))';
        velxvals=linspace(0,500,length(lastvel));
        velyvals=-lastvel/max(lastvel)*100;
        lastvel2=[velxvals;velyvals];
        lastvel3=lastvel2(:,sort([1 2:length(lastvel2) 2:length(lastvel2)]));
        
        Screen('DrawLines', win, lastpath2,1,[255 255 0]);
        Screen('DrawLines', win, lastvel3,1,[255 255 0],[textxstart textystart+13*ydist]);
        
        Screen('DrawText', win, ['Movetime: ' num2str(timeincirc(hitcirc_count-1,3)-timeincirc(hitcirc_count-1,2))], textxstart, textystart,[255 0 0]);
        Screen('DrawText', win, ['Max Vel: ' num2str(lastmaxvel)], textxstart, textystart+1.5*ydist,[255 0 0]);
        Screen('DrawText', win, ['Ave Movetime (block): ' num2str(nanmean(timeincirc(1:2:hitcirc_count-1,3)-timeincirc(1:2:hitcirc_count-1,2)))], textxstart, textystart+3*ydist,[255 0 0]);
        Screen('DrawText', win, ['Ave Max Vel (block): ' num2str(nanmean(allmaxvel(3:end)))], textxstart, textystart+4.5*ydist,[255 0 0]);
    end
    Screen('DrawText', win, ['Trial ' num2str(ii-2),'/',num2str(size(psychtest,1)-2),', Wait: ' num2str(wait_time + wait_time_before_movement(ii),'%.2f') '  ' num2str(GetSecs-t_last_trial,'%.2f')], textxstart, textystart+6*ydist,[255 0 0]);
end
ShowCursor;
Screen('CloseAll'); % close screen
if usetablet,
    WinTabMex(3); % Stop/Pause data acquisition.
    WinTabMex(1); % Shutdown driver.
end
ListenChar(0);

timevec=timevec(1:k); % difference between timevec and timevec2 is time it takes to run while loop
thePoints=thePoints(1:k,:);
tabletPoints=tabletPoints(1:tab_k,:); %#ok<NASGU>
total_vel=total_vel(1:k); %#ok<NASGU>
total_displacement=total_displacement(1:k); %#ok<NASGU>
deltax=deltax(1:k); %#ok<NASGU>
deltay=deltay(1:k); %#ok<NASGU>
timeincirc=timeincirc(1:hitcirc_count-1,:);
thePoints(:,1)=thePoints(:,1)-resx/2; %#ok<NASGU>        % adjust for other monitor points
testpositions(testpositions>180)=testpositions(testpositions>180)-360;  % convert from 0 to 360 to -180 to 180
goodlist=find(timeincirc(:,5)==0);
typelist=cell(maxtrialnum,1);

for counter=1:maxtrialnum
    typelist{counter}=find(movement_type==counter)-1;
end
name_prefix_all = [name_prefix,'_set_',tgt_set,'_',date];
disp('Saving...')
if ~exist([name_prefix_all,'.mat'],'file'), datafile_name = [name_prefix_all,'.mat'];
elseif ~exist([name_prefix_all,'_a.mat'],'file'), datafile_name = [name_prefix_all,'_a.mat'];
elseif ~exist([name_prefix_all,'_b.mat'],'file'), datafile_name = [name_prefix_all,'_b.mat'];
else
    char1='c';
    while exist([name_prefix_all,'_',char1,'.mat'],'file'), char1=char(char1+1); end
    datafile_name = [name_prefix_all,'_',char1,'.mat'];
end

save([name_prefix, '/', datafile_name]); disp(['Saved ', datafile_name]);

ntrials=size(timeincirc,1);
disp(['You got a total of ' num2str(length(goodlist)) ' trials correct out of a possible ' num2str(ntrials-1)])

curlen=1;
maxlen=0;
for ii=1:length(goodlist)
    if curlen>maxlen
        maxlen=curlen;
    end
    
    if ii>1
        if goodlist(ii)==goodlist(ii-1)+1
            curlen=curlen+1;
        else
            curlen=1;
        end
    end
end

disp(['Your longest streak was ' num2str(maxlen) ' trials in a row.'])
disp(['You took ' num2str(timevec(end)) ' seconds to complete this block.'])
return

function [rx, ry] = rotatexy(x,y,phi)
% phi is in degrees
phi=phi*pi/180;
[theta r]=cart2pol(x,y);
[rx ry]=pol2cart(theta+phi,r);
return


%
% function [angle_tag_out]= save_angle_out(testcursorx_out,testcursory_out,xstart,ystart)
% % save the  position of the aiming target when move_out
% if testcursorx_out<xstart&&testcursory_out>ystart
%     angle_tag_out=(atan((testcursory_out-ystart)/(xstart-testcursorx_out))-pi/2)*180/pi;
% elseif testcursorx_out<xstart&&testcursory_out<ystart
%     angle_tag_out=(-atan((ystart-testcursory_out)/(xstart-testcursorx_out))-pi/2)*180/pi;
% elseif testcursorx_out>xstart&&testcursory_out>ystart
%     angle_tag_out=(-atan((testcursory_out-ystart)/(testcursorx_out-xstart))+pi/2)*180/pi;
% elseif testcursorx_out>xstart&&testcursory_out<ystart
%     angle_tag_out=(atan((ystart-testcursory_out)/(testcursorx_out-xstart))+pi/2)*180/pi;
% elseif testcursory_out==ystart&&testcursorx_out<xstart
%     angle_tag_out=-90;
% elseif testcursory_out==ystart&&testcursorx_out>xstart
%     angle_tag_out=90;
% elseif testcursorx_out==xstart
%     angle_tag_out=0;
% end
% return





