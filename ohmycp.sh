ohmygcp() {
if ! type -P gcp >/dev/null;then
  echo need gcp >&2
  return 1
fi
case $# in
  0|1)
	  cp -v $@
	  ;;
#	echo -e "gcp: 缺少了文件操作数。" >&2
#	return 1
#	;;
#  1)
#	echo -e "gcp: 在\"$1\" 后缺少了要操作的目标文件。" >&2
#	return 1
#	;;
#  2)
#	  if [ ! -e "$1" ];then
#		  echo "gcp: 无法获取\"$1\" 的文件状态(stat): 没有那个文件或目录"
#		  return 1
#	  elif [[ "$2" == *"/"* ]]&&[ ! -d "$(echo ${2%/*})" ];then
#		  echo "gcp: 无法创建普通文件"$2": 没有那个文件或目录"
#		  return 1
#	  else
#		  gcp -fvr $@
#	  fi
#	;;
  *)
	  #mkfifo -m 777 /tmp/npipe
	  touch /tmp/ohmycp
	  args=($@)
	  s=${args[@]:0:$#-1}
	  argend=${args[-1]}
	  if [[ -d "$argend" ]];then
		  for (( i=0;i<=$(( $#-2 ));i++ ));do
			  o="$o $(echo $argend|sed 's/\/$//')/$(basename ${args[$i]})"
		  done
	  else
		  o="$argend"
	  fi
	  #echo $o
	  size=$(du -c -s $s|tail -n 1|sed 's/\([0-9]*\).*$/\1/')
	  hsize=$(du -c -s -h $s|tail -n 1|sed 's/^\([^\t]*\)\t.*$/\1B/')
	  #echo $size
	  {
		  cp -vr $@
		  rm /tmp/ohmycp
	  }&
	  sleep 0.1
	  while [ -f "/tmp/ohmycp" ]
	  do
		  #sleep 1
		  ttylen="$(tput cols)"
		  size2=$(du -c -s $o 2>/dev/null |tail -n 1|sed 's/\([0-9]*\).*$/\1/')
		  #echo $size2
		  progressnum="$(echo -e "scale=3;$size2/$size*100"|bc|sed 's/[0-9]\{2\}$//')"
		  progress=$(printf "%6s" "$progressnum")
		  pstart="Copying $hsize |"
		  pend="|$progress%"
		  stenlen=$(( $ttylen-${#pstart}-8 ))
		  gprolen=$(echo -e "scale=2;$size2/$size*$stenlen+1"|bc|sed 's/\..*$//')
		  gpro=$(for (( i=1;i<=$gprolen;i++ ));do echo -n '#';done)
		  #pstart="Copying $hsize |$gpro"
		  #stenlen=$(( $ttylen-${#pstart}-${#pend} ))
		  echo -ne "$pstart"
		  printf "%-$stenlen""s" "$gpro"
		  if [[ "$(echo $progressnum|sed 's/\..*$//')" == "99" ]];then
			  #end="| 100%"
			  echo -e "\b#| 100.0%"
			  break
		  else
			  #printf "%-$stenlen""s" "$gpro"
			  echo -ne "$pend\r"
		  fi
		  #echo -ne "$s $hsize\r"
		  #sleep 1
	  done
	  wait
	  #echo -ne "$pstart"
	  #printf "%-$stenlen""s" "#"
	  #endlen=${#pstart}
	  #c=$(( $ttylen-${#pstart}-${#end} ))
	  #for (( j=1;j<$c;j++ ));do echo -n '#';done
	  #echo -ne "100%\n"
	  #ttylen="$(tput cols)"
	  #echo -ne "$end"
	  #printf "%$c""s" " "
	  #echo ""
	  return 0
#	  local args dest
#	  args=("$@")
#	  for (( i=0;i<=$(( $#-2 ));i++ ));do
#		  if [ "${args[$i]}" != "-v" ]&&[ ! -e "${args[$i]}" ];then
#			  echo "gcp: 无法获取\"${args[$i]}\" 的文件状态(stat): 没有那个文件或目录"
#			  return 1
#		  fi
#	  done
#	  o=${args[$#-1]}
#	  if [ ! -d "$o" ];then
#		  echo "gcp: 目标\"$o\" 不是目录"
#		  return 1
#	  fi
#	  touch /tmp/mycp
#	  { 
#		  gcp -fr $@ > /tmp/mycp 2>&1
#		  rm /tmp/mycp
#	  } &
#	  a=$(( $#-2 ))
#	  while [ -f "/tmp/mycp" ]
#	  do
#		  gcp=$(cat -v /tmp/mycp|sed -e 's/\^M/\n/g'|grep 'Cop'|tail -n 1)
#		  for (( i=$(( $#-2 ));i>=0;i-- ));do
#			  if [ -e "$(echo ${o%/*})/${args[$i]}" ];then
#				  if [ "$a" == "$i" ];then
#					  break
#				  else
#					  file="${args[$i]} > $(echo ${o%/*})/"
#					  filelen=${#file}
#					  if [ "$filelen" -gt "80" ];then
#						  echo -e "$file"
#					  else
#						  c=$(( 80-$filelen ))
#						  echo -ne "$file"
#						  for (( j=1;j<$c;j++ ));do echo -n ' ';done
#						  echo ''
#					  fi
#					  a=$i
#					  break
#				  fi
#			  fi
#		  done
#		  echo -ne "$gcp\r"
#		  sleep 1
#
#	  done
#	  wait
#	  echo -e "$gcp"
	  ;;
esac
}

ohmygcp "$@"
