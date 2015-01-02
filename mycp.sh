cpv() {
if ! type -P pv >/dev/null;then
  echo need pv >&2
  return 1
fi
case $# in
  0)
	echo -e "cp: 缺少了文件操作数\n请尝试执行\"cp --help\"来获取更多信息。" >&2
	return 1
	;;
  1)
	echo -e "cp: 在\"$1\" 后缺少了要操作的目标文件\n请尝试执行\"cp --help\"来获取更多信息。" >&2
	return 1
	;;
  2)
	  gcp -fv $1 $2
	return 1
	;;
  *)
	  local args dest
	  args=("$@")
	  if [[ -d "${args[$#-1]}" ]];then
		  continue
	  else
		  mkdir ${args[$#-1]}
	  fi
	  if [[ -f "$1" ]];then
		  #rsync=1
		  #size=$(ls -l $1|cut -d ' ' -f5)
		  #echo $size
		  touch /tmp/mycp
		  { 
			  #rsync -P $1 $2;echo 0 > /tmp/mycp 
			  gcp -f $1 $2 > /tmp/mycp 2>&1
			  #rm /tmp/mycp
		  } &
		  #size2=$(ls -l "$2/$(basename "$1")"|cut -d ' ' -f5)
		  a=1
		  while [ -f "/tmp/mycp" ]
		  do
			  #ls -l "$2/$(basename "$1")"|cut -d ' ' -f5
			  gcp=$(cat -v /tmp/mycp|sed -e 's/\^M/\n/g'|tail -n 1)
			  #echo -ne "1\n$gcp\r"
			  #printf "\033c"
			  a=$(( $a+1 ))
			  echo -ne "$a $gcp\r"
			  #echo -ne "$gcp\r"
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
	  fi
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
