#!/bin/bash 

. $APP_SCRIPT/$APP_LOWER"_functions.sh"

infile_dir="/appl/pink/dev/tmp/adhoc" 
backup_infile_dir="/appl/pink/dev/tmp/adhoc/infile_backup" 
sqlldr_ctl_dir="/appl/pink/dev/tmp/adhoc/sql_ldr_ctl" 
sqlldr_log_dir="/appl/pink/dev/tmp/adhoc/sql_ldr_log" 
serv_req_log_dir="/appl/pink/dev/tmp/adhoc/serv_req_log" 
gen_trc_log_tab='PINK.generic_trace_log'
sep="'"

function WriteColor ()      
{
	local color_ok="\x1b[32m"
	local color_bad="\x1b[31m"
	local color_reset="\x1b[0m"
	local color_bold="\x1b[1m"
	local color_underline="\x1b[4m"
	local color="${color_bad}"
	local param_num="$#"
	
	if [ "${1}" = "bold" ]; then
    color="${color_bold}"
	fi
	
	if [ "${1}" = "underline" ]; then
    color="${color_underline}"
	fi
	
	if [ "${1}" = "debug" ] || [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then
    color="${color_ok}"
	fi
	
	if [ "${1}" = "error" ] || [ "${1}" = "critical" ] ; then
    color="${color_bad}"
	fi
	
	
	
	#if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
    # Don't use colors on pipes or non-recognized terminals
    #=""; color_reset="" 
	if [ ${param_num} -eq 2 ]; 
	then # request-ID command
		echo -e "${color}$(printf "[%s]" ${2})${color_reset}";
	else
		echo -e "$(date +"%Y-%m-%d %H:%M:%S") ${color}$(printf "[%s]" ${1})${color_reset}";
	fi
}

function IsZero () 
{
	if [ -z "$1" ]                           # Is parameter #1 zero length?
	then
		echo "$(WriteColor error) Parameter is zero length "  # Or no parameter passed.
	fi
}

function Operation () 
{
	#Import #Validate #Insert #Roll-back #Check-bad #Check-ok
	local Ops=${1}
	local Request_ID=${2}
	local TemplateFile=${sqlldr_ctl_dir}/${Request_ID}_template.ctl 
	local LogFile=${serv_req_log_dir}/${Request_ID}.log 
	local LogFileLdr=${sqlldr_log_dir}/${Request_ID}_ldr.log 
	local InFileName=${infile_dir}/${Request_ID}.txt 
	local RowCount=0
	local step=0
	local ict_user=`whoami`
	case $Ops in
	import)
			echo "$(WriteColor info) Importing file for request ${Request}"
			echo "$(WriteColor info) Using template: $(WriteColor bold ${TemplateFile})"
			echo "$(WriteColor info) Using log file: $(WriteColor bold ${LogFile})"
			cp ${sqlldr_ctl_dir}/new_event_debtor_comment.ctl ${TemplateFile} 
			sed -e "s/PGM_VALUE/${Request_ID}/g" ${TemplateFile} > ${TemplateFile}.tmp && mv ${TemplateFile}.tmp ${TemplateFile} 
			sed -e "s/USER/${ict_user}/g" ${TemplateFile} > ${TemplateFile}.tmp && mv ${TemplateFile}.tmp ${TemplateFile} 
			sed -e "s/PATH_TO_INFILE/$(echo ${infile_dir} | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" ${TemplateFile} > ${TemplateFile}.tmp && mv ${TemplateFile}.tmp ${TemplateFile} 
			sed -e "s/PATH_TO_SQLLDR_LOG/$(echo ${sqlldr_log_dir} | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" ${TemplateFile} > ${TemplateFile}.tmp && mv ${TemplateFile}.tmp ${TemplateFile} 
			sqlldr USERID=PINK/${APP_DB_PASS} CONTROL=${TemplateFile} LOG=${LogFileLdr} > ${LogFile} 2>&1  || echo "$(WriteColor error) Sqlloader failed, please look into log: $(WriteColor underline ${LogFileLdr})"
			RowCount="$(cat ${LogFileLdr} |egrep "records read:[ ]*[[:digit:]]*" | sed "s/[^0-9]//g")"
			if [ "${RowCount}" > 0 ]; then
				echo "$(WriteColor info) Number of rows loaded: $(WriteColor bold ${RowCount})"
				#write load result to generic trace log 
				start_SQLPLUS <<E_O_SQL
    BEGIN
	DB_PINK_COMMON.PR_INSERT_GENERIC_TRACE_LOG( in_request_module=>'PA_ICT_SERVICE_REQUEST.NEW_COMMENT',
                                            in_field_name_1=>'TASK_ID',in_field_value_1=>'${Request_ID}',
                                            in_field_name_2=>'OPERATION',in_field_value_2=>'SQL_LOADER',
                                            in_field_name_3=>'ROWS_LOADED',in_field_value_3=>'${RowCount}'
                                           );
    END;
	/
E_O_SQL
				cp ${InFileName} ${backup_infile_dir}/${Request_ID}_`date +%y%m%d%H%M%S`.txt 
				mv ${InFileName} ${InFileName}.old 
				step=2
			else
				start_SQLPLUS <<E_O_SQL2
    BEGIN
	DB_PINK_COMMON.PR_INSERT_GENERIC_TRACE_LOG( in_request_module=>'PA_ICT_SERVICE_REQUEST.NEW_COMMENT',
                                            in_field_name_1=>'TASK_ID',in_field_value_1=>'${Request_ID}',
                                            in_field_name_2=>'OPERATION',in_field_value_2=>'SQL_LOADER',
                                            in_field_name_3=>'RESULT',in_field_value_3=>'Error: 0 records loaded'
                                           );
    END;
	/
E_O_SQL2
			fi
			
	if [ ${step} -eq 2 ]; then
	echo "Starting PR_NEW_EVENT_DEBTOR_COMMENT"
		start_SQLPLUS <<E_O_SQL3
    BEGIN
		PA_ICT_SERVICE_REQUESTS.PR_NEW_EVENT_DEBTOR_COMMENT( 
										in_pgm_id => '${Request_ID}',
										in_ict_user => '${ict_user}'
										);
    END;
	/
E_O_SQL3

#$GEN_TRC_LOG_TAB
#select CASE WHEN( COUNT(1) > 0) THEN '1' ELSE '0' END into :test_count from dual
#		WHERE REQUEST_MODULE = 'PA_ICT_SERVICE_REQUEST.NEW_COMMENT'
#		and FIELD_NAME_1 = 'TASK_ID' and FIELD_VALUE_1 = $sep$Request_ID$sep
#		and FIELD_NAME_2 = 'OPERATION' and FIELD_VALUE_2 = 'PROCEDURE_EXCEPTION'
#		and FIELD_NAME_3 = 'AT TIME'

##get status value of procedure call from generic trace log
start_SQLPLUS <<E_O_SQL4
     var test_count number;
	 BEGIN
		select CASE WHEN( COUNT(1) > 0) THEN '1' ELSE '0' END into :test_count from ${gen_trc_log_tab}
		WHERE REQUEST_MODULE = 'PA_ICT_SERVICE_REQUEST.NEW_COMMENT'
		and FIELD_NAME_1 = 'TASK_ID' and FIELD_VALUE_1 = $sep$Request_ID$sep
		and FIELD_NAME_2 = 'OPERATION' and FIELD_VALUE_2 = 'PROCEDURE_EXCEPTION'
		and FIELD_NAME_3 = 'AT TIME'
		;
		
	 END;
	 /
	 exit :test_count;
E_O_SQL4

	if [ ${JSTAT} -gt 0 ]; then
		echo "$(WriteColor error) There are some errors during PL/SQL execution please check ${gen_trc_log_tab} table"
	else
		echo "$(WriteColor info) Importing comments and events finished with success "
	fi



	fi
	;;
	esac
	
	
}

if ! [[ "${APP_COUNTRY}" = 'DK' || "${APP_COUNTRY}" = 'NO' ]] || ! [[ "${APP}" = 'pink' ]]; then
	echo "$(WriteColor error) Wrong env. this script has been created for Denmark Pink/Norway!"
	echo "Curently you are using $(WriteColor bold "${APP_COUNTRY}\\${APP}")"
	exit 1	
fi


#if [ "${APP_COUNTRY}" != 'DK' ] || [ "${APP}" != 'pink' ]; then # request-ID command
#	echo "$(WriteColor error) Wrong env. this script has been created for Denmark Pink/Norway!"
#	echo "Curently you are using $(WriteColor bold "${APP_COUNTRY}\\${APP}")"
#	exit 1
#fi


if [ "$#" -eq 0 ]; then # request-ID command
    echo "$(WriteColor error) Illegal number of parameters, please use ${0} -r request-ID -o operation"
	exit 1
fi
#else

while getopts ":r:o:h" opt;
do
	case $opt in
	r)

		IsZero "$OPTARG"
		Request=${OPTARG}
		;;
	h)	
		echo "Please put proper parameters -r request-ID -o operation "
		exit 1
		;;
	o)	
		IsZero "$OPTARG"
		Operation "$OPTARG" "$Request"

		;;
	esac	
done
shift $(( OPTIND - 1 ));
	

