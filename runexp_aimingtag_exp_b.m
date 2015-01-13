function runexp_aimingtag_exp_b(name_prefix,tgt_file_name_prefix,tgt_set)

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
Screen('Preference','DefaultFontSize',25);

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
wait_time=.25;      % time in circle before target appears
wait_time2=0;      % wait time after target appears, to avoid false starts
timeinside=.3;      % time in the end target at below vel threshold until movement ends
vstart_thresh=250;  % pixels per second 6.35 cm/s in hand space
vstop_thresh=300;
singletravthresh=300;   % movement must be at least 7.6 cm long
startvisthresh=60;      % pixels around center start
ydist=20;               % spacing of entries on experimenter's monitor
maxsingletime=5;
reward_scale=1;         %3; % scaling factor for reward circle around the end point

% List of movement types
vflist=[1 2 3 4 19 20 25 26];
ptlist=[5 6 7 8 17 18 27 28];
dblist=[9 10 11 12 13 14 15 16 21 22 23 24];
nfbret=[98 99];
fbret=0;

% Program Colors
startcol_exp=[0 0 0];        %movement start color__black for experiment control
startcol_user=[255 0 255];   %movement start color__purple for user control

waitcol=[255 255 0];   %wait for movemnt as yellow

goodcol = [0 255 0];
slowcol = [0 0 255];
fastcol = [255 0 0];
nextcol = goodcol;
% slowcol= [255 0 0];
% nextcol=[0 255 0];

cursorcol=[255 255 255];            %cursor color in experiment control screen_ white
nofeedcursorcol=[255 0 255];        %cusor color in user screen_ purple


% Texture Definitions showing the circle of target or cursor
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
%be changed to modulate the position
philist=psychtest(:,1);
x1list=resx-psychtest(:,3);   %psychtest(:,3)and psychtest(:,2)are the position displaying in target file
y1list=resy-psychtest(:,4);
vis_feedback=psychtest(:,7);
movement_type=psychtest(:,8);
mark_endpoint=psychtest(:,9);
aim_rotation = psychtest(:,10);
aim_type = psychtest(:,11);

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

x_p1loc1=zeros(MAX_SAMPLES,1);
y_p1loc1=zeros(MAX_SAMPLES,1);

%save the data of aiming angle
aimingtagpos_x_out=zeros(size(psychtest,1),1);  %save the position of the selected aiming targets
aimingtagpos_y_out=zeros(size(psychtest,1),1);  %every block should save the position; 5 represents five blocks of experiments
aimingtagpos_x_back=zeros(size(psychtest,1),1);  %save the position of the selected aiming targets
aimingtagpos_y_back=zeros(size(psychtest,1),1);  %every block should save the position; 5 represents five blocks of experiments

aimingtargetangle=zeros(size(psychtest,1),1);

aiminglen=(length(x1list)-2)/2+1;
aimingangle1=ones(aiminglen,1)*2;             %save the angle of move_out
aimingangle2=ones(aiminglen,1)*2;             %save the angle of move_back

aimingangle_out=ones(aiminglen-1,1)*2;        %save the real angle of move_out
aimingangle_back=ones(aiminglen-1,1)*2;       %save the real angle of move_out
cursor_position=[];
cursor_position_1=[];

% Program variable predeclaration
[~, ~, buttons]=GetMouse;
jumpthegun=0;
hitcirc_count=1;
insidecircle=0;
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
xloc1= x1list(ii);      % x and y locations of finishing circle (cursor target)
yloc1= y1list(ii);
centercircle_x1=xloc1;
centercircle_y1=yloc1;

xstart_aiming=x1list(2); % x and y locations of aiming target when it is superposed with the cursor targets
ystart_aiming=y1list(2);

startTime = 0;
tic;
t_last_trial = GetSecs;
movement_start_time=startTime;
t_a=startTime;
startloc=[xstart-startcirclesize ystart-startcirclesize xstart+startcirclesize ystart+startcirclesize];%
p1loc=[centercircle_x1-circlesize centercircle_y1-circlesize centercircle_x1+circlesize centercircle_y1+circlesize];

% Hide the mouse cursor.
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
rightarrow_back=37;
leftarrow_back=39;

curtime=toc;
%angle for which testcursor starts
targetangle=atan((yloc1-ystart)/(xloc1-xstart));
%testangle=(2*round(rand(1))-1)*pi/2+targetangle;        % +/- 90,the transferation between the main screen and the less improtant screen
testangle_out=targetangle; %+pi/2;        % +/- 9
testangle_back=atan((ystart-yloc1)/(xloc1-xstart));
testangle_out=0;
testangle_back=0;

curkey=0;
curkey1=0;
firstpress=1;
teststarttime=curtime;

movelen=sqrt((x1list(1)-x1list(2))^2+(y1list(1)-y1list(2))^2);          %the radius of the circle
testcirclepath=movelen*[cos((0:180)/180*2*pi);sin((0:180)/180*2*pi)];   %the postion of aiming target
testcirclepath2=repmat([x1list(1);y1list(1)],1,length(testcirclepath)*2-1 )+testcirclepath(:,sort([1 2:length(testcirclepath) 2:length(testcirclepath)]));
targetpost1=zeros(180,4);
keyaim =1; % determine whether we select target via keyboard or mouse.

if usetablet
    WinTabMex(2); %Empties the packet queue in preparation for collecting actual data
end
WaitSecs(0.25); % just in case wait
instant_showingtag=1;

SetMouse(xc,yc);
[mx_init, ~, ~] = GetMouse;

while ~any(buttons(2))&&ii<length(philist) %
    %while ~any(curkey1 == space) &&ii<length(philist)    %~any(buttons(2:end)), the button of corsor is not pressed,the button is 3 dim vector[~,~,~]which respresents left, mid and right button of corsor. if the rigjt botton is not pressed, the code in which is goning on
    %end every block with space key
    k=k+1;
    Screen('Flip',win,0,0,1);
    %determine the position of the amiming targets
    for i=1:180
        targetpost1(i,:)=[testcirclepath(1:2,i)', testcirclepath(1:2,i)'] + [xstart ystart xstart ystart] + ATGT_selection_dot_size*[-1,-1, 1, 1];
    end
    if tgt_set~='a'&&tgt_set~='b'
        %%=====================================================================
        %%when move out, show the aiming target
        if mod(ii,2)==0
            if aim_type(ii)==999    %show how to select the aiming target in the baseline block and training block
                if ii==2&&tgt_set~='c' &&tgt_set~='d'&&tgt_set~='f'  % download the position of aiming target in last block
                    load('aimingtag_out.mat')
                    testangle_out=testangle_out;
                elseif tgt_set=='c'&&tgt_set=='d'&&tgt_set=='f'
                    testangle_out=0;
                end
                while ~any(curkey1==uparrow)&&curkey~=1
                    [keyIsDown,keySecs,keyCode] = KbCheck;
                    [mx, my, buttons] = GetMouse;
                    if buttons(1,1)==1
                        curkey=1;
                    end
                    if keyaim, % if using key to aim
                        %decide the changing angle of the moving cursor
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
                            
                            %decide the position of the pressed key
                            curkey1=find(keyCode);
                            if curkey1 == uparrow
                                %if toc < teststarttime+1;
                                %  curkey=enternarrow;
                                break;
                            end
                            if curkey1 == leftarrow_out
                                testangle_out=testangle_out-cursorspeed;
                            elseif curkey1 == rightarrow_out
                                testangle_out=testangle_out+cursorspeed;
                            end
                        else
                            firstpress=1;
                        end
                    else       % if using mouse to aim
                        displ=(mx-mx_init)/movelen;
                        testangle_out=displ+pi/2;
                    end
                    
                    cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                    testcursorx_out=xstart+movelen*cos(testangle_out+cursor_tgt_angle);
                    testcursory_out=ystart+movelen*sin(testangle_out+cursor_tgt_angle);
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
                    %               Screen('DrawTexture', win, circletext,[],startloc,[],[],[],waitcol);
                    Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);              %draw the start point as "S"
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
                if ii==length(x1list)-2
                    savefile = 'aimingtag_out.mat';
                    save(savefile, 'testcursorx_out', 'testcursory_out','testangle_out');
                end
                %==================================================================
            elseif  aim_type(ii)==990  %show the aiming target when it is fixed at 30 or -30
                testcursorx_out=xstart+movelen*sind(aim_rotation(ii));
                testcursory_out=ystart+movelen*cosd(aim_rotation(ii));
                testcursor1_out=[testcursorx_out-targetsize testcursory_out-targetsize testcursorx_out+targetsize testcursory_out+targetsize];
                Screen('DrawTexture', win, targtext,[],testcursor1_out,[],[],[],sel_aimingtargcol);
                Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_out(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
            end
            
            aimingtagpos_x_out(ii-1)=testcursorx_out;
            aimingtagpos_y_out(ii-1)=testcursory_out;
            % save the  position of the aiming target
            if testcursorx_out<xstart&&testcursory_out>ystart
                angle_tag_out=atan((testcursory_out-ystart)/(xstart-testcursorx_out))-pi/2;
            elseif testcursorx_out<xstart&&testcursory_out<ystart
                angle_tag_out=-atan((ystart-testcursory_out)/(xstart-testcursorx_out))-pi/2;
            elseif testcursorx_out>xstart&&testcursory_out>ystart
                angle_tag_out=-atan((testcursory_out-ystart)/(testcursorx_out-xstart))+pi/2;
            elseif testcursorx_out>xstart&&testcursory_out<ystart
                angle_tag_out=atan((ystart-testcursory_out)/(testcursorx_out-xstart))+pi/2;
            elseif testcursory_out==ystart&&testcursorx_out<xstart
                angle_tag_out=-pi/2;
            elseif testcursory_out==ystart&&testcursorx_out>xstart
                angle_tag_out=pi/2;
            elseif testcursorx_out==xstart
                angle_tag_out=0;
            end
            aimingangle1(t)=angle_tag_out;
        end
        
        if aimingangle1(t)==2                         % save the position of the cursor witho 0 in the vector
            t=t-1;
        end
        if ii==length(x1list)-2
            aimingangle_out=aimingangle1(1:end-1);     %delete the last zero in the vector
        end
        
        %when move back, show the aiming target
        if mod(ii,2)~=0
            if aim_type(ii)==-998    %show how to select the aiming target in the baseline block and training block
                if ii==3&&tgt_set~='c'&&tgt_set~='d'&&tgt_set~='f'     % download the position of aiming target in last block
                    load('aimingtag_back.mat')
                    testangle_back=testangle_back;
                elseif tgt_set=='c'&&tgt_set=='d'&&tgt_set~='f'
                    testangle_back=0;
                end
                while ~any(curkey1==uparrow) && curkey~=1
                    
                    [keyIsDown,keySecs,keyCode] = KbCheck;
                    [mx, my, buttons] = GetMouse;
                    if buttons(1,1)==1
                        curkey=1;
                    end
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
                            curkey1=find(keyCode);
                            if curkey1 == uparrow
                                %if toc < teststarttime+1;
                                %  curkey=enternarrow;
                                break;
                            end
                            if curkey1 == downarrow
                                return
                            end
                            if curkey1 == leftarrow_back
                                testangle_back=testangle_back-cursorspeed;
                            elseif curkey1 == rightarrow_back
                                testangle_back=testangle_back+cursorspeed;
                            else
                            end
                        else
                            firstpress=1;
                        end
                    else % if using mouse to aim
                        displ=(mx-mx_init)/movelen;
                        testangle_back=displ + pi/2;
                    end
                    cursor_tgt_angle = atan2( diff(y1list(ii-1:ii)), diff(x1list(ii-1:ii)) );
                    testcursorx_back=xstart+movelen*cos(testangle_back+cursor_tgt_angle);
                    testcursory_back=ystart+movelen*sin(testangle_back+cursor_tgt_angle);
                    testcursor_back=[testcursorx_back-targetsize testcursory_back-targetsize testcursorx_back+targetsize testcursory_back+targetsize];    %define a rectangle in pixels
                    Screen('DrawTexture', win, targtext,[],testcursor_back,[],[],[],sel_aimingtargcol);                                                   %draw aiming tgt on experiment control screen
                    Screen('DrawTexture', win, targtext,[],screenoffset-testcursor_back(1,[3,4,1,2]),[],[],[],sel_aimingtargcol); 
                    %draw aiming tgt on user screen.
                    %show the aiming targets
                    for i=1:180
                        targetpostion=targetpost1(i,:);
                        Screen('DrawTexture', win, ATGT_selection_dot_text,[],targetpostion,[],[],[],ATGT_selection_dotcol);
                        Screen('DrawTexture', win, ATGT_selection_dot_text,[],screenoffset-targetpostion(1,[3,4,1,2]),[],[],[],ATGT_selection_dotcol);
                    end
                    %%display the cursor target when select the aiming targets
                    %                 Screen('DrawTexture', win, circletext,[],startloc,[],[],[],waitcol);
                    Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);                     %draw the start point with "S"
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
                    thePoints(k,:) = [mX mY]; % record full precision points of the botton in corsor
                    % location to display cursor
                    % rotate xy centers around middle of screen coords at (0,0)
                    [dx dy]=rotatexy(mX-rotx,-(mY-roty),philist(ii));
                    dx = scaling*dx+rotx;     % expand screen shift it back
                    dy = -scaling*dy+roty;     % shift it back
                    %Draw the sprite at the new location.
                    cursor=[dx-cursorsize dy-cursorsize dx+cursorsize dy+cursorsize];
                    Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
                    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],cursorcol);
                    Screen('Flip',win,0,0,1)
                end
                %%=============================================================
                %show the selected aiming target
                testcursor1_back=[testcursorx_back-targetsize testcursory_back-targetsize testcursorx_back+targetsize testcursory_back+targetsize];
                Screen('DrawTexture', win, targtext,[],testcursor1_back,[],[],[],sel_aimingtargcol);
                Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_back(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
                if ii==length(x1list)-3
                    savefile = 'aimingtag_back.mat';
                    save(savefile, 'testcursorx_back', 'testcursory_back','testangle_back');
                end
                %==================================================================
            elseif aim_type(ii)==-997  %show the aiming target when it is fixed at 30 or -30
                testcursorx_back=xstart-movelen*sind(aim_rotation(ii));
                testcursory_back=ystart-movelen*cosd(aim_rotation(ii));
                testcursor1_back=[testcursorx_back-targetsize testcursory_back-targetsize testcursorx_back+targetsize testcursory_back+targetsize];
                Screen('DrawTexture', win, targtext,[],testcursor1_back,[],[],[],sel_aimingtargcol);
                Screen('DrawTexture', win, targtext,[],screenoffset-testcursor1_back(1,[3,4,1,2]),[],[],[],sel_aimingtargcol);
            end
            %      %%========================================================================================
            aimingtagpos_x_back(ii-1)=testcursorx_back;
            aimingtagpos_y_back(ii-1)=testcursory_back;
            % save the  position of the aiming target
%             if tgt_set~='c'&&tgt_set~='d'
            if testcursorx_back<xstart&&testcursory_back>ystart
                angle_tag_back=atan((testcursory_back-ystart)/(xstart-testcursorx_back))-pi/2;
            elseif testcursorx_back<xstart&&testcursory_back<ystart
                angle_tag_back=-atan((ystart-testcursory_back)/(xstart-testcursorx_back))-pi/2;
            elseif testcursorx_back>xstart&&testcursory_back>ystart
                angle_tag_back=-atan((testcursory_back-ystart)/(testcursorx_back-xstart))+pi/2;
            elseif testcursorx_back>xstart&&testcursory_back<ystart
                angle_tag_back=atan((ystart-testcursory_back)/(testcursorx_back-xstart))+pi/2;
            elseif testcursory_back==ystart&&testcursorx_back<xstart
                angle_tag_back=-pi/2;
            elseif testcursory_back==ystart&&testcursorx_back>xstart
                angle_tag_back=pi/2;
            elseif testcursorx_back==xstart
                angle_tag_back=0;
            end
            aimingangle2(num)=angle_tag_back;
%             end
%             if tgt_set=='c'&&tgt_set=='d'
%                 if testcursorx_back<xstart&&testcursory_back>ystart
%                     angle_tag_back=atan((testcursory_back-ystart)/(xstart-testcursorx_back))-pi/2;
%                 elseif testcursorx_back<xstart&&testcursory_back<ystart
%                     angle_tag_back=-atan((ystart-testcursory_back)/(xstart-testcursorx_back))-pi/2;
%                 elseif testcursorx_back>xstart&&testcursory_back>ystart
%                     angle_tag_back=-atan((testcursory_back-ystart)/(testcursorx_back-xstart))+pi/2;
%                 elseif testcursorx_back>xstart&&testcursory_back<ystart
%                     angle_tag_back=atan((ystart-testcursory_back)/(testcursorx_back-xstart))+pi/2;
%                 elseif testcursory_back==ystart&&testcursorx_back<xstart
%                     angle_tag_back=-pi/2;
%                 elseif testcursory_back==ystart&&testcursorx_back>xstart
%                     angle_tag_back=pi/2;
%                 elseif testcursorx_back==xstart
%                     angle_tag_back=0;
%                 end
%                 aimingangle2(num)=angle_tag_back;
%             end
        end
        aimingangle2(1)=1;
        % save the position of the cursor witho 0 in the vector
        if aimingangle2(num)==2
            num=num-1;
        end
        %delete the last zero in the vector
        if ii==length(x1list)-1
            Len=length(aimingangle2);
            aimingangle_back=aimingangle2(2:Len-1);
        end
    end
%=========================================================================
%=========================================================================
%     Here, GetMouse is only used so we know if a mouse button has been
%     pressed. If so, the while loop will exit in the next run and the
%     program will return to the command window.
[mX, mY, buttons] = GetMouse;
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
    if ~ismember(movement_type(ii),nfbret)  % if movement is not a no feedback return
        % yellow circle at start location
        %             Screen('DrawTexture', win, circletext,[],startloc,[],[],[],waitcol);
        Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);              %draw the start point as "S"
        Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
    else % movement is a no feedback return
        Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
    end
    
    if sqrt((dx-xstart)^2+(dy-ystart)^2)>startcirclesize     % cursor left start circle
        if firsttimeout==1
            if sqrt((dx-xstart)^2+(dy-ystart)^2)>circlesize && ~ismember(movement_type(ii),nfbret)
                Snd('Play',glass,fs1);
            end
            firsttimeout=0;
        end
        movement_start_time=curtime;
        t_a=movement_start_time;
    end
    
    if (curtime >= t_a + wait_time) || ismember(movement_type(ii),nfbret)  % in circle for long enough
        firsttimeout=1;
        started=1;
        t_a=curtime;
        if ~ismember(movement_type(ii),nfbret)  % if it isn't a no feedback return
            %                 Screen('DrawTexture', win, circletext,[],startloc,[],[],[],startcol);
            Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);              %draw the start point as "S"
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
        %             Screen('DrawTexture', win, circletext,[],startloc,[],[],[],startcol);
        Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);              %draw the start point as "S"
        Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],startcol_user);
        
        if sqrt((dx-xstart)^2+(dy-ystart)^2)>circlesize     % cursor left old target circle
            if firsttimeout==1 && (movement_type(ii)~=99)
                firsttimeout=0;
                Snd('Play',glass,fs1);
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
        % make circle at p1
        Screen('DrawTexture', win, circletext,[],p1loc,[],[],[],nextcol);
        Screen('DrawTexture', win, circletext,[],screenoffset-p1loc(1,[3,4,1,2]),[],[],[],nextcol);
        
        % make purple circle at start location
        if ~ismember(movement_type(ii),nfbret)
            %                 Screen('DrawTexture', win, circletext,[],startloc,[],[],[],startcol);
            Screen('DrawText', win, 'S', xstart-9, ystart-17,[255 255 255]);              %draw the start point as "S"
            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],startcol_user);
        else
            Screen('DrawTexture', win, circletext,[],screenoffset-startloc(1,[3,4,1,2]),[],[],[],waitcol);
        end
        
        %Check if it is inside circle
        if sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<circlesize && insidecircle==0 && ismoving==1    % first time in circle
            t1=curtime;
            insidecircle=1;
        elseif sqrt((dx-centercircle_x1)^2+(dy-centercircle_y1)^2)<circlesize && ismoving==1
            insidecircle=1;
        else
            insidecircle=0;
        end
        
        % inside circle for long enough
        % move on to next movement
        if (insidecircle==1 && curtime-t1 >= timeinside && ismoving == 1) || (ismember(movement_type(ii),ptlist) && (curtime-movement_start_time > maxsingletime || (max(total_vel((k-6):k)) < vstop_thresh && sqrt((dx-rotx)^2 + (dy-roty)^2) > singletravthresh)))
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
            ii=ii+1;
            t=t+1;
            num=num+1;
            t_last_trial = GetSecs;
            curkey=0;       %save by mouse
            curkey1=0;      %save by keyboard
            
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
    end
end
%permiss next selection of aiming targets
if  instant_showingtag==3;
    instant_showingtag=1;
end
%%%===============================================================================================================================================

% if visual feedback present, draw cursor, otherwise don't
% if cursor is around ~startvisthresh radius circle of the middle in type 99 movements
if (vis_feedback(ii)==1 && (jumpthegun==0 && firsttimeout ==1) || sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || ((ismember(movement_type(ii),nfbret) || started==0) && sqrt((dx-rotx)^2 + (dy-roty)^2) < startvisthresh) || (~ismember(movement_type(ii),nfbret) && ismoving==0)
    Screen('DrawTexture', win, cursortext,[],cursor,[],[],[],cursorcol);
    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],cursorcol);
else
    Screen('DrawTexture', win, cursortext,[],screenoffset-cursor(1,[3,4,1,2]),[],[],[],nofeedcursorcol);
end

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
%     Screen('DrawText', win, ['dx: ' num2str(dx)], textxstart, textystart,[255 0 0]);
%     Screen('DrawText', win, ['dy: ' num2str(dy)], textxstart, textystart+ydist,[255 0 0]);
% %     Screen('DrawText', win, ['centercircle_x1: ' num2str(centercircle_x1)], textxstart, textystart+2*ydist,[255 0 0]);
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
save(datafile_name); disp(['Saved ', datafile_name]);

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
