text_path = 'D:\Yeni klasör1\METU EE\3.2\374\regular\Term_Project\Input_file_example3.txt';
library_path = 'D:\Yeni klasör1\METU EE\3.2\374\regular\Term_Project\library.csv';

%///////////////////////////////////PHASE 1///////////////////////////////////////////
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
GMR_cond = GMR_raw*(0.3048);
values(2) = values(2)*1000000 ;
values(4) = values(4)*1000;
values(12) = values(12)*1000;

%///////////////////////////////////PHASE 2///////////////////////////////////////////
n_cct = values(6);
n_cond = values(8);

% /////////// GMR of Bundle calculation ///////////
b_dist = values(10) ;

if n_cond == 1 
    gmr_bundle = GMR_cond;
elseif n_cond == 2 
    gmr_bundle = (GMR_cond*b_dist)^(1/2); 
elseif n_cond == 3 
    gmr_bundle = (GMR_cond*b_dist*b_dist)^(1/3); 
elseif n_cond == 4 
    gmr_bundle = (GMR_cond*b_dist*b_dist*sqrt(2)*b_dist)^(1/4);    
elseif n_cond == 5 
    gmr_bundle = (GMR_cond*b_dist*b_dist* (b_dist*(1+sqrt(5))/2) * (b_dist*(1+sqrt(5))/2) )^(1/5);    
elseif n_cond == 6 
    gmr_bundle = (GMR_cond*b_dist*b_dist* 2*b_dist * b_dist*sqrt(3) * b_dist*sqrt(3) )^(1/6);    
elseif n_cond == 7 
    gmr_bundle = (GMR_cond*b_dist*b_dist *(b_dist/(2*sin(pi/14))) *(b_dist/(2*sin(pi/14))) *2*b_dist*cos(pi/7) *2*b_dist*cos(pi/7))^(1/7);  
elseif n_cond == 8 
    gmr_bundle = (GMR_cond*b_dist*b_dist *b_dist*sqrt(2+sqrt(2)) *b_dist*sqrt(2+sqrt(2)) *b_dist*(1+sqrt(2)) *b_dist*(1+sqrt(2)) *b_dist*sqrt(4+2*sqrt(2)))^(1/8);  
end

%/////////// sub-GMR and GMR calculations ///////////

x1 = values(16);
x2 = values(19);
x3 = values(22);

y1 = values(17);
y2 = values(20);
y3 = values(23);

if n_cct==1
    GMR = gmr_bundle;

elseif n_cct==2
    
    x4 = values(31);
    x5 = values(28);
    x6 = values(25);

    y4 = values(32);
    y5 = values(29);
    y6 = values(26);
    
    dist_aa = sqrt(abs(x1-x6)^2+abs(y1-y6)^2);
    dist_bb = sqrt(abs(x2-x5)^2+abs(y2-y5)^2);
    dist_cc = sqrt(abs(x3-x4)^2+abs(y3-y4)^2);
    
    gmr_aa = sqrt(gmr_bundle*dist_aa);
    gmr_bb = sqrt(gmr_bundle*dist_bb);
    gmr_cc = sqrt(gmr_bundle*dist_cc);
    
    GMR = (gmr_aa*gmr_bb*gmr_cc)^(1/3);
end

%/////////// GMD calculations///////////

dist_a1b1 = sqrt(abs(x1-x2)^2+abs(y1-y2)^2);
dist_b1c1 = sqrt(abs(x2-x3)^2+abs(y2-y3)^2);
dist_c1a1 = sqrt(abs(x3-x1)^2+abs(y3-y1)^2);

if n_cct==1
    GMD =(dist_a1b1*dist_b1c1*dist_c1a1)^(1/3);
    
elseif n_cct==2
    dist_a1b2 = sqrt(abs(x1-x5)^2+abs(y1-y5)^2);
    dist_a2b2 = sqrt(abs(x5-x6)^2+abs(y5-y6)^2);
    dist_a2b1 = sqrt(abs(x2-x6)^2+abs(y2-y6)^2);
    
    dist_b1c2 = sqrt(abs(x2-x4)^2+abs(y2-y4)^2);
    dist_b2c2 = sqrt(abs(x4-x5)^2+abs(y4-y5)^2);
    dist_b2c1 = sqrt(abs(x3-x5)^2+abs(y3-y5)^2);
    
    dist_c1a2 = sqrt(abs(x3-x6)^2+abs(y3-y6)^2);
    dist_c2a2 = sqrt(abs(x4-x6)^2+abs(y4-y6)^2);
    dist_c2a1 = sqrt(abs(x1-x4)^2+abs(y1-y4)^2);
    
    GMD_AB = ( dist_a1b1*dist_a1b2*dist_a2b2*dist_a2b1 )^(1/4);
    GMD_BC = ( dist_b1c1*dist_b1c2*dist_b2c2*dist_b2c1 )^(1/4);
    GMD_CA = ( dist_c1a1*dist_c1a2*dist_c2a2*dist_c2a1 )^(1/4);
    
    GMD = (GMD_AB*GMD_BC*GMD_CA)^(1/3);
end

% /////////// Resistance  calculation///////////
%ac_res_mi = table2array(table(index,7));
%ac_res = ac_res_mi *0.000621371192;
length = values(12);
%cond_area = pi*((table2array(table(index,5))*25.4)/2)^2;

resist = length*R_AC; 

% /////////// Reactance calculation///////////

induc = 2*10^(-7)*log(GMD/GMR);
reac = 2*pi*50*induc*length;

% /////////// Susceptence calculation///////////
eps = 8.8541878128*10^(-12);

if n_cct==1
    H12 =  sqrt(abs(x1-x2)^2+abs(y1+y2)^2);
    H13 =  sqrt(abs(x1-x3)^2+abs(y1+y3)^2);
    H23 =  sqrt(abs(x2-x3)^2+abs(y2+y3)^2);
    
    H1 = 2*y1;
    H2 = 2*y2;
    H3 = 2*y3;
    
elseif n_cct==2
    H12 = ( sqrt(abs(x1-x2)^2+abs(y1+y2)^2)*sqrt(abs(x1-x5)^2+abs(y1+y5)^2)*sqrt(abs(x6-x2)^2+abs(y6+y2)^2)*sqrt(abs(x6-x5)^2+abs(y6+y5)^2) )^(1/4);
    H13 = ( sqrt(abs(x1-x3)^2+abs(y1+y3)^2)*sqrt(abs(x1-x4)^2+abs(y1+y4)^2)*sqrt(abs(x6-x3)^2+abs(y6+y3)^2)*sqrt(abs(x6-x4)^2+abs(y6+y4)^2) )^(1/4);
    H23 = ( sqrt(abs(x2-x3)^2+abs(y2+y3)^2)*sqrt(abs(x2-x4)^2+abs(y2+y4)^2)*sqrt(abs(x5-x3)^2+abs(y5+y3)^2)*sqrt(abs(x5-x4)^2+abs(y5+y4)^2) )^(1/4);

    H1 = ( 2*y1 * 2*y6 * sqrt(abs(x1-x6)^2+abs(y1+y6)^2)*sqrt(abs(x6-x1)^2+abs(y6+y1)^2) )^(1/4);
    H2 = ( 2*y2 * 2*y5 * sqrt(abs(x2-x5)^2+abs(y2+y5)^2)*sqrt(abs(x5-x2)^2+abs(y5+y2)^2) )^(1/4);
    H3 = ( 2*y3 * 2*y4 * sqrt(abs(x3-x4)^2+abs(y3+y4)^2)*sqrt(abs(x4-x3)^2+abs(y4+y3)^2) )^(1/4);
end

req_cond = 0.7788*o_dia/2;

if n_cond == 1 
    req_bundle = req_cond;
elseif n_cond == 2 
    req_bundle = (req_cond*b_dist)^(1/2); 
elseif n_cond == 3 
    req_bundle = (req_cond*b_dist*b_dist)^(1/3); 
elseif n_cond == 4 
    req_bundle = (req_cond*b_dist*b_dist*sqrt(2)*b_dist)^(1/4);    
elseif n_cond == 5 
    req_bundle = (req_cond*b_dist*b_dist* (b_dist*(1+sqrt(5))/2) * (b_dist*(1+sqrt(5))/2) )^(1/5);    
elseif n_cond == 6 
    req_bundle = (req_cond*b_dist*b_dist* 2*b_dist * b_dist*sqrt(3) * b_dist*sqrt(3) )^(1/6);    
elseif n_cond == 7 
    req_bundle = (req_cond*b_dist*b_dist *(b_dist/(2*sin(pi/14))) *(b_dist/(2*sin(pi/14))) *2*b_dist*cos(pi/7) *2*b_dist*cos(pi/7))^(1/7);  
elseif n_cond == 8 
    req_bundle = (req_cond*b_dist*b_dist *b_dist*sqrt(2+sqrt(2)) *b_dist*sqrt(2+sqrt(2)) *b_dist*(1+sqrt(2)) *b_dist*(1+sqrt(2)) *b_dist*sqrt(4+2*sqrt(2)))^(1/8);  
end


if n_cct==1
    req = req_bundle;

elseif n_cct==2

    req_aa = sqrt(req_bundle*dist_aa);
    req_bb = sqrt(req_bundle*dist_bb);
    req_cc = sqrt(req_bundle*dist_cc);
    
    req = (req_aa*req_bb*req_cc)^(1/3);
end

capacitance = (2*pi*eps)/(log(GMD/req)-log( ((H12*H13*H23)^(1/3)) / ((H1*H2*H3)^(1/3)) ));
suscep = (2*pi*50*capacitance);

% /////////// pu calculation///////////
z_base = values(4)^2/values(2);

R_pu = resist / z_base
X_pu = reac / z_base
B_pu = suscep * length* z_base


out = [ R_pu, X_pu, B_pu ];
