clc
clear

dir='F:TMS_data\T1_Nifti\sub05\tms_optimization_adm_IFG_smooth100';
cd(dir)
load('simNIBS_opt_coil_position.txt');
A=simNIBS_opt_coil_position; %coil orientation in BrainSight = specific transformation matrix - empirically determined and visually verified
% A=roundn(A,-3);
 A(1:3,1)=-A(1:3,1);
 A(1:3,3)=-A(1:3,3);
 
 A1=A(1:3,4)';
 A2=A(1:3,1)';
 A3=A(1:3,2)';
 A4=A(1:3,3)';
 
 B=[A1,A2,A3,A4];
 
 tmp1=strfind(dir,'adm_'); 
 
 filename = fopen('brainsight_coil_position_input.txt','w');
 fprintf(filename,'%6.4f	',B);
 fclose(filename);
 
%  save brainsight_coil_position.txt A -ascii
    fid=fopen('brainsight_coil_position_matrix.txt','w')
        [m,n]=size(A);
         for i=1:1:m
           for j=1:1:n
              if j==n
                fprintf(fid,'%6.4f\n',A(i,j));
             else
               fprintf(fid,'%6.4f\t',A(i,j));
              end
           end
        end
        fclose(fid);