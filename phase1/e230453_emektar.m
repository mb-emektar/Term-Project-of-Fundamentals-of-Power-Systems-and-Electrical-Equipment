function [S_base, V_base, N_circuit , N_bundle, d_bundle, length, conductor_name, outside_diameter, RAC , GMR_conductor] = e230453_emektar(text_path, library_path)
    
%read cvs file
table = readtable(library_path);

%get numaric values
opts = detectImportOptions(text_path); 
opts.DataLines = [1 32];
values = table2array(readtable(text_path,opts));

% get conductor name
fid=fopen(text_path); 
linenum = 14;
c_name_cell = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
c_name = string(c_name_cell);

%find the position of the conductor name on the table
c_names = table2cell(table(:,1));
index = find(contains(c_names,c_name));

%find necessary values from table with row of the found position in the previous part
o_dia_raw = table2array(table(index,5));
R_AC_raw = table2array(table(index,7));
GMR_raw = table2array(table(index,8));

%necessary unit and type conversions
o_dia = o_dia_raw*(0.0254);
R_AC = R_AC_raw*(1/1609.34);
GMR = GMR_raw*(0.3048);
values(2) = values(2)*1000000 ;
values(4) = values(4)*1000;
values(12) = values(12)*1000;

S_base = values(2);
V_base = values(4);
N_circuit = values(6);
N_bundle = values(8);
d_bundle = values(10);
length = values(12);
conductor_name = c_name;
outside_diameter = o_dia;
RAC =  R_AC;
GMR_conductor = GMR;

end