#! /bin/sh
# getImports.sh <user>

# Show syntax
Show_Syntax() {
  echo "getImports.sh <user>"
  cd $INITIAL_PATH
  exit 1
}

# End of script
End() {
  cd $INITIAL_PATH
  echo "...process finished"
  exit 0
}

# End of script
LeerResp() {
  read -n 1 -p "DESCARGA MODULO ? [y/n] : " resp
  if [ "$resp" == "y"  -o "$resp" == "Y" ]; then 
	return 0
  else
    return 1
  fi
  
  
}

# Function Export
CVS_Export() {
  if [ "$1" = "include" ] ; then
    CVS_STD_DEST_PATH=ImportEx
    CVS_STD_DEST_FOLDER=ImportEx
  else
    CVS_STD_DEST_PATH=ImportEx/Runtime
    CVS_STD_DEST_FOLDER=Runtime
  fi
  CVS_PARENT_IMPORTEX=$2
  CVS_USER=$3
  CVS_ID=$5
  CVS_TAG=$6
  CVS_ROOT=$7
  CVS_FROM=$8
  CVS_TO=$9
  CVS_TO_LAST_DIR=`basename $CVS_TO 2>/dev/null`
  CVS_CVSROOT=:pserver:$CVS_USER@taurus:2401$CVS_ROOT
  CVS_LOGIN_CMD="cvs -d$CVS_CVSROOT login"
  if [ -z "$CVS_TO" ] ; then
    
    CVS_CHECKOUT_CMD="cvs -d$CVS_CVSROOT -r -q export -r $CVS_TAG -d $CVS_STD_DEST_FOLDER $CVS_FROM"
  else
    
    CVS_CHECKOUT_CMD="cvs -d$CVS_CVSROOT -r -q export -r $CVS_TAG -d $CVS_TO_LAST_DIR $CVS_FROM"
  fi
  echo ""
  echo " --- Download ($1) $CVS_ID $CVS_ROOT $CVS_FROM $CVS_TAG ($CVS_USER)"
  ACTUAL_PATH=$PWD
  cd $CVS_PARENT_IMPORTEX
  if [ ! -d $CVS_STD_DEST_PATH ] ; then
    mkdir -p $CVS_STD_DEST_PATH
  fi
  cd $CVS_STD_DEST_PATH/..
  if [ -n "$CVS_TO" ] ; then
    cd $CVS_STD_DEST_FOLDER
    if [ ! -d $CVS_TO ] ; then
      mkdir -p $CVS_TO
    fi
    cd $CVS_TO/..
  fi
  $CVS_CHECKOUT_CMD
  if [ $? -eq 1 ] ; then
    $CVS_LOGIN_CMD
    $CVS_CHECKOUT_CMD
  fi
  cd $ACTUAL_PATH
}

# Change to script path
INITIAL_PATH=$PWD
cd `dirname $0`

# Variable importex
CVS_IMPORT_EX=..

echo "FULL INSTALL o Paso por Paso  F(FULL)/S(StepByStep)"
read full

 echo "--------------------------------------------------------------------"
 echo "Erasing Dirs ..."
for dir in ` ls -d $CVS_IMPORT_EX/ImportEx/*`
do

   if [ "$full" == "F"  -o "$full" == "f" ]; then 
	resp="Y"
   else
	read -p "Eliminna directorio("$dir") ? [y/n] : " resp
   fi 
   
   
	if [ "$resp" == "y"  -o "$resp" == "Y" ]; then 
		rm -f -r $dir
	else
		echo "WARN: Directorio "$dir"  NO eliminado podria no tener correctamente las versiones actualizadas si esta descargando el modulo !!!"
	fi
done

# Get user
if [ -z "$1" ] ; then
  CVS_USERNAME=$LOGNAME
else
  CVS_USERNAME=$1
fi
if [ -z "$CVS_USERNAME" ] ; then
  echo "Unknown user for cvs"
  Show_Syntax
fi

# Main loop to read file
 
#tr -d '\015' < imports.txt | while read -n 0 IMPORT_LINE # DIEGO VIQUEIRA MODIFICACION PARA PODER PREGUTAR LA DESCARGA DEL MODULO
while read -u 3 IMPORT_LINE
do
   case "$IMPORT_LINE" in
    
		 %CVS_INCLUDE%*) 
		 echo "--------------------------------------------------------------------"
		 echo " Modulo - "$IMPORT_LINE
		 
		 if [ "$full" == "F"  -o "$full" == "f" ]; then 
			resp_1=0
		 else
			LeerResp
			resp_1=$?
		fi 
		 
		 
		 if [ $resp_1 == 0  ] ;then 
		  
			CVS_Export include $CVS_IMPORT_EX $CVS_USERNAME $IMPORT_LINE 
		 else
			echo "Skipping Install ..."
		 fi
		 ;;
		 %CVS_RUNTIME%*) 
		 echo "--------------------------------------------------------------------"
		 echo " Modulo"$IMPORT_LINE
		 
		 if [ "$full" == "F"  -o "$full" == "f" ]; then 
			resp_1=0
		 else
			LeerResp
			resp_1=$?
		fi 
		 
		
		 if [ $resp_1 == 0 ] ;then 
		 	 CVS_Export runtime $CVS_IMPORT_EX $CVS_USERNAME $IMPORT_LINE 
		 else
			echo "Skipping Install ..."
		 fi
		 ;;
   esac
done  3< imports.txt 

# Purge subfolder exclusive of other platforms
if [ `uname` = "SunOS" ] ; then
  PLATFORM=`uname -s`-`uname -m`
else
  PLATFORM=`uname -s`-x86-`uname -r | sed 's_\([0-9]\.[0-9]\).*_\1_'`
fi
PLATFORMBASE=`uname -s`-`uname -m`
for i in windows win32 Linux-x86-2.4 Linux-x86-2.6 SunOS-i86pc SunOS-sun4v Linux-i686 Linux-i686-2.4 Linux-i686-2.6; do
  if [ "$i" != "$PLATFORM" -a "$i" != "$PLATFORMBASE" ] ; then
    echo "Purgue $i folders..."
    find $CVS_IMPORT_EX/ImportEx -name $i -exec rm -rf {} \; 2>/dev/null
  fi
done

End

