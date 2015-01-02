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
	  if [ ! -e "$1" ];then
		  echo "cp: 无法获取\"$1\" 的文件状态(stat): 没有那个文件或目录"
		  return 1
	  elif [ -e "$2" ]||[[ "$2" != *"/"* ]];then
		  f=$(echo $1|sed 's/\/$//')
		  rsync -Pr $f $2
	  elif [ ! -d "$(echo ${2%/*})" ];then
		  echo "cp: 无法创建普通文件"$2": 没有那个文件或目录"
		  return 1
	  fi
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
	  touch /tmp/mycp
	  { 
		  gcp -fr $@ > /tmp/mycp 2>&1
		  rm /tmp/mycp
	  } &
	  a=$(( $#-2 ))
	  while [ -f "/tmp/mycp" ]
	  do
		  gcp=$(cat -v /tmp/mycp|sed -e 's/\^M/\n/g'|grep 'Cop'|tail -n 1)
		  for (( i=$(( $#-2 ));i>=0;i-- ));do
			  if [ -e "$(echo ${o%/*})/${args[$i]}" ];then
				  if [ "$a" == "$i" ];then
					  break
				  else
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
			  fi
		  done
		  echo -ne "$gcp\r"
		  sleep 1

	  done
	  wait
	  echo -e "$gcp"
	  ;;
esac
}

cpv "$@"
