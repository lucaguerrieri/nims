
restoredefaultpath


path1 = '.\utilities_2steps';
path2 = '..\estimation_utilities';
path3 = '..\plot_support';

if isunix
    path1 = strrep(path1,'\','/');
    path2 = strrep(path2,'\','/');
    path3 = strrep(path3,'\','/');
end


path (path,path1);
path (path,path2);
path (path,path3);
