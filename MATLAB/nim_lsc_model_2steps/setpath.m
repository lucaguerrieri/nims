
restoredefaultpath


path1 = '.\utilities_2steps';
path2 = '..\estimation_utilities';
path3 = '..\plot_support';
path4 = '..\barbaraToolbox';

if isunix
    path1 = strrep(path1,'\','/');
    path2 = strrep(path2,'\','/');
    path3 = strrep(path3,'\','/');
    path4 = strrep(path4,'\','/');
end


path (path,path1);
path (path,path2);
path (path,path3);
path (path,path4);
