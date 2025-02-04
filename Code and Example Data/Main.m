clear; close all;

%This the main matlab file to reproduce figures in 
% Z. Zhang, Y. Wu, D. Xiong, J. G. Ibrahim, A. Srivastava and Hongtu Zhu
% (2022). "LESA: Longitudinal  Elastic Shape  Analysis of  Brain
% Subcortical Structures", JASA. 

%% Load Example Data
currentFolder = pwd;
load Example_data.mat;

% The example data is from the OpenPain study (https://urldefense.com/v3/__https://openpain.org__;!!PhOWcWs!1XyUS01wuV_t_8bGJPgJH9Akh92HnMkagEdVB9Tq7Qm0Yj9KFPlbh75jcQ6i7dZYMHtMUzNWvqjPsogLnn8IYUE$ ). It contains 112 subjects aged from 21 to 68.
%  - F: 429 pre-processed and parameterized left ventricle surfaces of 112 subjects.  
%  - sparse_area: calculated area of the surfaces.
%  - sub_scan_age: ages of the subjects during each MRI scan.
%  - sub_times: total times of MRI scans for each subject (number of surfaces for each subject).
%  - mycolormap: color map used for surface trajectory visualization.


%% Surface Registration and Computing Karcher Mean with SRNF

% % This step registers the individual surfaces and estimates the Karcher
% % mean shape. 

% % It takes ~3 hours. In order to save running time, intermediate results 
% % are saved into step1_Registration_and_Mean.mat. Here we will load this file.

% % Load the saved results
load step1_Registration_and_Mean.mat;

% % If running this step is needed, please uncomment lines 35-37.
% % Parts of the codes for surface registration have only been compiled for
% % the Windows OS. 
% 
% addpath(genpath('./Registration/'));
% [muF,v] = Karcher_mean(F);
% cd(currentFolder);


%% PCA
% % This step conducts shape PCA. 
% 
% % It takes ~1.2 hour. To save time, intermediate results are already saved into 
% % step2_PCA.mat and step2_SPDM.mat. Here we directly load them:
load step2_PCA.mat;
load step2_SPDM.mat

%
% % If running this step is needed, please uncomment lines 51-54.

% [S,U,coef,sparse_coef]=surf_pca(v,muF,sub_times);

% % comparison with the SPHARM-PDM
% [S_SPDM,U_SPDM,coef_SPDM,v_SPDM,muF_SPDM]=spdm_pca(F);


%% Representation Efficiency
% Comparison of SRNF and SPHARM-PDM in the representation efficiency. 
% This step takes ~8 minutes.

[dist_elastic,dist_spdm] = repre_efficiency(U,coef,muF,v,U_SPDM,coef_SPDM,muF_SPDM,v_SPDM);

%% Figure 6
plot_repre_efficiency(dist_elastic,dist_spdm);

%% PACE Fitting
% PACE Package: https://urldefense.com/v3/__https://github.com/functionaldata/PACE_matlab__;!!PhOWcWs!1XyUS01wuV_t_8bGJPgJH9Akh92HnMkagEdVB9Tq7Qm0Yj9KFPlbh75jcQ6i7dZYMHtMUzNWvqjPsogLnbd7-8U$ 
% Yao, F., Müller, H.G., Wang, J.L. (2005). Functional data analysis for sparse longitudinal data. J. American Statistical Association 100, 577-590.
% This step takes ~1 minute.

addpath('./PACE_matlab-master/release2.17/PACE/');
[age_min,age_max,sparse_t,area_pred,area_mean_estimate,outa,coef_pred,...
    pc_mean_estimate,surf_estimate,surf_mean]=...
    pace_fitting(sub_scan_age,sparse_area,sparse_coef,38,muF,U);

%% Figure 5
% (a) Mean Surface
plot_mean(muF);
% (b) Cumulative percentage of variance
pc_num = plot_cumu_var(S);
% (c) 1st dominant PC
sliderplot_PC(muF,U,S,mycolormap);
% (d) Sparse area trajectories
plot_sparse_area(age_min,sparse_area,sparse_t);
% (e) Sparse PC1 trajectories
plot_sparse_PC(age_min,sparse_coef,sparse_t);

%% Figure 7
% Plot fitted area and PC1 score trajectories.
plot_PACE_area(age_min,age_max,area_pred,area_mean_estimate,outa);
plot_PACE_PC(age_min,age_max,coef_pred,pc_mean_estimate,outa);

%% Figure 8
% Plot fitted individual area, PC1 score, and surface trajectories.
idx = 95;
plot_individual_area(age_min,age_max,area_pred,area_mean_estimate,outa,sparse_t,sparse_area,idx);
plot_individual_PC(age_min,age_max,coef_pred,pc_mean_estimate,outa,sparse_t,sparse_coef,idx);
sliderplot_individual(surf_estimate{idx},mycolormap);

idx = 6;
plot_individual_area(age_min,age_max,area_pred,area_mean_estimate,outa,sparse_t,sparse_area,idx);
plot_individual_PC(age_min,age_max,coef_pred,pc_mean_estimate,outa,sparse_t,sparse_coef,idx);
sliderplot_individual(surf_estimate{idx},mycolormap);

%% Figure 9
% Plot recovered surface trajectory.
sliderplot_lifespan(surf_mean,mycolormap);
