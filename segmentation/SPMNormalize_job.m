%-----------------------------------------------------------------------
% Job saved on 10-Apr-2025 12:22:12 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.bbox.image = {'SET-LOCAL-DIRECTORY\01_Forward\00_h_InVivoAtlas_v10.4.nii,1'};
matlabbatch{1}.spm.util.bbox.bbdef.fov = 'fv';
matlabbatch{2}.spm.tools.oldnorm.estwrite.subj.source = {'SET-LOCAL-DIRECTORY\01_Forward\01_a_AvgPostWarp.nii,1'};
matlabbatch{2}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
matlabbatch{2}.spm.tools.oldnorm.estwrite.subj.resample = {'SET-LOCAL-DIRECTORY\01_Forward\01_a_AvgPostWarp.nii,1'};
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.template = {'SET-LOCAL-DIRECTORY\01_Forward\00_h_InVivoAtlas_v10.4.nii,1'};
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 0.24;
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0.24;
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'none';
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 2;
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
matlabbatch{2}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.bb(1) = cfg_dep('Get Bounding Box: BB', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','bb'));
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.vox = [0.08 0.08 0.08];
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.interp = 3;
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';
