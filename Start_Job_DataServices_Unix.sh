

#./Start_Job_DataServices_Unix.sh JB_TESTE_PARAMETROS "" "X"

#!/bin/sh

# Seta variaveis de ambiente do DataServices
. /opt/sap/dataservices/bin/al_env.sh

# Recebe os parametros de entrada
V_JOB=${1}
V_01=$(AL_Encrypt "'${2}'")
V_02=$(AL_Encrypt "'${3}'")
V_03=$(AL_Encrypt "'${4}'")
V_04=$(AL_Encrypt "'${5}'")
V_05=$(AL_Encrypt "'${6}'")
V_06=$(AL_Encrypt "'${7}'")
V_07=$(AL_Encrypt "'${8}'")
V_08=$(AL_Encrypt "'${9}'")
V_09=$(AL_Encrypt "'${10}'")
V_10=$(AL_Encrypt "'${11}'")

# Seta demais variaveis
V_DIR=/sapbods/script_DS
V_SERVER=`hostname`

case $V_SERVER in
  *snelnxn95*) 
          V_SYSTEM="DEV"
          ;;
  *snelnxo12*) 
          V_SYSTEM="QA"
          ;;
  *snelnxo17*) 
          V_SYSTEM="PREPRD"
          ;;
  *snelnxp38*) 
          V_SYSTEM="PRD"
          ;;
esac

    V_REPO=`grep -i BODS_$V_SYSTEM: $V_DIR/bods.cfg | cut -f 2 -d : | cut -f 1 -d , | cut -f 2 -d =`
    V_USER=`grep -i BODS_$V_SYSTEM: $V_DIR/bods.cfg | cut -f 2 -d : | cut -f 2 -d , | cut -f 2 -d =`
    V_PASS=`grep -i BODS_$V_SYSTEM: $V_DIR/bods.cfg | cut -f 2 -d : | cut -f 3 -d , | cut -f 2 -d =`
V_DATABASE=`grep -i BODS_$V_SYSTEM: $V_DIR/bods.cfg | cut -f 2 -d : | cut -f 4 -d , | cut -f 2 -d =` 

V_PASS=$(AL_Encrypt $V_PASS)


# Busca o valor hexadecimal do nome do Job
V_GUID=$( 
echo "set feed off
set pages 0
select distinct replace(guid,'-','_') guid from al_lang where object_type = 0 and type = 0 and name = '$V_JOB';
exit
"  | sqlplus -s $V_DATABASE
)


# Busca as variaveis globais do Job
V_JOB_GLOBAL=$( 
echo "set feed off
set pages 0
 select rtrim((case when max(var_01) is null then null else max(var_01)||'=V_01;' end)||(case when max(var_02) is null then null else max(var_02)||'=V_02;' end)||(case when max(var_03) is null then null else max(var_03)||'=V_03;' end)||(case when max(var_04) is null then null else max(var_04)||'=V_04;' end)||(case when max(var_05) is null then null else max(var_05)||'=V_05;' end)||(case when max(var_06) is null then null else max(var_06)||'=V_06;' end)||(case when max(var_07) is null then null else max(var_07)||'=V_07;' end)||(case when max(var_08) is null then null else max(var_08)||'=V_08;' end)||(case when max(var_09) is null then null else max(var_09)||'=V_09;' end)||(case when max(var_10) is null then null else max(var_10)||'=V_10;' end)) var_globais
   from (   
          select a.name
               , case when b.vp_seqnum = 1  then b.vp_name else null end var_01
               , case when b.vp_seqnum = 2  then b.vp_name else null end var_02
               , case when b.vp_seqnum = 3  then b.vp_name else null end var_03
               , case when b.vp_seqnum = 4  then b.vp_name else null end var_04
               , case when b.vp_seqnum = 5  then b.vp_name else null end var_05
               , case when b.vp_seqnum = 6  then b.vp_name else null end var_06
               , case when b.vp_seqnum = 7  then b.vp_name else null end var_07
               , case when b.vp_seqnum = 8  then b.vp_name else null end var_08
               , case when b.vp_seqnum = 9  then b.vp_name else null end var_09
               , case when b.vp_seqnum = 10 then b.vp_name else null end var_10
           from al_lang a
           join al_varparam b
             on a.object_key = b.parent_objid
          where a.name = '$V_JOB'
            and b.vp_type = 'GlobalVariable' )      
group by name;
exit
"  | sqlplus -s $V_DATABASE
)


# Elimina espaco em branco
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/ //g"`


# Atribui os valores de entrada as variaveis globais do Job
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_01/$V_01/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_02/$V_02/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_03/$V_03/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_04/$V_04/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_05/$V_05/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_06/$V_06/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_07/$V_07/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_08/$V_08/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_09/$V_09/g"`
V_JOB_GLOBAL=`echo $V_JOB_GLOBAL | sed -e"s/V_10/$V_10/g"`


# Prepara parametros para executar o camando do DataServices
V_PARAMETROS_DS=$(echo " -PLocaleUTF8  -S$V_SERVER -NsecEnterprise -Q$V_REPO -U$V_USER -P$V_PASS  -G$V_GUID -t5 -T14 -Ksp$V_SYSTEM -LocaleGV -GV\"$V_JOB_GLOBAL\"   -CtBatch -Cm$V_SERVER -Ca$V_USER -Cj$V_SERVER -Cp3500 ")


# Executa o comando do DataServices
/opt/sap/dataservices/bin/AL_RWJobLauncher  "/opt/sap/dataservices/log/JS_{$V_SERVER^^}/" -w "inet:$V_SERVER:3500" "$V_PARAMETROS_DS"


# Imprime o retorno da execucao do Job
./Retorno_Da_Execucao_Do_Job.sh $V_JOB

echo "Shell finalizado!!!"





