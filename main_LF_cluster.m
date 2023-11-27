clc;clear;close all; warning off
addpath(genpath('LineF'));
addpath(genpath('common'));

%% simulated data settings
npt=50;                     % inlier number
noise=0.01;                 %  noise level
nTest=100;                  % 100 independent tests 
thre = 3*noise;
RMS=cell(1,6);              % RMSE result
TIME=cell(1,6);             % time result

%% main loop: ourtiler rate from 10% to 90%, six methods for comparison
for k=1:9
    IR=1-k/10;                                          % inlier rate from 90% to 10%
    NO=round(npt/IR)-npt;                               % number of outliers
    str=['the outlier rate =' num2str(k*10) '%']; disp(str);
    
    for i=1:nTest

        %% data preparation
        rng shuffle
        cNO = min(max(ceil(xrand(1,1,[0,NO])),50),NO);  % number of clustered outliers
        uNO = NO-cNO;                                   % number of uniform outliers
        NC = round(xrand(1,1,[0.5,3.5]));               % number of clusters
        cnum = round(xrand(1,NC,[0.5,NO]));
        cnum = round(cnum/sum(cnum)*cNO);               % number of outliers in each clsuter
        cO = [];                                        % clustered outliers
        for iter=1:size(cnum,2)
            cen = xrand(1,2,[-2 2]);                    % randomly generate cluster centers
            range = xrand(1,2,[3*noise 9*noise]);           
            cluster = [xrand(1,cnum(iter),[cen(1) cen(1)+range(1)]);xrand(1,cnum(iter),[cen(2) cen(2)+range(2)])];
            cO = [cO cluster];
        end
        x= randn(1,npt+uNO);                            % randomly generate inliers and uniform outliers
        angle=xrand(1,1,[-pi/2,pi/2]);                  % randomly generate rotation angle
        ks=tan(angle);                                  % line parameters
        b=median(x);
        y=ks*x(1:npt)+repmat(b,1,npt);
        ymin=min(y(:));
        ymax=max(y(:));
        gt=[ks b];                                      % ground truth

        if uNO~=0                                       % add random errors to generate uniform outliers
            uO = xrand(1,uNO,[ymin ymax]);
            y = [y, uO];
        end
        n=randn(1,npt+uNO)*noise;                       % add Guassian noise
        y=y+n;
        x=[x,cO(1,:)];
        y=[y,cO(2,:)];
        M=[x' y'];
        save matches_line.txt M -ascii

        %% tukey+IRLS method
        [x_,model]=IRLS_Tukey(x,y,ones(1,size(x,2)),100);       
        residuals=abs(x_-y);
        inliers=residuals<thre;
        % refinement based on inliers
        if isnan(model(1))||sum(inliers)<2
            model= [1;0];
        else
            [model,~]=Linefit(x(inliers),y(inliers),ones(1,sum(inliers)));
        end
        x_ = model(1)*x + repmat(model(2),1,size(x,2));
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt));
        if isnan(rms)
            RMS{1,1}(k,i)=thre;                         % the rmse of failed case is set to the threshold for better visualization
        else
            RMS{1,1}(k,i)=rms;
        end

        %% MCC method
        [model,x_] = MCC_LF(x,y);      
        residuals=abs(x_-y);
        inliers=residuals<thre;
        if isnan(model(1))||sum(inliers)<2
            model= [1;0];
        else
            [model,~]=Linefit(x(inliers),y(inliers),ones(1,sum(inliers)));
        end
        x_ = model(1)*x + repmat(model(2),1,size(x,2));
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt));
        if isnan(rms)
            RMS{1,2}(k,i)=thre;
        else
            RMS{1,2}(k,i)=rms;
        end

        %% RANSAC method, refinement has been performed in the function of ransacLF
        [x_,model] = ransacLF(x,y,thre,'RANSAC');
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt));
        RMS{1,3}(k,i)=rms;

        %% GNC_GM method
        [model,x_] = GNC_GM_LF(x,y,1.3,thre);
        residuals=abs(x_-y);
        inliers=residuals<thre;
        if isnan(model(1))||sum(inliers)<2
            model= [1;0];
        else
            [model,~]=Linefit(x(inliers),y(inliers),ones(1,sum(inliers)));
        end
        x_ = model(1)*x + repmat(model(2),1,size(x,2));
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt));
        if isnan(rms)
            RMS{1,4}(k,i)=thre;
        else
            RMS{1,4}(k,i)=rms;
        end

        %% MAGSAC++ method, refinement has been performed in the implementation of MAGSAC++
        Cmd=['LineF\MAGSAC\MAGSAC_LF.exe' ' ' 'matches_line.txt' ' ' num2str(noise)];
        system(Cmd);
        A = load('res_line.txt');
        x_ = A(1)*x + repmat(A(2),1,size(x,2));
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt));
        RMS{1,5}(k,i)=rms;

        %% our AMCC method
        [model,x_] = AMCC_LF(x,y,thre,1.4);
        residuals=abs(x_-y);
        inliers=residuals<thre;
        if isnan(model(1))||sum(inliers)<2
            model= [1;0];
        else
            [model,~]=Linefit(x(inliers),y(inliers),ones(1,sum(inliers)));
        end
        x_ = model(1)*x + repmat(model(2),1,size(x,2));
        residuals=x_(:,1:npt)-y(:,1:npt);
        rms = norm(sqrt(sum(residuals.^2,2)./npt)); 
        if isnan(rms)
            RMS{1,6}(k,i)=thre;
        else
            RMS{1,6}(k,i)=rms;
        end
    end
end
plotResults(RMS, nTest, noise)



