DECLARE
 v_exe_name  fnd_executables_tl.user_executable_name%TYPE := 'XXD_CUSTOMER_GET';
 v_exe_short fnd_executables.executable_name%TYPE     :=     'XXD_CUSTOMER_GET';
 v_exe_file  fnd_executables.execution_file_name%TYPE :=     'customer_get';
 v_exe_desc  fnd_executables_tl.description%TYPE      :=     '';
 v_exe_appl  fnd_application.application_short_name%TYPE :=  'XXEMT';
 v_exe_method fnd_lookups.meaning%TYPE                :=     'Host';
 v_prg_short fnd_concurrent_programs.concurrent_program_name%TYPE    := 'XXD_CUSTOMER_GET';
 v_prg_name  fnd_concurrent_programs_tl.user_concurrent_program_name%TYPE  := 'AS EMT: Kliendi TeliaID sünk';
 v_prg_desc   fnd_concurrent_programs_tl.description%TYPE   :=     '';
 v_prg_appl  fnd_application.application_short_name%TYPE := 'XXEMT';
 VAR_ERROR_MSG VARCHAR2(2000);
  procedure put(str varchar2) is begin DBMS_OUTPUT.put_line(str); end;
BEGIN
  DBMS_OUTPUT.ENABLE(1000000);
  PUT(' -- Begin installing program: '||v_exe_name);
  rollback;
  apps.fnd_program.set_session_mode('customer_data');
  apps.fnd_program.debug_on;
  
  VAR_ERROR_MSG := apps.fnd_program.message;
  
  IF (VAR_ERROR_MSG IS NOT NULL) THEN
    -- PUT(VAR_ERROR_MSG);
    null;-- RETURN;
  END IF;
  IF (apps.fnd_program.program_exists(v_prg_short,v_PRG_appl)) THEN
     apps.fnd_program.delete_program(v_prg_short, v_PRG_appl);
     PUT('-- Program deleted  '||v_prg_short);
  END IF;
  IF (apps.fnd_program.executable_exists(v_exe_short, v_exe_appl)) THEN
      apps.fnd_program.delete_executable(v_exe_short, v_exe_appl);
      PUT('-- Executable deleted '||v_exe_short);
  END IF;
  PUT('-- creating EXE .. '||v_exe_short);
     apps.fnd_program.executable(
                    v_exe_name,
                    v_exe_appl,
                    v_exe_short,
                    v_exe_desc,
                    v_exe_method,
                    v_exe_file,
                    NULL,
                    NULL,
                    'US');
 PUT('-- exe created');
 PUT('-- creating prg .. '||v_prg_short);
 apps.fnd_program.register(   
  program  	       => v_prg_name ,
  application  	   => v_prg_appl ,
  enabled       	   => 'Y',
  short_name	  	   => v_prg_short ,
  description		   => v_prg_desc ,
  executable_short_name => v_exe_short ,
  executable_application=> v_exe_appl ,
  execution_options		=> '',
  priority			=> '',
  save_output			=> 'Y',
  print			=> 'Y',
  cols				=> '',
  rows				=> '',
  style 			=> '',
  style_required		=> 'N',
  printer			=> '',
  request_type			=> NULL,
  request_type_application     => NULL,
  use_in_srs			=> 'Y',
  allow_disabled_values	=> 'N',
  run_alone			=> 'N',
  -- output_type                  => 'Text',
  output_type                  => 'TEXT',
  enable_trace                 => 'N',
  restart                      => 'Y',
  nls_compliant                => 'Y',
  icon_name                    => NULL,
  language_code                => 'US',
  mls_function_short_name      => NULL,
  mls_function_application     => NULL,
  incrementor			=> NULL,
  refresh_portlet              => NULL);
 PUT('-- Program created .. '||v_prg_short);
  IF not  apps.fnd_program.PROGRAM_IN_group( v_prg_short,
                                             v_prg_appl,
                                             'AS_EMT_AR',
                                             'XXEMT') THEN
        apps.fnd_program.add_to_group( v_prg_short,
                                       v_prg_appl,
                                       'AS_EMT_AR',
                                       'XXEMT');
 PUT('-- Added to group: OM Concurrent Programs');
 END IF;
 PUT(' !!! OK - all created!!!');
 PUT(' !!! NOT COMMITED - do it manually!!!');
EXCEPTION
  WHEN OTHERS THEN
       PUT (SUBSTR(apps.fnd_program.message,1,240));
       RAISE;
END;
/

