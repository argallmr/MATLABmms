%
% Name
%   mms_edi_read_efield
%
% Purpose
%   Read MMS EDI electric field mode data files.
%
% Calling Sequence
%   [EDI1_BCS, EDI2_BCS] = mms_edi_bcs(SC, INSTR, MODE, LEVEL, TSTART, TEND, EDI_DIR)
%     Read EDI electric field mode data captured by spacecraft SC
%     (e.g. 'mms3'), instrument INSTR (e.g. 'edi'), from telemetry
%     mode MODE and data product level LEVEL between the time
%     interval of [TSTART, TEND]. Data can be found in directory
%     EDI_DIR. Times should be provided in ISO format:
%     'yyyy-mm-ddThh:mm_ss'. Firing angles are converted to firing
%     vectors in BCS and returned in the output structures.
%
% Parameters
%   SC              in, required, type=char/cell
%   INSTR           in, required, type=char
%   MODE            in, required, type=char
%   LEVEL           in, required, type=char
%   TSTART          in, required, type=char
%   TEND            in, required, type=char
%   EDI_DIR         in, required, type=char
%
% Returns
%   EDI1_BCS        out, required, type=structure
%                   Fields are:
%                     't_gd12_gd12'   -  TT2000 Epoch time for gun 1 and detector 2.
%                     'gun_gd12_bcs'  -  Gun1 position in BCS.
%                     'det_gd12_bcs'  -  Detector2 position in BCS.
%                     'fv_gd12_bcs'   -  Firing vectors from gun1 in BCS.
%   EDI2_BCS        out, required, type=structure
%                   Fields are:
%                     't_gd21'        -  TT2000 Epoch time for gun 2 and detector 1.
%                     'gun_gd21_bcs'  -  Gun2 position in BCS.
%                     'det_gd21_bcs'  -  Detector1 position in BCS.
%                     'fv_gd21_bcs'   -  Firing vectors from gun2 in BCS.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-18      Written by Matthew Argall
%
function [gd12_bcs, gd21_bcs] = mms_edi_bcs(sc, instr, mode, level, tstart, tend, edi_dir)

	if nargin < 7
		edi_dir = pwd();
	end
	
%------------------------------------%
% Get EDI Data                       %
%------------------------------------%
	% Gun positions and detectors in BCS
	gun1_bcs = mms_instr_origins_ocs('EDI1_GUN');
	gun2_bcs = mms_instr_origins_ocs('EDI2_GUN');
	det1_bcs = mms_instr_origins_ocs('EDI1_DETECTOR');
	det2_bcs = mms_instr_origins_ocs('EDI2_DETECTOR');
	
	% Read EDI efield data
	[t_gd12, t_gd21, g1fa_deg, g2fa_deg] = mms_edi_read_efield(sc, instr, mode, level, tstart, tend, edi_dir);
	
	% Convert to radians
	g1fa(1:2, :) = g1fa_deg(1:2, :) * pi/180.0;
	g2fa(1:2, :) = g2fa_deg(1:2, :) * pi/180.0;

	% Convert to cartesian coordinates
	%   - sph2cart requires the elevation angle, measured up from the xy-plane,
	%     not down from the z-axis.
	[g1fv_x, g1fv_y, g1fv_z] = sph2cart( g1fa(1,:), pi/2 - g1fa(2,:), ones(1, length(t_gd12)) );
	[g2fv_x, g2fv_y, g2fv_z] = sph2cart( g2fa(1,:), pi/2 - g2fa(2,:), ones(1, length(t_gd21)) );
	g1fv_edi1 = [g1fv_x; g1fv_y; g1fv_z];
	g2fv_edi2 = [g2fv_x; g2fv_y; g2fv_z];
	
%------------------------------------%
% Transform to BCS                   %
%------------------------------------%
	
	% Transformations from GUN1 and GUN2 to BCS
	edi12bcs = mms_instr_xxyz2ocs('EDI1_GUN');
	edi22bcs = mms_instr_xxyz2ocs('EDI2_GUN');

	% Transform firing vectors
	g1fv_bcs = mrvector_rotate( edi12bcs, g1fv_edi1 );
	g2fv_bcs = mrvector_rotate( edi22bcs, g2fv_edi2 );
	
%------------------------------------%
% Output                             %
%------------------------------------%
	
	% EDI1 output structure
	%   - EDI1 contains gun1 and detector2
	gd12_bcs = struct( 't_gd12',        t_gd12,   ...
	                   'gun_gd12_bcs',  gun1_bcs, ...
	                   'det_gd12_bcs',  det1_bcs, ...
	                   'fv_gd12_bcs',   g1fv_bcs );
	
	% EDI2 output structure
	%   - EDI2 contains gun1 and detector2
	gd21_bcs = struct( 't_gd21',        t_gd12,   ...
	                   'gun_gd21_bcs',  gun2_bcs, ...
	                   'det_gd21_bcs',  det2_bcs, ...
	                   'fv_gd21_bcs',   g2fv_bcs );
end