clc, clear
%  ------------------------------------------------------------------------
%  Human batch options that can be changed in the GUI or here directly
%  ------------------------------------------------------------------------
% set the number of cores for parallel processing 
try
  numcores = max(cat_get_defaults('extopts.nproc'),1);
catch
  numcores = 0;
end
%% CAT preprocessing 
%  ------------------------------------------------------------------------
% Dir containing eNKI or IXI (human) original T1w images %
human_dir = ...
    '~/project/chimp_human_opnmf/data/IXI/mwp1'; % /IXI/ or /eNKI/
% human (eNKI or IXI) images %
human_img = dir(fullfile(human_dir,'*.nii'));
% IMG need to be in a cell to be read by batch %    
for subj = 1:numel(human_img)
   matlabbatch{1}.spm.tools.cat.estwrite.data{subj,1} = ...
        fullfile(human_dir, human_img(subj).name);
end
% Check name and location of template dir in SPM dir %
% This should be the dir with cat v1725
cattempdir = fullfile(spm('dir'),'toolbox','cat12','animal_templates');
% CAT preprocessing expert options
% SPM parameter
matlabbatch{1}.spm.tools.cat.estwrite.data_wmh                            = {''};
matlabbatch{1}.spm.tools.cat.estwrite.nproc                               = numcores;
matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm                            = {fullfile(spm('dir'),'tpm','TPM.nii')}; % Human TPM 
matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg                         = 'mni';
matlabbatch{1}.spm.tools.cat.estwrite.opts.biasstr                        = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.opts.accstr                         = 0.75;

% segmentation options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.restypes.optimal = [1 0.3];
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.setCOM         = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.APP            = 1070;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.affmod         = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.NCstr          = -Inf;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.spm_kamap      = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.LASstr         = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.LASmyostr      = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.gcutstr        = 2;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.cleanupstr     = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.BVCstr         = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.WMHC           = 2;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.SLC            = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.segmentation.mrf            = 1;

% registration options
% used 1mm shooting template provided by Christian Gaser  'Template_0_GS1mm.nii' %
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.shootingtpm = {fullfile(spm('dir'),'toolbox','cat12','templates_MNI152NLin2009cAsym','Template_0_GS.nii')};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.regstr = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.vox            = 1;  % Downsample to 3mm for faster OPNMF processing
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.bb             = 45;

% surface options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtres              = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.pbtmethod           = 'pbt2x';
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.SRP                 = 22;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.reduce_mesh         = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.vdist               = 2;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.scale_cortex        = 0.7;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.add_parahipp        = 0.1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.surface.close_parahipp      = 1;

% admin options
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.experimental          = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.new_release           = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.lazy                  = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.ignoreErrors          = 1;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.verb                  = 2;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.admin.print                 = 2;

% output options
matlabbatch{1}.spm.tools.cat.estwrite.output.BIDS.BIDSno                  = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.surface                      = 0;    % surface reconstruction - not yet optimised for non-human primates 
matlabbatch{1}.spm.tools.cat.estwrite.output.surf_measures                = 3;

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
matlabbatch{2}.spm.spatial.smooth.fwhm                                   = repmat(6,1,3);  % smoothing filter size 4x4x4
matlabbatch{2}.spm.spatial.smooth.dtype                                  = 0;
matlabbatch{2}.spm.spatial.smooth.im                                     = 0;
matlabbatch{2}.spm.spatial.smooth.prefix                                 = 's6_';
%  ------------------------------------------------------------------------

%%
% Use to directly run script keep commented out if want to adapt using GUI
%spm_jobman('run',matlabbatch);
