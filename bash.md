```bash
while getopts ":hcplmvV" opt; do
  case $opt in
    h)
      #echo "-h help was triggered!" >&2
      echo $MINF1
      echo $MINF2
      exit 1
      ;;
    V)
      #echo "-V revision info was triggered!" >&2
      echo $MREV
      exit 1
      ;;
    v)
      #echo "-v print more info triggered!" >&2
      PLESS="False"
      PMINI="False"
      ;;
    m)
      #echo "-m print mini info triggered!" >&2
      PLESS="True"
      PMINI="True"
      ;;
    c)
      #echo "-c no colored-lines triggered!" >&2
      NCOL="True"
      ;;
    p)
      #echo "-p no header-lines triggered!" >&2
      PHC="False"
      ;;
    l)
      #echo "-l no command-lines triggered!" >&2
      CMC="False"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

```
