function exprun_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,c)
mkdir(name_prefix);
tgt_prefix = [pwd,'\tgt_files_aimingtag_exp_general_rot\vmr_aimingtag_',c];
dummy=input('Familiarization 1: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'a')
dummy=input('Familiarization 2: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'b')
dummy=input('Baseline 1: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'c')
dummy=input('Baseline 2: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'d')
% dummy=input('Baseline 3: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'e')
dummy=input('General-A: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'f')
dummy=input('General-NA: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'g')
dummy=input('Training 1: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'h')
dummy=input('Training 2: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'i')
dummy=input('General-NA: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'j')
dummy=input('General-A: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'k')
dummy=input('Training 3: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'l')
dummy=input('Training 4: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'m')
dummy=input('General-A: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'n')
dummy=input('General-NA: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'o')
cont = 1; counter = 0;
while cont && counter<4
    reply = 'A';
    while ~ismember(reply,'YyNn'),
        reply=input('Would you like to continue (Y/N)? ','s');
    end
    cont = ismember(reply,'Yy');
    if cont
        counter = counter + 1;
        if counter<3
            dummy=input(['Training ',int2str(4+counter),': ']);
        else
            dummy=input(['Washout ',int2str(counter-2),': ']);
        end
        runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'o'+counter);
    else
        return;
    end;
end
dummy=input('Training 5: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'p')
dummy=input('Training 6: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'q')
dummy=input('Wash-out1: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'r')
dummy=input('Wash-out2: ');
runexp_strategy_VMR_Exp_General_Rot_Wiggle(name_prefix,tgt_prefix,'s')
return
