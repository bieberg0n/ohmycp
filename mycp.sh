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
	if [[ -f "$1" ]];then
	  if [[ ! -e "$2" ]] || [[ -f "$2" ]];then
		pv "$1" > "$2"
	  elif [[ -d "$2" ]];then
		pv "$1" > "$2/$(basename "$1")"
	  fi
	elif [[ -d "$1" ]];then
	  if [[ ! -e "$2" ]];then
		(cd "$1" || exit 1
		mkdir "$2" || exit 1
		tar cf - . | pv | tar xf - -C "$2")
	  elif [[ -d "$2" ]];then
		tar cf - "$1" | pv | tar xf - -C "$2"
	  fi
	fi
	;;
  *)
	local args dest
	args=("$@")
	dest=${args[${#args[@]}-1]}
	unset args[${#args[@]}-1]
	if [[ -d "$dest" ]];then
	  tar cf - "${args[@]}" | pv | tar xf - -C "$dest"
	fi
	;;
esac
}
 
cpv "$@"
