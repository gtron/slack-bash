#!/bin/bash 

HOSTNAME='myhost.slack.com'
TOKEN='myTOKEN'
BOTNAME='BashBot'

ICON=':computer:';

while [[ $# > 0 && $1 =~ -* ]]
do
key="$1"

case $key in
        -to)
            shift
            if [[ "$1" =~ "@" ]]; then
                    DEST=${1/@/%40}
                    ASUSER="as_user=true&"
            else
                    DEST="%23$1"
            fi
            DEST=${DEST/\#/%23}
        ;;
        -c|--color)
                shift
                COLOR=$1
        ;;
        -s|--severity)
          shift
            SEVERITY=${1-'INFO'};
  
            case "$SEVERITY" in
              INFO)
                ICON=':page_with_curl:';
                COLOR=good
                ;;
              WARN|WARNING)
                ICON=':warning:';
                COLOR=${COLOR:-'warning'};
                ;;
              ERROR|ERR)
                ICON=':bangbang:';
                COLOR=danger
                ;;
              *)
                ICON=':slack:';
                ;;
            esac
        ;;
        -i|--icon)
            shift
            ICON=":$1:"
        ;;
        -d|--debug)
      DEBUG=1
    ;;
      -x|--explain) 
      set -x
    ;;
    -h|--help)
    usage
        ;;
    *)
        MSG="$MSG $1"
    ;;
esac
shift
done


sendSlack() {

  MSG="$@"
  MESSAGE=$( echo "$MSG" | sed -f urlencode.sed );
  [ ! -z $COLOR ] && ATTACHMENTS=$( echo "[{\"pretext\": \"$PRETEXT\", \"text\": \"$@\", \"color\":\"${COLOR}\", \"fallback\":\"${MSG:0:60}...\"}]" | sed -f urlencode.sed) && MESSAGE=""

  IMAGE="https://slack.global.ssl.fastly.net/205a/img/services/jenkins-ci_36.png"
  [ -z $IMAGE ] || [[ $_DEST =~ %40 ]] ||  IMAGE="icon_url=$IMAGE" && ICON=""
  PAYLOAD="${ASUSER:-""}channel=${DEST}&username=${BOTNAME}&icon_emoji=${ICON}&text=${MESSAGE}&token=$TOKEN&pretty=1&${IMAGE}&attachments=$ATTACHMENTS";

  API="api/chat.postMessage"
  URL="https://${HOSTNAME}/$API?$PAYLOAD"

  curlCmd="curl -s -S $URL"
  
  if [ "$DEBUG" == "1" ]; then
    echo "Should run ... $curlCmd"
    
  else
	  CURL_RESULT=$($curlCmd)
	  if [ -z "$CURL_RESULT" ]; then
	    return 0;
	  else
	    return 1;
	  fi
  fi

}

sendSlack "$MSG"
