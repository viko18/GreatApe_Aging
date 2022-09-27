clc, clear

%  ------------------------------------------------------------------------
%  Chimpanzee batch options that can be changed in the GUI or here directly
%  ------------------------------------------------------------------------
% open the chimpanzee preprocessing from cat12
cat12('chimpanzee');
% set the number of cores for parallel processing 
try
  numcores = max(cat_get_defaults('extopts.nproc'),1);
catch
  numcores = 0;
end
%% CAT preprocessing 
%  ------------------------------------------------------------------------
% Dir containing chimp original T1w images %
chimps_dir = ...
    'C:\Users\svickery\Documents\preproc_test';
% chimp images %
chimp_img = dir(fullfile(chimps_dir,'*.nii'));
% IMG need to be in a cell to be read by batch %    
for subj = 1:numel(chimp_img)
   matlabbatch{1}.spm.tools.cat.estwrite.data{subj,1} = ...
        fullfile(chimps_dir, chimp_img(subj).name);
end
% Check name and location of template dir in SPM dir %
% This should be the dir with cat v1725
cattempdir = fullfile(spm('dir'),'toolbox','cat12','animal_templates');
% CAT preprocessing expert options
% SPM parameter
matlabbatch{1}.spm.tools.cat.estwrite.data_wmh                            = {''};
matlabbatch{1}.spm.tools.cat.estwrite.nproc                               = numcores;
matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm                            = {fullfile(cattempdir,'chimpanzee_TPM.nii')}; % Juna chimp TPM 
matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg                         = 'none';
matlabbatch{1}.spm.tools.cat.estwrite.opts.ngaus                          = [1 1 2 3 4 2];
matlabbatch{1}.spm.tools.cat.estwrite.opts.warpreg                        = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.tools.cat.estwrite.opts.bias.spm.biasfwhm              = 30;      % small values are important to remove the bias but 30 mm is more or less the limit
matlabbatch{1}.spm.tools.cat.estwrite.opts.bias.spm.biasreg               = 0.001;   % 
matlabbatch{1}.spm.tools.cat.estwrite.opts.acc.spm.samp                   = 1.5;     % ############# higher resolutions helps but takes much more time (e.g., 1.5 about 4 hours), so 1.0 to 1.5 mm seems to be adequate  
matlabbatch{1}.spm.tools.cat.estwrite.opts.acc.spm.tol                    = 1e-06;   % smaller values are better and important to remove the bias in some image
matlabbatch{1}.spm.tools.cat.estwrite.opts.redspmres                      = 0;

% segmentation options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.APP            = 1070;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.NCstr          = -Inf;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.spm_kamap      = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.LASstr         = 1.0;  
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.gcutstr        = 2;     
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.cleanupstr     = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.BVCstr         = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.WMHC           = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.SLC            = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.mrf            = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.restypes.best  = [0.5 0.3]; 

% registration options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.T1             = {fullfile(cattempdir,'chimpanzee_T1.nii')};              % Juna chimp T1
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.brainmask      = {fullfile(cattempdir,'chimpanzee_brainmask.nii')};       % Juna chimp brainmask
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.cat12atlas     = {fullfile(cattempdir,'chimpanzee_cat.nii')};             % Juna chimp cat atlas
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.darteltpm      = {fullfile(cattempdir,'chimpanzee_Template_1.nii')};      % there is no Juna chimp Dartel template as shooting is much better
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.shootingtpm    = {fullfile(cattempdir,'chimpanzee_Template_0_GS.nii')};   % Juna chimp shooting template
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regstr         = 0.5;  
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.vox            = 2; % Downsample to 2mm for faster OPNMF processing

% surface options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtres              = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtmethod           = 'pbt2x';
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtlas              = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.collcorr            = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.reduce_mesh         = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.vdist               = 1.33333333333333;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.scale_cortex        = 0.7;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.add_parahipp        = 0.1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.close_parahipp      = 0;

% admin options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.experimental          = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.new_release           = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.lazy                  = 0; % ############## avoid reprocessing 
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.ignoreErrors          = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.verb                  = 2;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.print                 = 2;

% output options
matlabbatch{1}.spm.tools.cat.estwrite.output.surface                      = 0;    % surface reconstruction - not yet optimised for non-human primates 
matlabbatch{1}.spm.tools.cat.estwrite.output.surf_measures                = 3;

% volume atlas maps
matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.chimpanzee_atlas_davi = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.ROImenu.atlases.ownatlas     = {''}; % you can add own atlas maps but they have to be in the same orientation as the other template files especially the final GS template

% surface atlas maps
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Desikan    = 0;    
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Destrieux  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.HCP        = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_100P_17N = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_200P_17N = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_400P_17N = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.Schaefer2018_600P_17N = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.sROImenu.satlases.ownatlas   = {''};

% volume output
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.warped                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod                       = 1; % needed for VBM 
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.warped                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod                       = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.native                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.warped                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.mod                      = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.CSF.dartel                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.native                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.warped                  = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.dartel                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.jacobianwarped               = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.warps                        = [0 0];

% special maps 
matlabbatch{1}.spm.tools.cat.estwrite.output.ct.native                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.ct.warped                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.ct.dartel                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.pp.native                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.pp.warped                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.pp.dartel                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.native                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.warped                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.mod                      = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WMH.dartel                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.SL.native                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.SL.warped                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.SL.mod                       = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.SL.dartel                    = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.native                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.warped                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.mod                     = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.TPMC.dartel                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.atlas.native                 = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.atlas.warped                 = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.atlas.dartel                 = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.label.native                 = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.label.warped                 = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.label.dartel                 = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.las.native                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.las.warped                   = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.las.dartel                   = 0;

%  ------------------------------------------------------------------------

%% smoothing
%  ------------------------------------------------------------------------
matlabbatch{2}.spm.spatial.smooth.fwhm                                   = repmat(4,1,3);  % smoothing filter size 4x4x4
matlabbatch{2}.spm.spatial.smooth.dtype                                  = 0;
matlabbatch{2}.spm.spatial.smooth.im                                     = 0;
matlabbatch{2}.spm.spatial.smooth.prefix                                 = 's4_';
%  ------------------------------------------------------------------------

%%
% Use to directly run script keep commented out if want to adapt using GUI
%spm_jobman('run',matlabbatch);
