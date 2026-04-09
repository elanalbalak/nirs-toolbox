function varargout=listAtlasRegions(labels)
%This function returns a list of the regions in the AAL atlas

if(nargin==0)
    mesh=nirs.registration.Colin27.mesh_V2;
    lst=nirs.util.listAtlasRegions(mesh(end).labels);
    %aalLabels=load(which('ROI_MNI_V5_List.mat'));
    %lst=strvcat(aalLabels.ROI.Nom_L);
else
    keys=labels.keys;
    lst={};
    lst2={};
    for i=1:length(keys)
        l=labels(keys{i});
        for j=1:length(l.Label)
            if(~isempty(l.Label{j}))
            lst{end+1}=l.Label{j};
            lst2{end+1}=keys{i};
            end
        end
    end
    lst=strvcat(lst);
    lst2=strvcat(lst2);
end

varargout{1}=lst;
if(nargout==2)
    varargout{2}=lst2;
end

return
