%-----------------------------------------------------------------------
% Job saved on 13-Jan-2026 22:48:26 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {'SET-LOCAL-DIRECTORY\NoiseImages\Sample_1'};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.filter = 'G*.nii';
matlabbatch{1}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPListRec';
matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('File Selector (Batch Mode): Selected Files (G*.nii)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.smooth.fwhm = [0 0 0];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's000_';
matlabbatch{3}.spm.spatial.smooth.data(1) = cfg_dep('File Selector (Batch Mode): Selected Files (G*.nii)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{3}.spm.spatial.smooth.fwhm = [0.15 0.15 0.15];
matlabbatch{3}.spm.spatial.smooth.dtype = 0;
matlabbatch{3}.spm.spatial.smooth.im = 0;
matlabbatch{3}.spm.spatial.smooth.prefix = 's150_';
matlabbatch{4}.spm.spatial.smooth.data(1) = cfg_dep('File Selector (Batch Mode): Selected Files (G*.nii)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{4}.spm.spatial.smooth.fwhm = [0.3 0.3 0.3];
matlabbatch{4}.spm.spatial.smooth.dtype = 0;
matlabbatch{4}.spm.spatial.smooth.im = 0;
matlabbatch{4}.spm.spatial.smooth.prefix = 's300_';
