function tripleplot(data1a,data1b,data2,dates,thistitle)


line(dates,data1a,'Color','k');
hold on
line(dates,data1b,'Color','k');
hold off

ax1 = gca; 


set(ax1,'XColor','k','YColor','k')

xlim([dates(1) dates(end)])

%Next, create another axes at the same location as the first, placing the x-axis on top and the y-axis on the right. Set the axes Color to none to allow the first axes to be visible and color code the x- and y-axis to match the data.
ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','w','YColor','r','LineStyle','--','XTickLabel',{});

title(thistitle)

%Draw the second set of data in the same color as the x- and y-axis.


hl2 = line(dates,data2,'Color','r','lineStyle','--','Parent',ax2);
xlim([dates(1) dates(end)])