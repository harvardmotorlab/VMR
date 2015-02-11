%%positive rotation
a=load('vmr_aimingtag_Pc.tgt'); pc=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Pd.tgt'); pd=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Pe.tgt'); pe=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Ph.tgt'); pl=find(a(:,12)==0), rh=find(a(:,1)==0),size(a)
a=load('vmr_aimingtag_Pi.tgt'); pi=find(a(:,12)==0),ri=find(a(:,1)==0); ri(1:2:end), size(a)
a=load('vmr_aimingtag_Pj.tgt'); pj=find(a(:,12)==0),rj=find(a(:,1)==0); rj(1:2:end),size(a)
a=load('vmr_aimingtag_Pk.tgt'); pk=find(a(:,12)==0),rk=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Pn.tgt'); pn=find(a(:,12)==0),rn=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Po.tgt'); po=find(a(:,12)==0),ro=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Pp.tgt'); pp=find(a(:,12)==0),rp=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Pq.tgt'); pq=find(a(:,12)==0),rq=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Pt.tgt'); pt=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Pu.tgt'); pu=find(a(:,12)==0),, size(a)



%%negative rotation
a=load('vmr_aimingtag_Nc.tgt'); nc=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Nd.tgt'); nd=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Ne.tgt'); ne=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Nh.tgt'); nh=find(a(:,12)==0),rh=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Ni.tgt'); ni=find(a(:,12)==0), ri=find(a(:,1)==0),size(a)
a=load('vmr_aimingtag_Nj.tgt'); nj=find(a(:,12)==0), rj=find(a(:,1)==0),size(a)
a=load('vmr_aimingtag_Nk.tgt'); nk=find(a(:,12)==0), rk=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Nn.tgt'); nn=find(a(:,12)==0), rn=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_No.tgt'); no=find(a(:,12)==0), ro=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Np.tgt'); np=find(a(:,12)==0), rp=find(a(:,1)==0), size(a)
a=load('vmr_aimingtag_Nq.tgt'); nq=find(a(:,12)==0), rq=find(a(:,1)==0),  size(a)
a=load('vmr_aimingtag_Nt.tgt'); nt=find(a(:,12)==0), size(a)
a=load('vmr_aimingtag_Nu.tgt'); nu=find(a(:,12)==0), size(a)

disp('pc,pd,pe,nc,nd,ne')
[pc,pd,pe,nc,nd,ne]
disp('pi,pj,pk,po,ni,nj,nk,no')
[pi,pj,pk,po,ni,nj,nk,no]
disp('pl,pp,pq,pr,nl,np,nq,nr')
[pl,pp,pq,pr,nl,np,nq,nr]