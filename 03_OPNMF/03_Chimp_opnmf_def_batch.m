clc, clear
% SPM12 CAT12 batch for utilising chimpanzee to human deformation map to 
% deform chimp OPNMF solutions to human MNI space to conduct ARI similarity
% analyses

% working project directory %
wd = '/home/svickery/projects/chimp_human_opnmf/';

% chimp - human deformation field map location %
def_map = fullfile(wd, 'data', 'expansion', 'y_JunaChimp_brain.nii,1');

% all chimp OPNMF solutions %
% !!! OPNMF solutions need to be .nii to be used in spm batch !!! %
opnmf_imgs = dir(fullfile(wd, 'data', 'chimp', 'opnmf_parc', '*.nii'));

% batch options %
matlabbatch{1}.spm.tools.cat.tools.defs2.field = {def_map};
for subj = 1:numel(opnmf_imgs)
    matlabbatch{1}.spm.tools.cat.tools.defs2.images{subj,1} =  ...
        {fullfile(opnmf_imgs.folder , opnmf_imgs(subj).name)}';
end
    matlabbatch{1}.spm.tools.cat.tools.defs2.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{1}.spm.tools.cat.tools.defs2.vox = [3 3 3];
matlabbatch{1}.spm.tools.cat.tools.defs2.interp = 0;
matlabbatch{1}.spm.tools.cat.tools.defs2.modulate = 0;
