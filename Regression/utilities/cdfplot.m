function cdfplot(X)
    tmp = sort(reshape(X,prod(size(X)),1));
    Xplot = reshape([tmp tmp].',2*length(tmp),1);

    tmp = [1:length(X)].'/length(X);
    Yplot = reshape([tmp tmp].',2*length(tmp),1);
    Yplot = [0; Yplot(1:(end-1))];

    figure(gcf);
    plot(Xplot, Yplot);
    grid on
    title('Cumulative Density Function')
    xlabel('Accuracy')
    ylabel('%')
end


