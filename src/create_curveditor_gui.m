function create_curveditor_gui(hObject,eventdata,handles)
global custom;  %default settings and customed settings
global sitename; %edi sites:number,sitename,location,
                 %freqs,impedence and tipper
hccmain=figure;
set(hccmain,'units','normalized','position',[0.2 0.1 0.7 0.8],'numbertitle','off',...
    'name','Sounding Curve Editor');
bcolor=get(hccmain,'color');
haa=axes('units','normalized','position',[0.08 0.55 0.65 0.4],'tag','axisa');
hab=axes('units','normalized','position',[0.08 0.07 0.65 0.4],'tag','axisb');
hac=axes('units','normalized','position',[0.8 0.65 0.18 0.3],'tag','axissite');
custom.currentsite=1;
%button group 'EDIT'
hbgedit=uibuttongroup(hccmain,'units','normalized','position',...
    [0.78 0.31 0.2 0.2],'title','edit','backgroundcolor',bcolor,...
    'tag','','fontweight','bold');
hcboxedit=uicontrol(hbgedit,'style','checkbox','units','normalized','position',...
    [0.05 0.8 0.5 0.2],'string','enable edit','tag','enable edit mode', ...
    'backgroundcolor',bcolor,'tooltipstring','enable edit mode');
hmaskx=uicontrol(hbgedit,'style','radiobutton','units','normalized','position',...
    [0.05 0.45 0.45 0.2],'string','mask x','tag','maskx', ...
    'backgroundcolor',bcolor,'tooltipstring','enable mask mode',...
    'enable','off');
hmasky=uicontrol(hbgedit,'style','radiobutton','units','normalized','position',...
    [0.05 0.1 0.45 0.2],'string','mask y','tag','masky', ...
    'backgroundcolor',bcolor,'tooltipstring','enable mask mode',...
    'enable','off');
hgmaskx=uicontrol(hbgedit,'style','radiobutton','units','normalized','position',...
    [0.55 0.45 0.45 0.2],'string','Gmask X','tag','Gmask X', ...
    'backgroundcolor',bcolor,'tooltipstring','enable group mask mode',...
    'enable','off');
hgmasky=uicontrol(hbgedit,'style','radiobutton','units','normalized','position',...
    [0.55 0.1 0.45 0.2],'string','Gmask Y','tag','Gmask Y', ...
    'backgroundcolor',bcolor,'tooltipstring','enable group mask mode',...
    'enable','off');
hgmaskall=uicontrol(hbgedit,'style','radiobutton','units','normalized','position',...
    [0.55 0.8 0.45 0.2],'string','Gmask All','tag','Gmask All', ...
    'backgroundcolor',bcolor,'tooltipstring','enable group mask mode',...
    'enable','off');

%button group 'IMPEDANCE'
hbgimpedance=uibuttongroup(hccmain,'units','normalized','position',...
    [0.78 0.10 0.2 0.2],'title','impedance & tipper','backgroundcolor',bcolor,...
    'tag','','fontweight','bold');
hZxxyy=uicontrol(hbgimpedance,'style','radiobutton','units','normalized','position',...
    [0.05 0.7 0.6 0.25],'string','Zxx & Zyy','tag','plot Zxx & Zyy', ...
    'backgroundcolor',bcolor,'tooltipstring','plot Zxx & Zyy');
hZxyyx=uicontrol(hbgimpedance,'style','radiobutton','units','normalized','position',...
    [0.05 0.4 0.6 0.25],'string','Zxy & Zyx','tag','plot Zxy & Zyx', ...
    'backgroundcolor',bcolor,'tooltipstring','plot Zxy & Zyx');
hTxTy=uicontrol(hbgimpedance,'style','radiobutton','units','normalized','position',...
    [0.05 0.1 0.6 0.25],'string','Tx & Ty','tag','plot Tx & Ty', ...
    'backgroundcolor',bcolor,'tooltipstring','plot Tx & Ty');

% other buttons
hpbprevious=uicontrol(hccmain,'style','pushbutton','units','normalized','position',...
    [0.78 0.52 0.06 0.05],'string','prev','tag','previous site');
hpbnext=uicontrol(hccmain,'style','pushbutton','units','normalized','position',...
    [0.85 0.52 0.06 0.05],'string','next','tag','next site');
hpbselect=uicontrol(hccmain,'style','pushbutton','units','normalized','position',...
    [0.92 0.52 0.06 0.05],'string','select','tag','select site');
hpbset_flist=uicontrol(hccmain,'style','pushbutton','units','normalized','position',...
    [0.79 0.03 0.08 0.05],'string','Set Freq table','tag','Set Freq table');
hpbquit=uicontrol(hccmain,'style','pushbutton','units','normalized','position',...
    [0.89 0.03 0.08 0.05],'string','DONE','tag','done');


htext=uicontrol(hccmain,'style','text','units','normalized','position',...
    [0.84 0.58 0.08 0.03],'string',sitename{custom.currentsite},...
    'backgroundcolor',bcolor);

% put all handles into a structure
handle.axis=[haa,hab,hac];
handle.buttons=[hpbprevious,hpbnext,hpbset_flist,hpbquit,hpbselect];
handle.Zbox=[hZxxyy,hZxyyx,hTxTy];
handle.editbox=[hmaskx,hmasky,hgmaskx,hgmasky,hgmaskall];
handle.parent=handles;
handle.text=htext;
handle.init= uisuspend(gcf);
handle.check=hcboxedit;
handle.figure=hccmain;

% set ui callbacks
set(hpbquit,'callback',{@quit_this,hccmain});
set(hpbset_flist,'callback',{@view_flist,handle.parent});
set(hcboxedit,'callback',{@enable_edit_curve,handle});
set(hmaskx,'callback',{@Zedit,handle,'maskx'});
set(hgmaskx,'callback',{@Zedit,handle,'gmaskx'});
set(hmasky,'callback',{@Zedit,handle,'masky'});
set(hgmasky,'callback',{@Zedit,handle,'gmasky'});
set(hgmaskall,'callback',{@Zedit,handle,'gmaskall'});

set(hpbprevious,'callback',{@previous_site,handle});
set(hpbnext,'callback',{@next_site,handle});
set(hpbselect,'callback',{@select_site,handle});
set(hZxxyy,'callback',{@plot_sounding,handle,'xxyy'});
set(hZxyyx,'callback',{@plot_sounding,handle,'xyyx'});
set(hTxTy,'callback',{@plot_sounding,handle,'txty'});

% start ploting
subplot_site(hObject,eventdata,handle.axis(3));
plot_sounding(hObject,eventdata,handle,'xyyx');
set(handle.Zbox,'value',0);
set(handle.Zbox(2),'value',1);
return
