function exprun_strategy_VMR_Exp_a(name_prefix,c)
mkdir(name_prefix);
tgt_prefix = [pwd,'\tgt_files_aimingtag_a\vmr_aimingtag_',c];
dummy=input('Familiarization 1: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'a')
dummy=input('Familiarization 2: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'b')
dummy=input('Baseline 1: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'c')
dummy=input('Baseline 2: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'d')
dummy=input('Baseline 3: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'e')
dummy=input('Training 1: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'f')
dummy=input('Training 2: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'g')
dummy=input('Training 3: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'h')
dummy=input('Training 4: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'i')
dummy=input('Training 5: ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'j')
dummy=input('Wash out : ');
runexp_strategy_VMR_Exp_a(name_prefix,tgt_prefix,'k')
return
