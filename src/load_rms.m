function load_rms(hObject,eventdata,handle)
% a script to display WSINVMT3D (and ModEM) rms iteration variance
% you will need the model files generated by WSINVMT3D.
% or the log file from ModEM
[cname cdir]=uigetfile({'*_model*','WSINVMT model file(*_model*)';...
    '*.log','ModEM log file(*.log)';...
    '*.*','All files(*.*)'},...
    'Choose WSMT3DINV/ModEM Output files', 'MultiSelect', 'on');
if ~iscell(cname)
    if cname==0;
        disp('user canceled...');
        return
    else
        cfilename=cname;
        % we are probably loading a ModEM log file
        % the easy part...
        fid=fopen([cdir,cfilename],'r');
        % now start reading ModEM log file
        disp('start reading ModEM log file');
        for n=1:10
            line=fgetl(fid); %try to skip comment lines at the file head
            if findstr(line,'START:')~=0
                p1=strfind(line,'rms=');
                p2=strfind(line,'lambda=');
                Arms=zeros(201,1); % maximum 200 iterations to be displayed
                Arms(1)=str2double(line(p1+4:p2-1));
                i=1;
                break
            elseif n==10
                disp(['initial RMS not found in ', num2str(n),...
                      ' lines, please check your log file'])
                return                
            end
        end
        while(~feof(fid))
            line=fgetl(fid);
            if findstr(line,'CG iteration')~=0
                line=fgetl(fid); % proceed to the next line
                p1=strfind(line,'rms=');
                p2=strfind(line,'lambda=');
                i=i+1;
                Arms(i)=str2double(line(p1+4:p2-1));
            elseif findstr(line,'Exiting...')~=0
                break
            end
        end
        Niter=i;
        disp('end reached')
        fclose(fid);
        plot(handle.axis,1:Niter,Arms(1:Niter),'-s','markersize',10);
        xlabel('iteration');
        ylabel('Root Mean Square misfit');
    end
else
    cfilename=char(cname);
    % we are probably loading WSINV3D model files
    % the hard part...
    nout=size(cfilename,1);
    sprintercell=zeros(3,nout);
    idat=zeros(3,1);
    for iout=1:nout    % get the iteration infomation from each model file.
        outname=[cdir,cfilename(iout,:)];
        fid=fopen(deblank(outname),'r');
        if ~feof(fid)
            line=fgetl(fid);
        end
        ptr0=strfind(line,'No.');
        ptr1=strfind(line,'RMS =');
        ptr2=strfind(line,'LM =');
        idat(1)=str2double(deblank(line(ptr0+3:ptr1-1)));
        if  isempty(ptr2);
            idat(2)=str2double(deblank(line(ptr1+5:end)));
            idat(3)=0;
        else
            idat(2)=str2double(deblank(line(ptr1+5:ptr2-1)));
            idat(3)=str2double(deblank(line(ptr2+4:end)));
        end
        fclose(fid);
        sprintercell(:,iout)=idat;
    end
    hold(handle.axis,'on')
    sprintercell=sortrows(sprintercell.',1)';
    i=1;
    for iout=1:nout
        if sprintercell(3,iout)~=0 % rip the "final model" of each iteration
            tsc(:,i)=sprintercell(:,iout);
            i=i+1;
        end
    end
    % currently no more than 15 iterations supported
    colortab=[0 0 1; 0 1 0; 1 0 0; 1 1 0; 0 0 0; 1 0 1; 0 1 1;...
        0 0 0.5; 0 0.5 0; 0.5 0 0; 0.5 0.5  0; 0.5 0 0.5;...
        0 0.5 0.5; 0 1 0.5; 1 0 0.5;];
    ptr=1;
    % currently no more than 15 iterations supported
    Ilegend=cell(3,1);
    for i=1:15;
        Ilegend(i)={['Iteration ',num2str(i)]};
    end;
    % start ploting rms and lambda "iteration by iteration".
    for iout=1:size(tsc,2) 
        if iout==size(tsc,2) % or we got the last iteration
            temp=sortrows(tsc(:,ptr:iout).',3)';
            plot(handle.axis,temp(3,:),temp(2,:),'-s','LineWidth',2,'color',...
                colortab(temp(1,1),:),'markersize',10);
            ptr=iout+1;
            i=(temp(1,1));
        elseif tsc(1,iout)~=tsc(1,iout+1)% if we find a new iteration
            temp=sortrows(tsc(:,ptr:iout).',3)';
            plot(handle.axis,temp(3,:),temp(2,:),'-s','LineWidth',2,'color',...
                colortab(temp(1,1),:),'markersize',10);
            ptr=iout+1;
            i=(temp(1,1));
        end
    end
    grid on;
    set(handle.axis,'xscale','log')
    legend(handle.axis,Ilegend(1:i));
    xlim(handle.axis,[ min(tsc(3,:))/2,max(tsc(3,:))*2])
    ylim(handle.axis,[0 ceil(max(tsc(2,:)))]);
    xlabel('\lambda Multiplier');
    ylabel('RMS');    
end
title(handle.axis,'Iteration RMS variation',...
    'fontsize',12)
hold(handle.axis,'off')
return


