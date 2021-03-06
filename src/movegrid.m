function movegrid(hObject,eventdata,handles,opt,tool)
% callback function used to adjust 2D grid (x,y, or z mode)
% this callback is added to main axis (handles.axis)
% use opt 'off' to stop callback function
switch nargin
case 2
    error('Must Specify a handle to a line object')
case 3
    opt='x';
case 4
    if ~any(strcmp(opt,{'x','y','z','off'}))
        error(['Second argument ''' opt ''' is an unknown command option.'])
    end
end
h=findobj(handles.axis,'type','surface');
if nargin<5  % i.e. user-invoked.  
    b=get(h,'tag');
    if ~isempty(b)&strcmp(b,'movegrid')&(nargin==1|strcmp(opt,'off'))  % function being de-invoked
        k=get(h,'userdata');
        %  acw modified to recall buttondownfcn and restore when turned off
        set(h,'buttondownfcn',k.bdfcn,'userdata','','tag','');
    else % function being invoked
        if isempty(b)
    %lala
        else 
            k=get(h,'userdata');
        end
        k.opt=opt;
        k.bdfcn=get(h,'buttondownfcn'); % save the current buttondownfcn before reset
        set(h,'buttondownfcn',{@movegrid, handles, opt, 1},'userdata',k,'tag','movegrid');
        set(findobj('children',h),'units','pixels')
    end
else  % i.e. self-invoked
    if strcmp(get(gcf,'selectiontype'),'open')
        k=get(h,'userdata');
        %  acw modified to recall buttondownfcn and restore when turned off
        set(h,'buttondownfcn',k.bdfcn,'userdata','','tag','');
        % ==================BUG=================== %
        % movegird(h,'off'); %it's strange that movegrid can not call itself...
    else
        switch tool
        case 1 % line's buttondownfcn invoked
            cp=get(gca,'currentpoint');
            k=get(h,'userdata');
            switch opt
                case 'y'% EAST-WEST(right-left) DIRECTION
                    dy=abs(get(h,'xdata')-cp(1,1));% determine which x grid the user clicked on
                    k.index=find(dy(1,:)==min(dy(1,:)));% the most close grid
                case 'x'% NORTH-SOUTH(up-down) DIRECTION
                    dx=abs(get(h,'ydata')-cp(2,2));% determine which x grid the user clicked on
                    k.index=find(dx(:,1)==min(dx(:,1)));% the most close grid
                case 'z'% TOP-BOTTOM(up-down) DIRECTION
                    %please note that 'z' here is actrually stored in
                    %'ydata'.
                    dz=abs(get(h,'ydata')-cp(2,2));% determine which y grid the user clicked on
                    k.index=find(dz(:,1)==min(dz(:,1)));% the most close grid
            end
            k.axesdata=get(gca,'userdata');
            k.doublebuffer=get(gcf,'doublebuffer');
            k.winbmfcn = get(gcf,'windowbuttonmotionfcn');  %  save current window motion function
            k.winbupfcn = get(gcf,'windowbuttonupfcn');  %  save current window up function
            k.winbdfcn = get(gcf,'windowbuttondownfcn');  %  save current window down function
            
            set(h,'userdata',k);
            set(gcf,'windowbuttonmotionfcn',{@movegrid, handles, opt, 2},'doublebuffer','on');
            set(gca,'userdata',h);
            set(gcf,'windowbuttonupfcn',{@movegrid, handles, opt, 3});
            set(gcf,'Pointer','fullcross');
            
            
            %         end    
        case 2 % button motion function
            k=get(h,'userdata');
            cp=get(gca,'currentpoint');
            x=get(h,'xdata');
            y=get(h,'ydata');
            switch opt
            case 'y'% EAST-WEST(right-left) DIRECTION
                x(:,k.index)=cp(1,1);
                if k.index>1&x(1,k.index)<x(1,k.index-1)%see if the grid goes over the previous one
                    x(:,k.index)=x(:,k.index-1)+1;%if so, force it back
                    %disp('hohoe')%for debug
                end
                if k.index<length(x(1,:))&x(1,k.index)>x(1,k.index+1)%see if the grid goes over the next one
                    x(:,k.index)=x(:,k.index+1)-1;%if so, force it back
                    %disp('hohoe')%for debug
                end
            case 'x'% NORTH-SOUTH(up-down) DIRECTION
                y(k.index,:)=cp(2,2);
                if k.index>1&y(k.index,1)<y(k.index-1,1)%see if the grid goes over the previous one
                    y(k.index,:)=y(k.index-1,:)+1;%if so, force it back
                    %disp('hohoe')%for debug
                end
                if k.index<length(y(:,1))&y(k.index,1)>y(k.index+1,1)%see if the grid goes over the next one
                    y(k.index,:)=y(k.index+1,:)-1;%if so, force it back
                    %disp('hohoe')%for debug
                end
            case 'z'% TOP-BOTTOM(up-down) DIRECTION
                z=y;
                z(k.index,:)=cp(2,2);
                if k.index>1&z(k.index,1)>z(k.index-1,1)%see if the grid goes over the previous one
                    z(k.index,:)=z(k.index-1,:)-1;%if so, force it back
                    %disp('hohoe')%for debug
                end
                if k.index<length(z(:,1))&z(k.index,1)<z(k.index+1,1)%see if the grid goes over the next one
                    z(k.index,:)=z(k.index+1,:)+1;%if so, force it back
                    %disp('hohoe')%for debug
                end
                y=z;
            end
            
            set(h,'xdata',x,'ydata',y);
            % test to see if a grid moved off the screen - update limits
            fgx=get(gca,'xlim');
            fgy=get(gca,'ylim');
            if any(opt=='y')&&cp(2,2)>fgy(2)&&k.index==length(x(:,1))
                set(gca,'ylim',[fgy(1) cp(2,2)])
            end
            if any(opt=='y')&&cp(2,2)<fgy(1)&&k.index==1
                set(gca,'ylim',[cp(2,2) fgy(2)])
            end
            if any(opt=='x')&&cp(1,1)>fgx(2)&&k.index==length(y(1,:))
                set(gca,'xlim',[fgx(1) cp(1,1)])
            end
            if any(opt=='x')&&cp(1,1)<fgx(1)&&k.index==1
                set(gca,'xlim',[cp(1,1) fgx(2)])
            end
            if any(opt=='z')&&cp(1,1)>fgx(2)&&k.index==length(y(1,:))
                set(gca,'xlim',[fgx(1) cp(1,1)])
            end
            if any(opt=='z')&&cp(1,1)<fgx(1)&&k.index==1
                set(gca,'xlim',[cp(1,1) fgx(2)])
            end
            switch opt
                case 'y'%EAST-WEST(left-right) direction
                    title(['E-W: ' num2str(cp(1,1)) ' m']);
                case 'x'%NORTH-SOUTH(up-down) direction            
                    title(['N-S: ' num2str(cp(1,2)) ' m']);
                case 'z'%TOP-BOTTOM(up-down) direction            
                    title(['Depth: ' num2str(cp(1,2)) ' m']);
            end
        case 3 % button up - we're done
            k=get(h,'userdata');
            set(gca,'userdata',k.axesdata); % restore axes data to its previous value
            set(gcf,'windowbuttonupfcn',k.winbupfcn,'doublebuffer',k.doublebuffer);
            set(gcf,'windowbuttonmotionfcn','');% kill the button motion function
            set(gcf,'Pointer','arrow');
        end
    end
end

