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
	  if [[ -d "$argend" ]];then
		  for (( i=0;i<=$(( $#-2 ));i++ ));do
			  o="$o $(echo $argend|sed 's/\/$//')/$(basename ${args[$i]})"
		  done
	  else
		  o="$argend"
	  fi
	  size=$(du -c -s $s|tail -n 1|sed 's/\([0-9]*\).*$/\1/')
	  hsize=$(du -c -s -h $s|tail -n 1|sed 's/^\([^\t]*\)\t.*$/\1B/')
	  {
		  cp -vr $@
		  rm /tmp/ohmycp
	  }&
	  sleep 0.1
	  while [ -f "/tmp/ohmycp" ]
	  do
		  ttylen="$(tput cols)"
		  size2=$(du -c -s $o 2>/dev/null |tail -n 1|sed 's/\([0-9]*\).*$/\1/')
		  progressnum="$(echo -e "scale=3;$size2/$size*100"|bc|sed 's/[0-9]\{2\}$//')"
		  progress=$(printf "%6s" "$progressnum")
		  pstart="Copying $hsize |"
		  pend="|$progress%"
		  stenlen=$(( $ttylen-${#pstart}-8 ))
		  gprolen=$(echo -e "scale=2;$size2/$size*$stenlen+1"|bc|sed 's/\..*$//')
		  gpro=$(for (( i=1;i<=$gprolen;i++ ));do echo -n '#';done)
		  echo -ne "$pstart"
		  printf "%-$stenlen""s" "$gpro"
		  if [[ "$(echo $progressnum|sed 's/\..*$//')" == "99" ]];then
			  echo -e "\b#| 100.0%"
			  break
		  else
			  echo -ne "$pend\r"
		  fi
	  done
	  wait
	  return 0
	  ;;
esac
}

ohmygcp "$@"
