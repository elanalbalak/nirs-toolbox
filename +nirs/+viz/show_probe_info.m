function show_probe_info(probe)

colin=nirs.registration.Colin27.mesh_V2;
f=figure;
ax=subplot(2,2,2);
hold on;
p=probe.draw3d_ballandstick(ax);


set(f,'Tag','ShowProbeGUI');

c=colin(end).draw([],[],[],[],ax);

rois=colin(end).labels.keys;
cnt=uicontrol(f,Style="popupmenu",String=rois);
set(cnt,"Units",'normalized','Position',[0.1 .80 .3 .1]);

labels=colin(end).labels(rois{1});
cnt2=uicontrol(f,Style="popupmenu",String=labels.Label);
set(cnt2,"Units",'normalized','Position',[0.1 .70 .3 .1]);

cnt3=uitable(f);
set(cnt3,'Units','normalized','Position',[.1 .1 .3 .6]);

cnt4=uicontrol(f,'Style','text');
set(cnt4,'Units','normalized','Position',[.1 .05 .3 .05],'HorizontalAlignment','left');


UserData.probe=probe;
UserData.probe_handles=p;
UserData.mesh_handles=c;
UserData.labels=colin(end).labels;
UserData.ROI_popup=cnt;
UserData.Label_popup=cnt2;
UserData.test_box=cnt4;
UserData.table=cnt3;

set(cnt,'Callback',@change_roi)
set(cnt2,'Callback',@change_label);

ax2=subplot(2,2,4);
nirs.util.depthmap(cnt2.String{cnt2.Value},probe,{cnt.String{cnt.Value}},ax2);
UserData.depth_axis=ax2;
set(f,'UserData',UserData);

set(ax,'Units','normalized');
set(ax,'Position',[.45 .4 .5 .6]);

redraw_probe;
axis(ax,'off');

return;


function change_roi(varargin)

fig=findobj('type','figure','tag','ShowProbeGUI');
UserData=get(fig,'UserData');
key=UserData.ROI_popup.String{UserData.ROI_popup.Value};

labels=UserData.labels(key);
set(UserData.Label_popup,'Value',1,'String',labels.Label)

redraw_probe;

return

function change_label(varargin)

redraw_probe;

return


function redraw_probe(varargin)

fig=findobj('type','figure','tag','ShowProbeGUI');
UserData=get(fig,'UserData');
key=UserData.ROI_popup.String{UserData.ROI_popup.Value};
labels=UserData.labels(key);
regionIdx=UserData.Label_popup.Value;

FaceColor=ones(size(UserData.mesh_handles.Vertices,1),3)*.9;
i=labels.VertexIndex{regionIdx};
FaceColor(i,1)=1;
FaceColor(i,2:3)=0;
set(UserData.mesh_handles,'FaceColor','interp');
set(UserData.mesh_handles,'FaceVertexCdata',FaceColor);

str=[key ': ' labels.Label{regionIdx} ' (' labels.Region{regionIdx} ')'];
set(UserData.test_box,'String',str)

tbl=nirs.util.convertlabels2roi(UserData.probe,labels.Label{regionIdx},key);

set(UserData.table,"Data",tbl)
set(UserData.test_box,'FontWeight','bold','FontSize',14);

colormap=hot(height(tbl));
colormap=colormap(end:-1:1,:);
linecolorIdx=tbl.weight;
[~,idx]=sort(linecolorIdx);
linecolors=zeros(height(tbl),3);
for i=1:length(idx)
    if(isnan(linecolorIdx(idx(i))))
        linecolors(idx(i),2)=1;
    else
        linecolors(idx(i),:)=colormap(i,:);
    end
end
for i=1:length(UserData.probe_handles)
    set(UserData.probe_handles(i),"FaceColor",linecolors(i,:))
end

nirs.util.depthmap(labels.Label{regionIdx},UserData.probe,{key},UserData.depth_axis);


return


