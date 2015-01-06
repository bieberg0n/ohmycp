ohmygcp() {
if ! type -P gcp >/dev/null;then
  echo need gcp >&2
  return 1
fi
case $# in
  0|1)
	  cp -v $@
	  ;;
  *)
	  touch /tmp/ohmycp
	  args=($@)
	  s=${args[@]:0:$#-1}
	  argend=${args[-1]}
	  #获取新文件的名称
	  if [[ -d "$argend" ]];then
		  for (( i=0;i<=$(( $#-2 ));i++ ));do
			  o="$o $(echo $argend|sed 's/\/$//')/$(basename ${args[$i]})"
		  done
	  else
		  o="$argend"
	  fi
	  #被复制的文件总大小
	  size=$(du -c -s $s|tail -n 1|sed 's/\([0-9]*\).*$/\1/')
	  #被复制的文件总大小(易于阅读的格式)
	  hsize=$(du -c -s -h $s|tail -n 1|sed 's/^\([^\t]*\)\t.*$/\1B/')
	  #子进程执行复制
	  {
		  cp -vr $@
		  rm /tmp/ohmycp
	  }&
	  sleep 0.1

	  while [ -f "/tmp/ohmycp" ]
	  do
		  #终端宽度
		  ttylen="$(tput cols)"
		  #已复制内容总大小
		  size2=$(du -c -s $o 2>/dev/null |tail -n 1|sed 's/\([0-9]*\).*$/\1/')
		  #百分比
		  progressnum="$(echo -e "scale=3;$size2/$size*100"|bc|sed 's/[0-9]\{2\}$//')"
		  #调整长度
		  progress=$(printf "%6s" "$progressnum")
		  pstart="Copying $hsize |"
		  pend="|$progress%"
		  #进度条总长度
		  stenlen=$(( $ttylen-${#pstart}-8 ))
		  #"#"号要显示的长度
		  gprolen=$(echo -e "scale=2;$size2/$size*$stenlen+1"|bc|sed 's/\..*$//')
		  #生成"#"号字符串
		  gpro=$(for (( i=1;i<=$gprolen;i++ ));do echo -n '#';done)
		  #显示头部
		  echo -ne "$pstart"
		  #显示进度条
		  printf "%-$stenlen""s" "$gpro"
		  if [[ "$(echo $progressnum|sed 's/\..*$//')" == "99" ]];then
			  #结束时显示100.0%
			  echo -e "\b#| 100.0%"
			  break
		  else
			  #未结束时显示当前进度百分比
			  echo -ne "$pend\r"
		  fi
	  done
	  wait
	  return 0
	  ;;
esac
}

ohmygcp "$@"
