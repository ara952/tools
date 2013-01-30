% computes domain integral. accepts varying z grid but UNIFORM horizontal
% grid

function [out] = domain_integrate(in,xax,yax,zax)

    if isvector(xax) && isvector(yax) && isvector(zax)
        out = squeeze(trapz(xax,trapz(yax,trapz(zax,in,3),2),1));
        return
    end
    
    int_z = nan([size(zax,1) size(yax,2) size(in,4)]);
    for i=1:size(zax,1)
        for j=1:size(zax,2)
            int_z(i,j,:) = trapz(squeeze(zax(i,j,:)),squeeze(in(i,j,:,:)))';
        end
    end
    
    out = squeeze(trapz(xax(:,1,1),trapz(yax(1,:,1),int_z,2),1));