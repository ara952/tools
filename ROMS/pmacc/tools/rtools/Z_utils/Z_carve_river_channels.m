function [rout, mask_rho, h] = Z_carve_river_channels(h, ...
    lon_rho, lat_rho, mask_rho, riverFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z_carve_river_channels.m  3/2009 Dave Sutherland
%
% This takes the positions in the riverFile and carves out channels and
% adjusts the mask in the gridfile. Used in make_grid.m.
%
% INPUT: riverFile is mat file with structure that contains info for each
%        river to carve out. It needs to include a structure "rivers" with
%        the fields:
%         lat - latitude of river positions along its length
%         lon = longitude of river positions along its length
%         name - river name
%         depth - minimum river depth (m)
%         width - maximum river width (# of cells)
%         dir - river direction (0 = E/W, 1 = N/S)
%         rpos - lat/lon of river source position (last of lat and lon)
%         sign - sign indication flow direction (-1 mean flow is negative,
%         +1 means flow is positive, i.e. if dir = 0 and sign = -1 the
%         river flows from east to west)
%         max_dist - maximum river width (km)
%
%   - other variables are from original grid (h, lat_rho, lon_rho,
%   mask_rho)
%
% OUTPUT: this m-file loads in grid and saves it again after altering
% the mask and bathy
% - also outputs new grid info and indices for each river source,
% and direction (0 for x, 1 for y)
%
% updated SNG Feb 15 2011 to avoid exporting any nans in the record, only
% changes were applied to the plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(riverFile); %this gives structure 'rivers'

num_rivers = length(rivers);

% now read in lat/lon, etc. from rivers and alter bathy and mask
for i = 1:num_rivers
    lon = rivers(i).lon; lat = rivers(i).lat;
    depth = rivers(i).depth; % depth is minimum depth to make river channel
    max_cellwidth = rivers(i).width;
    % width is maximum width to make river channel
    
    %interpolate between each point on river line
    % to ensure good grid coverage
    dx = sw_dist(lat,lon,'km')*1000;
    dd = 100; %resolution in meters of interpolation between points
    dn = round(dx./dd); %number of points between each specified lat/lon
    loni = linspace(lon(1),lon(2),dn(1))';
    lati = linspace(lat(1),lat(2),dn(1))';
    for k = 2:length(lon)-1
        a = linspace(lon(k),lon(k+1),dn(k))';
        b = linspace(lat(k),lat(k+1),dn(k))';
        loni = [loni;a];
        lati = [lati;b];
    end
    klat = dsearchn(lat_rho(:,1),lati); %get indices closest to grid points
    klon = dsearchn(lon_rho(1,:)',loni);
    %now need to make sure cells abut side to side and not at corners
    aa = diff([klon klat],1,1);
    ind = find(abs(aa(:,1))>=1 & abs(aa(:,2))>=1);
    %if both 1's, then faces aren't together
    while ~isempty(ind)
        add = [klon(ind(1)) klat(ind(1)) + aa(ind(1),2)];
        klon = [klon(1:ind(1)); add(1); klon(ind(1)+1:end)];
        klat = [klat(1:ind(1)); add(2); klat(ind(1)+1:end)];
        aa = diff([klon klat],1,1);
        ind = find(abs(aa(:,1))>=1 & abs(aa(:,2))>=1);
    end
    kgrid = [klon klat];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % now check resolution of grid cells where river point source is,
    % add more if less
    % than certain amount
    dist_limit = rivers(i).max_dist; %2 km
    posx = dsearchn(lon_rho(1,kgrid(:,1))',rivers(i).rpos(1));
    %point source longitude
    posx = kgrid(posx,1);
    sign(i) = rivers(i).sign;
    posy = dsearchn(lat_rho(kgrid(:,2),1),rivers(i).rpos(2));
    posy = kgrid(posy,2);
    pos = [lon_rho(posy,posx) lat_rho(posy,posx)];
    dist(1) = sw_dist([pos(2) lat_rho(posy+1,posx)],[pos(1) pos(1)],'km');
    dist = min(dist);
    numcells = 1; %number of grid cells to use
    while dist < dist_limit && numcells < max_cellwidth
        numcells = numcells + 1;
        distnew = sw_dist([pos(2) lat_rho(posy+numcells,posx)], ...
            [pos(1) pos(1)],'km');
        dist = [dist distnew]; dist = sum(dist);
    end
    %%%--------------------------------------------------------------------
    
    %%%%%%%%%%%%%% now set river position and direction from these indices
    %%% make channel = numcells wide
    allx = kgrid(:,1)'; ally = kgrid(:,2)';
    rout(i).X(1) = kgrid(end,1); %first point source
    rout(i).Y(1) = kgrid(end,2);
    rout(i).D = rivers(i).dir*ones(numcells,1);
    %if need to make channel wider than 1 grid cell
    mov = [-1;1;-2;2;-3;3;-4;4];
    if(numcells >= 2) % if need to add only one more point source
        for nn = 2:numcells
            if(rout(i).D(1)==1)
                allx2 = allx + mov(nn-1);
                ally2 = ally;
            elseif(rout(i).D(1)==0)
                allx2 = allx; %keep x indices
                ally2 = ally + mov(nn-1); %move down one grid point
            end
            rout(i).X(nn) = allx2(end); %first point source
            rout(i).Y(nn) = ally2(end);
            kgrid = [kgrid;[allx2(:) ally2(:)]];
        end
    end
    %
    rout(i).Y = rout(i).Y - 1; %puts onto u/v grid as needed
    rout(i).sign = sign(i)*ones(numcells,1);
    rout(i).id = i;
    if(1) %don't move in one point
        if rout(i).D(1) == 1; %direction along N/S (eta) direction
            if sign(i) == -1 %southward flow, move point in one
                rout(i).Y = rout(i).Y;
            else rout(i).Y = rout(i).Y-1;end
        elseif rout(i).D(1) == 0; %direction along E/W (x) direction
            if sign(i) == -1 %westward flow, move point in one
                rout(i).X = rout(i).X;
            else rout(i).X = rout(i).X-1;end
        end
    end %end this subsection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % next, alter bathy and mask at those points
    for j=1:length(kgrid(:,1))
        h(kgrid(j,2),kgrid(j,1)) = max(depth,h(kgrid(j,2),kgrid(j,1)));
        mask_rho(kgrid(j,2),kgrid(j,1)) = 1;
    end
    
end %end for i=1:num_rivers

