function [ output ] = graphViz( Ifile )
    output = mkdotfile(Ifile, 'output.txt');
    ha = axes;
    mGraphViz(output, ha);
end

