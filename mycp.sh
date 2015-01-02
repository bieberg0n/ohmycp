cpv() {
if ! type -P pv >/dev/null;then
  echo need pv >&2
  return 1
fi
case $# in
  0)
	echo -e "cp: 缺少了文件操作数。" >&2
	return 1
	;;
  1)
	echo -e "cp: 在\"$1\" 后缺少了要操作的目标文件。" >&2
	return 1
	;;
  2)
	  if [ -e "$1" ]&&[ ! -e "$2" ]&&[ ! -d "$(echo ${2%/*})" ];then
		  mkdir $(echo ${2%/*})
	  fi
	  gcp -fvr $@
	;;
  *)
	  local args dest
	  args=("$@")
	  for (( i=0;i<=$(( $#-2 ));i++ ));do
		  if [ "${args[$i]}" != "-v" ]&&[ ! -e "${args[$i]}" ];then
			  echo "cp: 无法获取\"${args[$i]}\" 的文件状态(stat): 没有那个文件或目录"
			  return 1
		  fi
	  done
	  o=${args[$#-1]}
	  if [ ! -e "${args[$#-1]}" ]&&[ ! -d "$(echo ${o%/*})" ];then
		  mkdir $(echo ${o%/*})
	  fi
	  #if [[ -f "$1" ]];then
	  #rsync=1
	  #size=$(ls -l $1|cut -d ' ' -f5)
	  #echo $size
	  touch /tmp/mycp
	  { 
		  #rsync -P $1 $2;echo 0 > /tmp/mycp 
		  gcp -fr $@ > /tmp/mycp 2>&1
		  rm /tmp/mycp
	  } &
	  #size2=$(ls -l "$2/$(basename "$1")"|cut -d ' ' -f5)
	  a=$(( $#-2 ))
	  while [ -f "/tmp/mycp" ]
	  do
		  #ls -l "$2/$(basename "$1")"|cut -d ' ' -f5
		  gcp=$(cat -v /tmp/mycp|sed -e 's/\^M/\n/g'|grep 'Cop'|tail -n 1)
		  #echo -ne "1\n$gcp\r"
		  #printf "\033c"
		  #a=$(( $a+1 ))
		  for (( i=$(( $#-2 ));i>=0;i-- ));do
			  #符合名字
			  if [ -e "$(echo ${o%/*})/${args[$i]}" ];then
				  #a=${args[$i]}
				  #if [ "$a" == "${args[$i]}" ];then
					  #break
				  #else
				  #a=$i
				  if [ "$a" == "$i" ];then
					  break
				  else
					  #echo -ne "                                                             \r"
					  file="${args[$i]} > $(echo ${o%/*})/"
					  filelen=${#file}
					  if [ "$filelen" -gt "80" ];then
						  echo -e "$file"
					  else
						  c=$(( 80-$filelen ))
						  echo -ne "$file"
						  for (( j=1;j<$c;j++ ));do echo -n ' ';done
						  echo ''
					  fi
					  a=$i
					  break
				  fi
				  #a=${args[$i]}
			  fi
		  done
		  echo -ne "$gcp\r"
		  sleep 1

		  #size2=$(ls -l "$2/$(basename "$1")"|cut -d ' ' -f5)
		  #echo $size2
		  #progress=$(echo "scale=3;($size2)/$size*100"|bc|sed -e 's/..$/%/')
		  #echo -ne $progress
		  #if [ "$(cat /tmp/mycp)" == "0" ];then
		  #	rsync=0
		  #fi
	  done
	  wait
	  echo -e "$gcp"
	  #	  if [[ ! -e "$2" ]] || [[ -f "$2" ]];then
	  #		pv "$1" > "$2"
	  #	  elif [[ -d "$2" ]];then
	  #		pv "$1" > "$2/$(basename "$1")"

	  #fi
	  #	elif [[ -d "$1" ]];then
	  #	  if [[ ! -e "$2" ]];then
	  #		(cd "$1" || exit 1
	  #		mkdir "$2" || exit 1
	  #		tar cf - . | pv | tar xf - -C "$2")
	  #	  elif [[ -d "$2" ]];then
	  #		tar cf - "$1" | pv | tar xf - -C "$2"
	  #	  fi
	  #fi
	  ;;
  #  *)
	  #	local args dest
	  #	args=("$@")
	  #	dest=${args[${#args[@]}-1]}
	  #	unset args[${#args[@]}-1]
	  #	if [[ -d "$dest" ]];then
	  #	  tar cf - "${args[@]}" | pv | tar xf - -C "$dest"
	  #	fi
	  #	;;
esac
}

cpv "$@"
