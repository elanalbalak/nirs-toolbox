function probe_registation_info(probe,maxregions,regions,atlas)

mesh=probe.getmesh;
labels=mesh(end).labels;

if(nargin<2)
    maxregions=5;
end

if(nargin<4 || isempty(atlas))
    atlas=labels.keys;
else
    if(~iscell(atlas))
        atlas={atlas};
    end
end

allatlas=labels.keys;
rmatlas={allatlas{~ismember(allatlas,atlas)}};
labels=labels.remove(rmatlas);

if(nargin<3 || isempty(regions))
    [regions,keys]=nirs.util.listAtlasRegions(labels);
end

regions=cellstr(regions);
keys=cellstr(keys);

probe.link.type=[];
probe.link=unique(probe.link);
probe.link.type=808*ones(height(probe.link),1);

slab=nirs.forward.ApproxSlab;
slab.probe=probe;
slab.mesh=mesh(end);
slab.prop=nirs.media.tissues.brain(808);

J=slab.jacobian;

Names={};
ExtNames={};
Atlas={};
cnt=1;
Brain=zeros(size(mesh(end).nodes,1),length(regions));
for idx=1:length(regions)
    rois=labels(keys{idx});
    Ri=find(ismember(rois.Label,regions{idx}));
    if(length(Ri)==1)
        Names{cnt}=regions{idx};
        ExtNames{cnt}=rois.Region{Ri};
        Atlas{cnt}=keys{idx};
        Brain(rois.VertexIndex{Ri},cnt)=1;
        cnt=cnt+1;
    end
end

Brain(:,cnt+1:end)=[];

Weight=J.mua*Brain;
lst=find(sum(Weight,1)>max(sum(Weight,1))/40);

Names={Names{lst}};
ExtNames={ExtNames{lst}};
Atlas={Atlas{lst}};

Weight=Weight(:,lst);
Weight=Weight/max(Weight(:));

channels=cellstr(strcat('Src',num2str(probe.link.source),'-Det',num2str(probe.link.detector)));

Names=strrep(Names,'_',' ');

imagesc(Weight); colormap(gray);
set(gca,'XTick',[1:length(Names)], 'XTickLabel',Names,'XTickLabelRotation',90);
set(gca,'Ytick',[1:length(channels)],'YTickLabel',channels);
title('Relative region sensitivity');
colorbar;

for i=1:length(channels)
    fprintf(['<strong>' channels{i} '</strong>\r']);
    [val,idx]=sort(Weight(i,:),'descend');
    for j=1:maxregions
        if(val(j)>0)
            fprintf(['\t Weight=' sprintf('%.4f',val(j)) '\t\t' Names{idx(j)} ' (' ExtNames{idx(j)} ') ' Atlas{idx(j)} '\r']);
        end
    end
end

return 