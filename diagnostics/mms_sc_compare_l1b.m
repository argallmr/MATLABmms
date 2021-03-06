%
% Name
%   mms_sc_view
%
% Purpose
%   Compare my level 1b data results to those of the mag team to
%   see if I am applying the calibration parameters correctly.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-05-07      Written by Matthew Argall
%
%***************************************************************************

get_data = true;

if get_data

%------------------------------------%
% Inputs                             %
%------------------------------------%
	sc         = 'mms2';
	instr      = 'scm';
	mode       = 'comm';
	optdesc    = 'sc256';
	duration   = 64.0;
	tstart     = '2015-06-30T14:40:00';
	tend       = '2015-06-30T15:00:00';
	sc_cal_dir = fullfile('/home', 'argall', 'data', 'mms', 'scm_cal');
	hk_dir     = '/nfs/hk/';
	att_dir    = fullfile('/nfs', 'ancillary', sc, 'defatt');

%------------------------------------%
% Find Files                         %
%------------------------------------%
	% SCM L1A Data File
	[l1a_fname, count, str] = mms_file_search(sc, instr, mode, 'l1a', ...
	                                          'TStart',    tstart, ...
	                                          'TEnd',      tend, ...
	                                          'OptDesc',   optdesc);
	assert(count > 0, ['SCM L1A file not found: "' str '".']);
	
	% SCM L1B Data File
	[l1b_fname, count, str] = mms_file_search(sc, instr, mode, 'l1b', ...
	                                          'TStart',    tstart, ...
	                                          'TEnd',      tend, ...
	                                          'OptDesc',   optdesc);
	assert(count > 0, ['SCM L1B file not found: "' str '".']);
	
	% SCM Cal File
	cal_fname = fullfile(sc_cal_dir, [sc '_' instr sc(4) '_caltab_%Y%M%d%H%m%S_v*.txt']);
	[cal_fname, nFiles] = MrFile_Search( cal_fname, 'VersionRegex', '([0-9])');
	assert(nFiles > 0, ['SCM cal file not found: "' str '".']);

%------------------------------------%
% Calibrated Mag in BCS              %
%------------------------------------%
	[t, ~, b_omb] = mms_sc_create_l1b(l1a_fname, cal_fname, tstart, tend, duration);
	
%------------------------------------%
% Official L1B Data                  %
%------------------------------------%
	sc_l1b = mms_sc_read_l1b(l1b_fname, tstart, tend);
end

%------------------------------------%
% Plot the Results                   %
%------------------------------------%
% Convert time to datenumber to use the datetick function.
t_dn_orig  = MrCDF_epoch2datenum(t);
t_l1b_orig = MrCDF_epoch2datenum(sc_l1b.tt2000);


f_dmpa = figure();

% Magnitude
subplot(4,1,1)
plot( t_l1b, mrvector_magnitude(b_l1b_123), t_dn, mrvector_magnitude(b_123) );
title([ upper(sc) ' ' upper(instr) ' 123 ' tstart(1:10) ]);
xlabel( 'Time UTC' );
ylabel( {'|B|', '(nT)'} );
ylim(yrange);
datetick();
legend('MagTeam', 'Mine');

% X-component
subplot(4,1,2)
plot( t_l1b, b_l1b_123(1,:), t_dn, b_123(1,:) );
xlabel( 'Time UTC' );
ylabel( {'B_{X}', '(nT)'} );
ylim(yrange);
datetick();

% Y-component
subplot(4,1,3)
plot( t_l1b, b_l1b_123(2,:), t_dn, b_123(2,:) );
xlabel( 'Time UTC' );
ylabel( {'B_{Y}', '(nT)'} );
ylim(yrange);
datetick();

% Z-component
subplot(4,1,4)
plot( t_l1b, b_l1b_123(3,:), t_dn, b_123(3,:) );
title('Calibrated SCM Data in 123');
xlabel( 'Time UTC' );
ylabel( {'B_{Z}', '(nT)'} );
ylim(yrange);
datetick();