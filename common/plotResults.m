function plotResults(RMSE, nTest, noise)

n=10:10:90;
name= {'M-estimation', 'MCC','RANSAC', 'GNC-GM', 'MAGSAC++','AMCC' };
marker= {'x','+','p','d','<','o'};
color = hsv(length(name));
lx='Outlier rate [%]';

%% plot RMSE
RES=[];                         
for i=1:length(name)      
    RMS=RMSE{1,i};
    RMS(RMS>3*noise)=3*noise;
    res=mean(RMS,2);
    RES=[RES;res'];
end
figure;box('on');hold('all');
ly='RMSE';
yrange= [0 3*noise];
p= zeros(1,length(name));
for i= 1:length(name)
    p(i)= plot(n,RES(i,:),'marker',marker{i},'color',color(length(name)-i+1,:),...
        'markerfacecolor',color(length(name)-i+1,:),'displayname',name{i}, 'LineWidth',3,'MarkerSize',8);
      
end
ylim(yrange);
xlim(n([1 end]));
set(gca,'xtick',n);
handle=legend(p,'Fontname', 'Times New Roman');
xlabel(lx,'FontSize',16,'Fontname', 'Times New Roman');
ylabel(ly,'FontSize',16,'Fontname', 'Times New Roman');
set(gca,'position',[0.13 0.14 0.85 0.84]);
set(gca,'FontSize',16,'Fontname','Times new roman');

%% plot Success rate
RES=[];
for i=1:6
    res=sum(RMSE{1,i}<3*noise,2);
    res=(res./nTest)*100;
    if isempty(res)
        continue;
    end
    RES=[RES;res'];
end
figure;box('on');hold('all');
ly='Success rate [%]';
yrange= [0 100];
p= zeros(1,length(name));
for i= 1:length(name)
    p(i)= plot(n,RES(i,:),'marker',marker{i},'color',color(length(name)-i+1,:),...
        'markerfacecolor',color(length(name)-i+1,:),'displayname',name{i}, 'LineWidth',3,'MarkerSize',8);
      
end
ylim(yrange);
xlim(n([1 end]));
set(gca,'xtick',n);
handle=legend(p,'Fontname', 'Times New Roman');
xlabel(lx,'FontSize',14,'Fontname', 'Times New Roman');
ylabel(ly,'FontSize',14,'Fontname', 'Times New Roman');
set(gcf,'Position',[0,0,800,400], 'color','w') 
set(gca,'position',[0.09 0.14 0.9 0.84]);
set(gca,'FontSize',14,'Fontname','Times new roman');

