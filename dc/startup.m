fprintf('\n startup.m entered \n');

% update toolboxcache
rehash toolboxcache

% unicode support
feature('DefaultCharacterSet', 'UTF8')


%% Make good figures

% good colormap
set(0,'DefaultFigureColormap',flipud(cbrewer('div', 'RdYlGn', 32)));

% figure properties
%set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultFigureColor','w')
set(0,'DefaultFigureRenderer','zbuffer')
set(0,'DefaultFigurePaperPositionMode', 'auto');
set(0,'DefaultTextFontName', 'TeXGyrePagella');
set(0,'DefaultTextColor','k')
set(0,'DefaultTextFontSize',14)

% axes
set(0,'DefaultAxesFontName','TeXGyrePagella')
set(0,'DefaultAxesFontWeight','normal')
set(0,'DefaultAxesTickLength'  , [.01 .01]);
set(0,'DefaultAxesLineWidth'  , 1);
set(0,'DefaultAxesFontSize',12)
set(0,'DefaultAxesBox','on')
set(0,'DefaultAxesTickDir','out')
%set(0,'DefaultAxesXMinorTick','on')
%set(0,'DefaultAxesYMinorTick','on')
%set(0,'DefaultAxesZMinorTick','on')
set(0,'DefaultAxesXColor',[.3 .3 .3])
set(0,'DefaultAxesYColor',[.3 .3 .3])
set(0,'DefaultAxesZColor',[.3 .3 .3])
set(0,'DefaultAxesLineWidth',1.5)
set(0,'DefaultLineLineWidth',1.5);

%% change to current working dir
cd('E:\Work\eddyshelf\');

